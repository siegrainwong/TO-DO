//
//  SyncDataManager.m
//  TO-DO
//
//  Created by Siegrain on 16/6/2.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "AFHTTPRequestOperationManager+Synchronous.h"
#import "AFNetworking.h"
#import "AppDelegate.h"
#import "CDTodo.h"
#import "DateUtil.h"
#import "GCDQueue.h"
#import "LCSyncRecord.h"
#import "LCTodo.h"
#import "SCLAlertHelper.h"
#import "SyncDataManager.h"

typedef NS_ENUM(NSInteger, TodoFetchType) {
    TodoFetchTypeCommit,
    TodoFetchTypeDownload
};

/* 每次同步最大获取数据量 */
static NSInteger const kMaximumSyncCountPerFetch = 100;
/* 本地时间与服务器时间相差多少秒禁止同步 */
static NSInteger const kInvalidTimeInterval = 10;

@interface
SyncDataManager ()
@property (nonatomic, readwrite, strong) CDUser* cdUser;
@property (nonatomic, readwrite, strong) LCUser* lcUser;

@property (nonatomic, readwrite, strong) NSManagedObjectContext* localContext;
@property (nonatomic, readwrite, strong) CDSyncRecord* syncRecord;
@property (nonatomic, readwrite, strong) SyncErrorHandler* errorHandler;

@property (nonatomic, readwrite, assign) SyncType syncType;
@property (nonatomic, readwrite, assign) SyncMode syncMode;
@property (nonatomic, readwrite, assign) BOOL isSyncing;
@property (nonatomic, readwrite, assign) NSUInteger synchronizedCount;
@property (nonatomic, readwrite, strong) NSMutableDictionary* lastCreatedAtDictionary;
@property (nonatomic, readwrite, strong) NSString* recordMark;
@end

@implementation SyncDataManager
@synthesize localDictionary = _localDictionary;
#pragma mark - accessors
+ (BOOL)isSyncing
{
    return [[self dataManager] isSyncing];
}

#pragma mark - initial
+ (instancetype)dataManager
{
    static SyncDataManager* dataManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dataManager = [SyncDataManager new];
        dataManager.isSyncing = NO;
        dataManager.errorHandler = [SyncErrorHandler new];
        dataManager.lastCreatedAtDictionary = [NSMutableDictionary new];
        [dataManager.errorHandler setErrorHandlerWillReturn:^{
            [dataManager cleanUp];
        }];
    });
    return dataManager;
}
#pragma mark - synchronization
- (void)synchronize:(SyncMode)syncMode complete:(CompleteBlock)complete;
{
    _isSyncing = YES;
    /*
	 同步方式：
	 每一批次两个并行队列，每次最多同步五十条数据，超过五十条下次进行同步。
	 每批同步分上传和下载（与队列不对应），若上传或下载数超过上限，则下一批次同步。
	 
	 同步类型：
	 1. 若本地没有同步记录，则将本地所有数据进行上传，并将服务器上所有的数据进行下载(incremental sync)
	 2. 若 lastSyncTimeOnServer = lastSyncTimeOnClient，表明服务器数据没有变化，则仅需要上传本地修改过的数据和新增的数据(send changes)
	 3. 若 lastSyncTimeOnServer > lastSyncTimeOnClient，则进行全数据对比，先对比同步所有已有数据，再将其他数据从服务器上下载(full sync)
	 4. 其他情况进行incremental sync
	 
	 注意事项：
	 1. 所有同步时间戳均以服务器时间为准，每次同步之前先获取服务器的时间戳
	 2. 若本地时间与服务器时间相差xx秒以上，提醒并不予同步
	 3. 对比同步规则：1.大版本同步小版本 2.版本相同的话，以线上数据为准进行覆盖（另一种做法是建立冲突副本，根据本项目的实际情况不采用这种方式）
	 
	 异常情况：
	 以下几种情况会影响同步时数据的原子性：
	 1. 云函数返回之前挂掉：下次同步则为full sync，同时在对比时会将objectId赋值给本地对应的待办事项。
	 2. 若在批次之间挂掉的话（上一批成功，下一批挂掉），这时需要在判断同步类型时，判断上一次同步成功的记录次数，若次数超限，此次同步为full sync。
	 */

    /*
	 TODO: 如何实现按批同步，需要在同步中获取到两种类型的数量，分别为上传数量和下载数量，其中一种数量超过批次读取数上限时，递归同步
	 同时数据以localCreatedAt字段进行分页，所以每次同步结束时需要按数量类型来保存lastLocalCreatedAt字段。
	 
	 不过现在有个问题，批次之间duang了怎么办？我还没有想好，我明天再琢磨下
	 */
    __weak typeof(self) weakSelf = self;
    NSBlockOperation* asyncOperation = [NSBlockOperation new];
    [asyncOperation addExecutionBlock:^{
        //1. 准备同步
        if (![weakSelf isPreparedWithSyncMode:syncMode])
            return [weakSelf.errorHandler returnWithError:nil description:@"2. 准备同步失败，停止同步" failBlock:complete];

        __block NSMutableArray<CDTodo*>* todosReadyToCommit = [NSMutableArray new];

        //2. 开始同步
        NSBlockOperation* operation = [NSBlockOperation new];
        __weak NSBlockOperation* weakOperation = operation;
        //2-1. 并行线程1
        [operation addExecutionBlock:^{
            NSDate* lastCreatedAt = weakSelf.lastCreatedAtDictionary[@(TodoFetchTypeCommit)];

            //如果是提交变更，获取所有修改过的数据、如果是其他模式，就只获取本地新增的数据
            NSArray<CDTodo*>* todosArray = [weakSelf fetchTodoWithAVObjectFiltering:weakSelf.syncType == SyncTypeSendChanges ? AVObjectFilteringNone : AVObjectFilteringNoObjectId isOnlyFetchTodosNeedsToCommit:YES lastCreatedAt:lastCreatedAt ?: [NSDate date]];
            [todosReadyToCommit addObjectsFromArray:todosArray];
            [weakSelf recordDataCountAndLastCreateDateWithArray:todosArray fetchType:TodoFetchTypeCommit];
        }];
        //2-2. 并行线程2
        [operation addExecutionBlock:^{
            NSDate* lastCreatedAt = weakSelf.lastCreatedAtDictionary[@(TodoFetchTypeDownload)];
            if (weakSelf.syncType == SyncTypeIncrementalSync) {
                //2-2-1. 如果是增量同步，将服务器的数据添加到上下文中
                if ([weakSelf isAddedTodosToContextFromTodosOnServerWithLastCreatedAt:lastCreatedAt ?: [NSDate date]]) return;

                [weakOperation setCompletionBlock:nil];
                return [weakSelf.errorHandler returnWithError:nil description:@"2-1. 下载数据失败" failBlock:complete];
            } else if (weakSelf.syncType == SyncTypeFullSync) {
                //2-2-2. 如果是全量同步，则将本地没有的数据添加进上下文，将其他数据对比之后加入相应的同步序列
                [todosReadyToCommit addObjectsFromArray:[weakSelf retreiveTodosNeedsToCommitAndCompareTheRestOfTodosWithLastCreatedAt:lastCreatedAt ?: [NSDate date]]];
            }
        }];
        //2-3. 汇总线程
        [operation setCompletionBlock:^{
            DDLogInfo(@"进入汇总线程");

            if (![weakSelf commitTodosAndSave:todosReadyToCommit])
                return [self.errorHandler returnWithError:nil description:@"2-3. 上传\\保存数据失败" failBlock:complete];

            return [weakSelf returnIfDonNotNeedToSync:complete];
        }];
        [operation start];
    }];
    [asyncOperation start];
}
#pragma mark - sync methods
#pragma mark - sync prepare
/**
 *  准备同步
 *
 *  @param latestSyncRecordOnLocal 输出：本次同步的同步记录
 *
 *  @return 是否成功
 */
- (BOOL)isPreparedWithSyncMode:(SyncMode)syncMode
{
    if (_synchronizedCount) {
        _syncRecord = [self syncRecordByInsertOnServerAndLocal];
        if (!_syncRecord) return NO;

        return YES;
    }

    if (!_lcUser) _lcUser = [AppDelegate globalDelegate].lcUser;
    if (!_cdUser) _cdUser = [AppDelegate globalDelegate].cdUser;

    _errorHandler.isAlert = syncMode == SyncModeManually;

    _recordMark = [[NSUUID UUID] UUIDString];

    _localContext = [NSManagedObjectContext MR_contextWithParent:[NSManagedObjectContext MR_rootSavingContext]];

    //1. 根据服务器和本地的最新同步记录获取此次同步的同步类型
    _syncType = [self syncTypeWithLastSyncRecordOnServer:[self retriveLastSyncRecordOnServer] andLastSyncRecordOnLocal:[self retriveLastSyncRecordOnLocal]];

    //2. 在本地和线上插入同步记录，准备开始同步
    _syncRecord = [self syncRecordByInsertOnServerAndLocal];
    if (!_syncRecord) return NO;

    return YES;
}
#pragma mark - sync type
/**
 *  获取此次同步的同步类型
 *
 *  @param lcSyncRecord 服务器的同步记录
 *  @param cdSyncRecord 本地的同步记录
 *
 *  @return 同步类型
 */
- (SyncType)syncTypeWithLastSyncRecordOnServer:(LCSyncRecord*)lcSyncRecord andLastSyncRecordOnLocal:(CDSyncRecord*)cdSyncRecord
{
    /**
	 *	1. 若 lastSyncTimeOnServer = lastSyncTimeOnClient，表明服务器数据没有变化，则仅需要上传本地修改过的数据和新增的数据(send changes)
	 *	2. 若 lastSyncTimeOnServer > lastSyncTimeOnClient，则进行全数据对比，先对比同步所有已有数据，再将其他数据从服务器上下载(full sync)
	 *  3. 若 Server 没有该 Client 的同步记录，则将本地所有数据进行上传，并将服务器上所有的数据进行下载(incremental sync)
	 *  4. 正常情况来说，是不会出现 lastSyncTimeOnServer < lastSyncTimeOnClient 的，这种情况也进行 incremental sync
	 */
    if (!cdSyncRecord)
        return SyncTypeIncrementalSync;

    // 参见 异常情况2
    if (cdSyncRecord.commitCount.integerValue >= kMaximumSyncCountPerFetch || cdSyncRecord.downloadCount.integerValue >= kMaximumSyncCountPerFetch)
        return SyncTypeFullSync;

    if ([lcSyncRecord.syncBeginTime compare:cdSyncRecord.syncBeginTime] == NSOrderedSame)
        return SyncTypeSendChanges;
    else if ([lcSyncRecord.syncBeginTime compare:cdSyncRecord.syncBeginTime] == NSOrderedDescending)
        return SyncTypeFullSync;
    else
        return SyncTypeIncrementalSync;
}
#pragma mark - incremental sync methods
/**
 *  获取服务器上可以同步的待办事项，并转换为本地对象添加到当前上下文中
 *
 *  @return 是否成功
 */
- (BOOL)isAddedTodosToContextFromTodosOnServerWithLastCreatedAt:(NSDate*)lastCreatedAt
{
    NSArray<LCTodo*>* todosNeedsToDownload = [self retrieveTodosWithLastCreatedAt:lastCreatedAt];
    if (!todosNeedsToDownload) return NO;
    [self recordDataCountAndLastCreateDateWithArray:todosNeedsToDownload fetchType:TodoFetchTypeDownload];

    for (LCTodo* todo in todosNeedsToDownload) {
        CDTodo* cdTodo = [CDTodo cdTodoWithLCTodo:todo inContext:_localContext];
        cdTodo.syncStatus = @(SyncStatusSynchronized);
    }

    return YES;
}
#pragma mark - full sync methods
/**
 *  将本地没有的数据添加进上下文，将其他数据对比之后加入相应的同步序列，并返回需要上传的数组
 *
 *  @return 等待上传的数据
 */
- (NSArray<CDTodo*>*)retreiveTodosNeedsToCommitAndCompareTheRestOfTodosWithLastCreatedAt:(NSDate*)lastCreatedAt
{
    NSMutableArray<CDTodo*>* todosReadyToCommit = [NSMutableArray new];
    NSMutableArray<LCTodo*>* serverTodosArray = [NSMutableArray arrayWithArray:[self retrieveTodosWithLastCreatedAt:lastCreatedAt]];
    [self recordDataCountAndLastCreateDateWithArray:serverTodosArray fetchType:TodoFetchTypeDownload];

    for (LCTodo* lcTodo in serverTodosArray) {
        // 筛选出本地没有的数据
        CDTodo* cdTodo = [self todoWithIdentifier:lcTodo.identifier];
        if (!cdTodo) {
            cdTodo = [CDTodo cdTodoWithLCTodo:lcTodo inContext:_localContext];
            cdTodo.syncStatus = @(SyncStatusSynchronized);
            continue;
        }

        // 参见 异常情况1
        if (!cdTodo.objectId) cdTodo.objectId = lcTodo.objectId;

        // 对比规则：1.大版本同步小版本 2.版本相同的话，以线上数据为准进行覆盖
        if (lcTodo.syncVersion >= cdTodo.syncVersion.integerValue) {
            [cdTodo cdTodoReplaceByLCTodo:lcTodo];
            cdTodo.syncStatus = @(SyncStatusSynchronized);
        } else if (lcTodo.syncVersion < cdTodo.syncVersion.integerValue) {
            [todosReadyToCommit addObject:cdTodo];
        }
    }

    return [todosReadyToCommit copy];
}
#pragma mark - sync saving methods
/**
 *  将准备提交给服务器的待办事项转换为字典，并将本地待办事项标记为“已同步”状态
 */
- (NSArray<NSDictionary*>*)todosToDictionary:(NSArray<CDTodo*>*)cdTodosArray
{
    NSMutableArray<NSDictionary*>* result = [NSMutableArray new];
    for (CDTodo* todo in cdTodosArray) {
        //2-1-1-1. 转换为LeanCloud对象，再转换为字典，添加到待上传列表中
        LCTodo* lcTodo = [LCTodo lcTodoWithCDTodo:todo];
        [result addObject:[[lcTodo dictionaryForObject] copy]];

        //2-1-1-2. 修改本地数据状态为同步完成
        todo.syncStatus = @(SyncStatusSynchronized);
    }

    return [result copy];
}
/**
 *  调用云函数保存代办事项，更新同步记录并保存当前上下文
 *
 *  @param todosReadyToCommit 待提交的待办事项
 *  @param syncRecord         需要更新的同步记录
 *
 *  @return 是否成功
 */
- (BOOL)commitTodosAndSave:(NSArray<CDTodo*>*)todosReadyToCommit
{
    // 2-1-3-1. 上传数据并保存服务器的同步记录
    NSArray<NSDictionary*>* todosDictionary = [self todosToDictionary:todosReadyToCommit];
    NSError* error = nil;
    NSDictionary* commitTodoParameters =
      @{ @"todos" : todosDictionary,
          @"syncRecordDictionary" : @{
              @"syncRecordId" : _syncRecord.objectId,
              @"commitCount" : _syncRecord.commitCount,
              @"downloadCount" : _syncRecord.downloadCount
          } };
    // Mark: 这里回调返回了两个数据，第一个是待办事项objectId数组，第二个是服务器修改过的的SyncRecord字典。
    // Mark: LeanCloud rpcFunction美名其曰可以直传AVObject，然而云函数并不支持保存
    NSArray* responseDatas = [AVCloud callFunction:@"commitTodos" withParameters:commitTodoParameters error:&error];
    if (error) return NO;

    NSArray* objectIdArray = responseDatas[0];
    NSDictionary* syncRecordDictionary = responseDatas[1];

    // 2-1-3-2. 修改本地待办事项的objectId
    if (objectIdArray.count)
        [todosReadyToCommit enumerateObjectsUsingBlock:^(CDTodo* todo, NSUInteger idx, BOOL* stop) {
            if (!todo.objectId) todo.objectId = objectIdArray[idx];
        }];

    // 2-1-3-3. 上传成功后更新本地的同步记录
    _syncRecord.isFinished = syncRecordDictionary[@"isFinished"];
    _syncRecord.syncEndTime = syncRecordDictionary[@"syncEndTime"];

    // 2-1-3-4. 持久化保存本地数据
    [_localContext MR_saveToPersistentStoreAndWait];

    return YES;
}
#pragma mark - LeanCloud methods
#pragma mark - retrieve sync record
/**
 *  根据本机唯一标识获取服务器上的最新一条同步记录
 */
- (LCSyncRecord*)retriveLastSyncRecordOnServer
{
    AVQuery* query = [AVQuery queryWithClassName:[LCSyncRecord parseClassName]];
    [query whereKey:@"isFinished" equalTo:@(YES)];
    [query whereKey:@"user" equalTo:_lcUser];
    [query orderByDescending:@"syncBeginTime"];
    NSError* error = nil;
    LCSyncRecord* record = (LCSyncRecord*)[query getFirstObject:&error];
    if (error && error.code != 101) {  //101意思是没有这个表
        [SCLAlertHelper errorAlertWithContent:error.localizedDescription];
        return [self.errorHandler returnWithError:error description:[NSString stringWithFormat:@"1. 获取服务器同步记录失败 %s", __func__]];
    }

    return record;
}
#pragma mark - retrieve todo

/**
 *  获取服务器上所有可以同步的待办事项
 */
- (NSArray<LCTodo*>*)retrieveTodosWithLastCreatedAt:(NSDate*)lastCreatedAt
{
    AVQuery* query = [AVQuery queryWithClassName:[LCTodo parseClassName]];
    [query whereKey:@"user" equalTo:_lcUser];
    [query whereKey:@"localCreatedAt" lessThan:lastCreatedAt];
    [query orderByDescending:@"localCreatedAt"];
    [query setLimit:kMaximumSyncCountPerFetch];

    NSError* error = nil;
    NSArray<LCTodo*>* array = [query findObjects:&error];
    if (error && error.code != 101) {  //101意思是没有这个表
        [SCLAlertHelper errorAlertWithContent:error.localizedDescription];
        return [self.errorHandler returnWithError:error description:[NSString stringWithFormat:@"2-1. %s", __func__]];
    }

    return array;
}
#pragma mark - MagicRecord methods
#pragma mark - retrive sync record
/**
 *  根据本机唯一标识获取本地的最新一条同步记录
 */
- (CDSyncRecord*)retriveLastSyncRecordOnLocal
{
    NSPredicate* filter = [NSPredicate predicateWithFormat:@"isFinished = %d AND user = %@", YES, _cdUser];
    CDSyncRecord* record = [CDSyncRecord MR_findFirstWithPredicate:filter sortedBy:@"syncBeginTime" ascending:NO];

    return record;
}
#pragma mark - retrieve data that needs to sync
/**
 *  筛选本地前50条待办事项，以createdAt倒序排序
 *
 *  @param filtering objectId的筛选规则
 *  @param filtering 是否只筛选需要上传的待办事项
 *
 *  @return 本地待办事项
 */
- (NSArray<CDTodo*>*)fetchTodoWithAVObjectFiltering:(AVObjectFiltering)filtering isOnlyFetchTodosNeedsToCommit:(BOOL)todosIsNeedsToCommit lastCreatedAt:(NSDate*)lastCreatedAt
{
    NSMutableArray* arguments = [NSMutableArray new];
    NSString* predicateFormat = @"user = %@ AND createdAt < %@";
    [arguments addObjectsFromArray:@[ _cdUser, lastCreatedAt ]];

    NSString* appendPredicate = @"";
    NSString* sortBy = @"createdAt";
    if (filtering == AVObjectFilteringHasObjectId)
        appendPredicate = @" and objectId != nil";
    else if (filtering == AVObjectFilteringNoObjectId)
        appendPredicate = @" and objectId = nil";

    predicateFormat = [predicateFormat stringByAppendingString:appendPredicate];
    appendPredicate = @"";
    if (todosIsNeedsToCommit) {
        appendPredicate = @" and syncStatus != %@";
        [arguments addObject:@(SyncStatusSynchronized)];
    }
    predicateFormat = [predicateFormat stringByAppendingString:appendPredicate];

    NSPredicate* filter = [NSPredicate predicateWithFormat:predicateFormat argumentArray:[arguments copy]];
    NSFetchRequest* request = [CDTodo MR_requestAllWithPredicate:filter inContext:_localContext];
    [request setFetchLimit:kMaximumSyncCountPerFetch];
    request.sortDescriptors = @[ [[NSSortDescriptor alloc] initWithKey:sortBy ascending:NO] ];
    NSArray<CDTodo*>* data = [CDTodo MR_executeFetchRequest:request inContext:_localContext];

    return data;
}
#pragma mark - fetch todo by uuid
/**
 *  根据identifier获取待办事项
 */
- (CDTodo*)todoWithIdentifier:(NSString*)identifier
{
    return [CDTodo MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"identifier = %@", identifier] inContext:_localContext];
}
#pragma mark - both MagicRecord and LeanCloud methods
#pragma mark - insert sync record
/**
 *  向服务器和本地插入一条同步记录
 *
 *  @return 本地的同步记录实体
 */
- (CDSyncRecord*)syncRecordByInsertOnServerAndLocal
{
    NSDate* serverDate = [self serverDate];
    if (!serverDate) return nil;

    NSError* error = nil;
    LCSyncRecord* lcSyncRecord = [LCSyncRecord object];
    lcSyncRecord.isFinished = NO;
    lcSyncRecord.user = self.lcUser;
    lcSyncRecord.syncBeginTime = serverDate;
    lcSyncRecord.phoneIdentifier = self.cdUser.phoneIdentifier;
    lcSyncRecord.syncEndTime = nil;
    lcSyncRecord.syncType = _syncType;
    lcSyncRecord.recordMark = _recordMark;

    [lcSyncRecord save:&error];
    if (error) return [self.errorHandler returnWithError:error description:[NSString stringWithFormat:@"2. %s", __func__]];

    CDSyncRecord* cdSyncRecord = [CDSyncRecord syncRecordFromLCSyncRecord:lcSyncRecord inContext:_localContext];

    DDLogInfo(@"正在保存本地的同步记录");
    [_localContext MR_saveToPersistentStoreAndWait];

    return cdSyncRecord;
}
#pragma mark - helper
/**
 *  获取服务器时间并转换为 NSDate
 */
- (NSDate*)serverDate
{
    NSDictionary* parameters = [NSDictionary dictionaryWithObjects:@[ kLeanCloudAppID, kLeanCloudAppKey ] forKeys:@[ @"X-LC-Id", @"X-LC-Key" ]];
    AFHTTPRequestOperationManager* manager = [AFHTTPRequestOperationManager manager];
    NSError* error = nil;
    NSDictionary* responseObject = [manager syncGET:kLeanCloudServerDateApiUrl parameters:parameters operation:nil error:&error];
    if (error) return [self.errorHandler returnWithError:error description:@"2. 无法获取服务器时间"];

    NSDate* serverDate = [DateUtil dateFromISO8601String:responseObject[@"iso"]];
    NSInteger intervalFromServer = fabs([serverDate timeIntervalSince1970] - [[NSDate date] timeIntervalSince1970]);
    if (intervalFromServer > kInvalidTimeInterval)
        return [self.errorHandler returnWithError:nil description:@"2. 本地时间和服务器时间相差过大，已停止同步"];

    return serverDate;
}
- (void)recordDataCountAndLastCreateDateWithArray:(NSArray*)array fetchType:(TodoFetchType)fetchType
{
    NSDate* createdAt;
    if (fetchType == TodoFetchTypeCommit) {
        _syncRecord.commitCount = @(array.count);
        createdAt = ((CDTodo*)[array lastObject]).createdAt;

    } else {
        _syncRecord.downloadCount = @(array.count);
        createdAt = ((LCTodo*)[array lastObject]).localCreatedAt;
    }
    _lastCreatedAtDictionary[@(fetchType)] = createdAt ?: [NSDate date];
}
/**
 *  结束同步之前的清除操作
 */
- (void)cleanUp
{
    _syncRecord = nil;
    _localContext = nil;
    _isSyncing = NO;
    _synchronizedCount = 0;
    _recordMark = nil;
    _lastCreatedAtDictionary = [NSMutableDictionary new];
}
/**
 *  先检查是否需要继续同步，不需要则返回，需要则递归
 */
- (void)returnIfDonNotNeedToSync:(CompleteBlock)block
{
    NSInteger commitCount = _syncRecord.commitCount.integerValue;
    NSInteger downloadCount = _syncRecord.downloadCount.integerValue;

    if (commitCount < kMaximumSyncCountPerFetch && downloadCount < kMaximumSyncCountPerFetch) {
        DDLogInfo(@"此次同步完毕，一共进行了 %ld 次同步", _synchronizedCount + 1);
        [self cleanUp];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            return block(YES);
        }];
    } else {
        _synchronizedCount++;
        DDLogInfo(@"开始进行第 %ld 次同步", _synchronizedCount + 1);
        return [self synchronize:SyncModeManually complete:block];
    }
}
/**
 *  将本地待办事项数组转换为字典，并将objectId设为key
 */
- (NSDictionary*)cdTodosToDictionaryWithObjectIdSetToKey:(NSArray<CDTodo*>*)todosArray
{
    NSMutableDictionary* result = [NSMutableDictionary new];
    for (CDTodo* todo in todosArray) {
        [result setObject:todo forKey:todo.objectId];
    }

    return [result copy];
}
@end
