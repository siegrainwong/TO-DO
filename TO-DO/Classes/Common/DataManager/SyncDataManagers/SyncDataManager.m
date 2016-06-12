//
//  SyncDataManager.m
//  TO-DO
//
//  Created by Siegrain on 16/6/2.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "AFHTTPRequestOperationManager+Synchronous.h"
#import "AFNetworking.h"
#import "CDTodo.h"
#import "CDUser.h"
#import "DateUtil.h"
#import "GCDQueue.h"
#import "LCSyncRecord.h"
#import "LCTodo.h"
#import "LCUser.h"
#import "SCLAlertHelper.h"
#import "SyncDataManager.h"

static NSInteger const kFetchLimitPerBatch = 50;
static NSInteger const kInvalidTimeInterval = 10;

@interface
SyncDataManager ()
@property (nonatomic, readwrite, strong) CDUser* cdUser;
@property (nonatomic, readwrite, strong) LCUser* lcUser;

@property (nonatomic, readwrite, assign) SyncMode syncType;
@property (nonatomic, readwrite, assign) BOOL isSyncing;
@property (nonatomic, readwrite, strong) NSManagedObjectContext* localContext;
@property (nonatomic, readwrite, strong) SyncErrorHandler* errorHandler;
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
        [dataManager.errorHandler setErrorHandlerWillReturn:^{
            dataManager.localContext = nil;
        }];
    });
    return dataManager;
}
- (void)setupSync:(SyncMode)syncType
{
    _syncType = syncType;
    _lcUser = [LCUser currentUser];
    _cdUser = [CDUser userWithLCUser:_lcUser];
    _errorHandler.isAlert = _syncType == SyncModeManually;

    /*
	 Mark: MagicalRecord
	 在另一个线程中，对于根上下文的操作是无效的，必须新建一个上下文，该上下文从属于根上下文
	 若不想保存该上下文的内容，在执行save之前释放掉即可
	 */
    _localContext = [NSManagedObjectContext MR_contextWithParent:[NSManagedObjectContext MR_rootSavingContext]];
}
#pragma mark - synchronization
- (void)synchronize:(SyncMode)syncType complete:(CompleteBlock)complete;
{
    //    if (_isSyncing) return complete(YES);
    //    _isSyncing = YES;
    /*
	 同步方式：
	 每一次队列同步最新的五十条数据，有错误的话，队列作废
	 1. 若 Server 没有该 Client(需要手机的唯一识别码进行辨认) 的同步记录，则将本地所有数据进行上传，并将服务器上所有的数据进行下载(incremental sync)
	 2. 若 lastSyncTimeOnServer = lastSyncTimeOnClient，表明服务器数据没有变化，则仅需要上传本地修改过的数据和新增的数据(send changes)
	 3. 若 lastSyncTimeOnServer > lastSyncTimeOnClient，则进行全数据对比，先对比同步所有已有数据，再将其他数据从服务器上下载(full sync)
	 
	 注意事项：
	 1. 所有同步时间戳均以服务器时间为准，每次同步之前先获取服务器的时间戳
	 2. 若本地时间与服务器时间相差xx秒以上，提醒并不予同步
	 3. 对比同步规则：1.大版本同步小版本 2.版本相同的话，以线上数据为准进行覆盖（另一种做法是建立冲突副本，根据本项目的实际情况不采用这种方式）
	 */
    __weak typeof(self) weakSelf = self;
    NSBlockOperation* asyncOperation = [NSBlockOperation new];
    [asyncOperation addExecutionBlock:^{
        [weakSelf setupSync:syncType];

        //1. 准备同步，获取同步类型和本次同步记录
        SyncType syncType;
        CDSyncRecord* syncRecord = nil;
        if (![weakSelf prepareToSynchronize:&syncType cdSyncRecord:&syncRecord])
            return [weakSelf.errorHandler returnWithError:nil description:@"2. 准备同步失败，停止同步" returnWithBlock:complete];

        //2. 根据同步类型开始同步
        //2-1. 增量同步、提交变更
        if (syncType == SyncTypeIncrementalSync || syncType == SyncTypeSendChanges) {
            __block NSMutableArray<NSDictionary*>* todosReadyToCommit = [NSMutableArray new];

            NSBlockOperation* operation = [NSBlockOperation new];
            __weak NSBlockOperation* weakOperation = operation;
            [operation addExecutionBlock:^{
                //如果是增量同步，就只获取没有同步过的数据，如果是提交变更，就获取所有修改过的数据
                todosReadyToCommit = [NSMutableArray arrayWithArray:[weakSelf lcTodosIsNotSynchronized:syncType == SyncTypeSendChanges]];
            }];
            if (syncType == SyncTypeIncrementalSync) {
                [operation addExecutionBlock:^{
                    if (![weakSelf retrieveTodosAndAddToContext]) {
                        [weakOperation setCompletionBlock:nil];
                        return [self.errorHandler returnWithError:nil description:@"2-1. 下载数据失败" returnWithBlock:complete];
                    }
                }];
            }
            [operation setCompletionBlock:^{
                if (![weakSelf commitTodosAndSave:todosReadyToCommit cdSyncRecord:syncRecord])
                    return [self.errorHandler returnWithError:nil description:@"2-1. 上传数据失败" returnWithBlock:complete];

                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    DDLogInfo(@"all fucking done : %@", [NSThread currentThread]);
                    return complete(YES);
                }];
            }];
            [operation start];
        }
    }];
    [asyncOperation start];
}
#pragma mark - sync methods
/**
 *  准备同步
 *
 *  @param syncType     输出：同步类型
 *  @param cdSyncRecord 输出：本次同步的同步记录
 *
 *  @return 是否成功
 */
- (BOOL)prepareToSynchronize:(SyncType*)syncType cdSyncRecord:(CDSyncRecord**)cdSyncRecord
{
    //1. 根据服务器和本地的最新同步记录获取此次同步的同步类型
    LCSyncRecord* latestSyncRecordOnServer = [self retriveLatestSyncRecordOnServer];
    CDSyncRecord* latestSyncRecordOnLocal = [self retriveLatestSyncRecordOnLocal];
    *syncType = [self syncTypeWithLCSyncRecord:latestSyncRecordOnServer cdSyncRecord:latestSyncRecordOnLocal];

    //2. 在本地和线上插入同步记录，准备开始同步
    *cdSyncRecord = [self insertAndGetSyncRecordWithType:*syncType];
    if (!*cdSyncRecord) return NO;

    return YES;
}
/**
 *  获取服务器上可以同步的待办事项，并转换为本地对象添加到当前上下文中
 *
 *  @return 是否成功
 */
- (BOOL)retrieveTodosAndAddToContext
{
    NSArray<LCTodo*>* todosNeedsToDownload = [self retrieveTodos];
    if (!todosNeedsToDownload) return NO;

    for (LCTodo* todo in todosNeedsToDownload) {
        CDTodo* cdTodo = [CDTodo cdTodoWithLCTodo:todo inContext:_localContext];
        cdTodo.syncStatus = @(SyncStatusSynchronized);
    }

    return YES;
}
/**
 *  获取准备提交给服务器的待办事项，并转换为字典
 *
 *  @param isNotSynchronized 是否只获取没有同步过的数据
 */
- (NSArray<NSDictionary*>*)lcTodosIsNotSynchronized:(BOOL)isNotSynchronized
{
    NSMutableArray<NSDictionary*>* result = [NSMutableArray new];
    NSArray<CDTodo*>* todosNeedsToUpload = [self fetchTodoIsNotSynchronized:isNotSynchronized lastRecordIsUpdateAt:[NSDate date]];
    for (CDTodo* todo in todosNeedsToUpload) {
        //2-1-1-1. 转换为LeanCloud对象，再转换为字典，添加到待上传列表中
        LCTodo* lcTodo = [LCTodo lcTodoWithCDTodo:todo];
        [result addObject:[[lcTodo dictionaryForObject] copy]];

        //2-1-1-2. 修改本地数据状态为同步完成，同时赋予唯一编号
        todo.syncStatus = @(SyncStatusSynchronized);
        todo.objectId = lcTodo.objectId;
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
- (BOOL)commitTodosAndSave:(NSArray<NSDictionary*>*)todosReadyToCommit cdSyncRecord:(CDSyncRecord*)syncRecord
{
    // 2-1-3-1. 上传数据并保存服务器的同步记录
    // Mark: 这个东西要用LeanCloud的云函数来做，不然无法保证数据正确
    // Mark: 我靠它云引擎有Bug，传上去保存成功了，但都是空数据...
    NSError* error = nil;
    NSDictionary* commitTodoParameters = @{ @"todos" : todosReadyToCommit,
        @"syncRecordId" : syncRecord.objectId };
    // Mark: 这里回调返回的是云函数上修改后的SyncRecord字典
    // TODO: 这里回调还需要把objectId取回来..
    NSDictionary* syncRecordDictionary = [AVCloud rpcFunction:@"commitTodos" withParameters:commitTodoParameters error:&error];
    if (error) return NO;

    // 2-1-3-2. 上传成功后更新本地的同步记录
    syncRecord.isFinished = syncRecordDictionary[@"isFinished"];
    syncRecord.syncEndTime = syncRecordDictionary[@"syncEndTime"];

    // 2-1-3-3. 提交本地数据
    [_localContext MR_saveToPersistentStoreAndWait];

    return YES;
}
#pragma mark - LeanCloud methods
#pragma mark - retrieve sync record
/**
 *  根据本机唯一标识获取服务器上的最新一条同步记录
 */
- (LCSyncRecord*)retriveLatestSyncRecordOnServer
{
    AVQuery* query = [AVQuery queryWithClassName:[LCSyncRecord parseClassName]];
    [query whereKey:@"isFinished" equalTo:@(YES)];
    [query whereKey:@"user" equalTo:_lcUser];
    [query whereKey:@"phoneIdentifier" equalTo:_cdUser.phoneIdentifier];
    [query orderByDescending:@"syncBeginTime"];
    NSError* error = nil;
    LCSyncRecord* record = (LCSyncRecord*)[query getFirstObject:&error];
    if (error && error.code != 101) {  //101意思是没有这个表
        [SCLAlertHelper errorAlertWithContent:error.localizedDescription];
        return [self.errorHandler returnWithError:error description:[NSString stringWithFormat:@"1. 获取服务器同步记录失败 %s", __func__]];
        ;
    }

    return record;
}
#pragma mark - retrieve todo

/**
 *  获取服务器上所有可以同步的待办事项
 */
- (NSArray<LCTodo*>*)retrieveTodos
{
    AVQuery* query = [AVQuery queryWithClassName:[LCTodo parseClassName]];
    [query whereKey:@"isHidden" equalTo:@(NO)];
    [query whereKey:@"user" equalTo:_lcUser];
    [query setLimit:kFetchLimitPerBatch];

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
- (CDSyncRecord*)retriveLatestSyncRecordOnLocal
{
    NSPredicate* filter = [NSPredicate predicateWithFormat:@"isFinished = %d AND user = %@", YES, _cdUser];
    CDSyncRecord* record = [CDSyncRecord MR_findFirstWithPredicate:filter sortedBy:@"syncBeginTime" ascending:NO];

    return record;
}
#pragma mark - retrieve data that needs to sync
/**
 *  筛选本地的待办事项
 *
 *  @param isNotSynchronized 是否只获取没有同步过的数据
 *  @param updateAt     最近一条记录的更新时间
 *
 *  @return 本地待办事项
 */
- (NSArray<CDTodo*>*)fetchTodoIsNotSynchronized:(BOOL)isNotSynchronized lastRecordIsUpdateAt:(NSDate*)updateAt
{
    NSMutableArray* arguments = [NSMutableArray new];
    NSString* predicateFormat = @"user = %@ and syncStatus != %@ and updatedAt <= %@";
    [arguments addObjectsFromArray:@[ _cdUser, @(SyncStatusSynchronized), updateAt ]];
    if (isNotSynchronized)
        predicateFormat = [predicateFormat stringByAppendingString:@" and objectId = nil"];

    NSPredicate* filter = [NSPredicate predicateWithFormat:predicateFormat argumentArray:[arguments copy]];
    NSFetchRequest* request = [CDTodo MR_requestAllWithPredicate:filter inContext:_localContext];
    [request setFetchLimit:kFetchLimitPerBatch];
    request.sortDescriptors = @[ [[NSSortDescriptor alloc] initWithKey:@"updatedAt" ascending:NO] ];
    NSArray<CDTodo*>* data = [CDTodo MR_executeFetchRequest:request inContext:_localContext];

    return data;
}
#pragma mark - both MagicRecord and LeanCloud methods
#pragma mark - insert sync record
/**
 *  向服务器和本地插入一条同步记录
 *
 *  @return 本地的同步记录实体
 */
- (CDSyncRecord*)insertAndGetSyncRecordWithType:(SyncType)syncType
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
    lcSyncRecord.syncType = syncType;

    [lcSyncRecord save:&error];
    if (error) return [self.errorHandler returnWithError:error description:[NSString stringWithFormat:@"2. %s", __func__]];

    CDSyncRecord* cdSyncRecord = [CDSyncRecord syncRecordFromLCSyncRecord:lcSyncRecord inContext:_localContext];

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
/**
 *  获取此次同步的同步类型
 *
 *  @param lcSyncRecord 服务器的同步记录
 *  @param cdSyncRecord 本地的同步记录
 *
 *  @return 同步类型
 */
- (SyncType)syncTypeWithLCSyncRecord:(LCSyncRecord*)lcSyncRecord cdSyncRecord:(CDSyncRecord*)cdSyncRecord
{
    /**
	 *	1. 若 lastSyncTimeOnServer = lastSyncTimeOnClient，表明服务器数据没有变化，则仅需要上传本地修改过的数据和新增的数据(send changes)
	 *	2. 若 lastSyncTimeOnServer > lastSyncTimeOnClient，则进行全数据对比，先对比同步所有已有数据，再将其他数据从服务器上下载(full sync)
	 *  3. 若 Server 没有该 Client 的同步记录，则将本地所有数据进行上传，并将服务器上所有的数据进行下载(incremental sync)
	 *  4. 正常情况来说，是不会出现 lastSyncTimeOnServer < lastSyncTimeOnClient 的，这种情况也进行 incremental sync
	 */
    if (!lcSyncRecord)
        return SyncTypeIncrementalSync;

    if ([lcSyncRecord.syncBeginTime compare:cdSyncRecord.syncBeginTime] == NSOrderedSame)
        return SyncTypeSendChanges;
    else if ([lcSyncRecord.syncBeginTime compare:cdSyncRecord.syncBeginTime] == NSOrderedDescending)
        return SyncTypeFullSync;
    else
        return SyncTypeIncrementalSync;
}
@end
