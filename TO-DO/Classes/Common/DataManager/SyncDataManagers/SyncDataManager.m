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

static NSString* const kGetServerDateApiUrl = @"https://api.leancloud.cn/1.1/date";

static NSInteger const kFetchLimitPerQueue = 50;
static NSInteger const kInvalidTimeInterval = 10;

@interface
SyncDataManager ()
@property (nonatomic, readwrite, strong) CDUser* cdUser;
@property (nonatomic, readwrite, strong) LCUser* lcUser;

@property (nonatomic, readwrite, assign) BOOL isSyncing;
@end

@implementation SyncDataManager
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
        dataManager = [[SyncDataManager alloc] init];
        dataManager.lcUser = [LCUser currentUser];
        dataManager.cdUser = [CDUser userWithLCUser:dataManager.lcUser];
        dataManager.isSyncing = NO;
    });
    return dataManager;
}
#pragma mark - synchronization
- (void)synchronize:(void (^)(bool succeed))complete;
{
    //    if (_isSyncing) return complete(YES);
    //    _isSyncing = YES;
    /*
	 同步方式：
	 每次同步最新的五十条数据
	 1. 若 Server 没有该 Client(需要手机的唯一识别码进行辨认) 的同步记录，则将本地所有数据进行上传，并将服务器上所有的数据进行下载
	 2. 若 lastSyncTimeOnServer = lastSyncTimeOnClient，表明服务器数据没有变化，则仅需要上传本地修改过的数据和新增的数据	
	 3. 若 lastSyncTimeOnServer > lastSyncTimeOnClient，则进行全数据对比，先对比同步所有已有数据，再将其他数据从服务器上下载
	 
	 注意事项：
	 1. 所有同步时间戳均以服务器时间为准，每次同步之前先获取服务器的时间戳
	 2. 若本地时间与服务器时间相差1分钟以上，提醒并不予同步
	 3. 对比同步规则：1.大版本同步小版本 2.版本相同的话，以线上数据为准进行覆盖（另一种做法是建立冲突副本，根据本项目的实际情况不采用这种方式）
	 */
    __weak typeof(self) weakSelf = self;
    GCDQueue* queue = [GCDQueue globalQueueWithLevel:DISPATCH_QUEUE_PRIORITY_DEFAULT];
    [queue async:^{
        LCSyncRecord* lastSyncRecord = nil;
        CDSyncRecord* syncRecord = nil;
        if (![self prepareToSynchornize:&lastSyncRecord cdSyncRecord:&syncRecord])
            return [weakSelf returnBlock:complete];

        //2-1. 记录为空，下载所有服务器数据，上传所有本地数据
        if (!lastSyncRecord) {
            NSArray<CDTodo*>* todosNeedsToUpload = [weakSelf fetchTodoHasSynchronized:NO lastRecordIsUpdateAt:[NSDate date]];
            NSArray<LCTodo*>* todosNeedsToDownload = [weakSelf retrieveTodos];

            dispatch_group_t group = dispatch_group_create();
            //2-1-1. 上传数据
            [queue asyncWithGroup:group block:^{
                for (CDTodo* todo in todosNeedsToUpload) {
                    //2-1-1-1. 转换为LeanCloud对象，并上传
                    LCTodo* lcTodo = [LCTodo lcTodoWithCDTodo:todo];
                    NSError* error = nil;
                    [lcTodo save:&error];
                    if (error) {
                        DDLogError(@"2-1-1-2：%@", error.localizedDescription);
                        continue;
                    }
                    //2-1-1-2. 上传完成，修改本地数据状态为同步完成，同时赋予唯一编号
                    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext* localContext) {
                        CDTodo* localContextTodo = [todo MR_inContext:localContext];
                        localContextTodo.syncStatus = @(SyncStatusSynchronized);
                        localContextTodo.objectId = lcTodo.objectId;
                    }];
                }
            }];
            //2-1-2. 下载数据
            [queue asyncWithGroup:group block:^{
                for (LCTodo* todo in todosNeedsToDownload) {
                    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext* localContext) {
                        CDTodo* cdTodo = [[CDTodo cdTodoWithLCTodo:todo] MR_inContext:localContext];
                        cdTodo.syncStatus = @(SyncStatusSynchronized);
                    }];
                }
            }];
            [queue asyncGroupNotify:group block:^{
                DDLogInfo(@"all fucking done");
                [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext* localContext) {
                    CDSyncRecord* localContextSyncRecord = [syncRecord MR_inContext:localContext];
                    localContextSyncRecord.isFinished = @(YES);
                    localContextSyncRecord.syncEndTime = [NSDate date];
                }];

                [[GCDQueue mainQueue] sync:^{
                    return complete(YES);
                }];
            }];
        }
    }];
}
- (BOOL)prepareToSynchornize:(LCSyncRecord**)lastSyncRecord cdSyncRecord:(CDSyncRecord**)cdSyncRecord
{
    //1. 获取服务器上最新的同步记录
    *lastSyncRecord = [self retriveLatestSyncRecord];

    //2. 在本地和线上插入同步记录，准备开始同步
    *cdSyncRecord = [self insertAndGetSyncRecord];
    if (!*cdSyncRecord) return NO;

    return YES;
}
#pragma mark - LeanCloud methods
#pragma mark - retrieve sync record
/**
 *  根据本机唯一标识获取服务器上的最新一条同步记录
 */
- (LCSyncRecord*)retriveLatestSyncRecord
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
        DDLogError(@"1. %s", __func__);
        return nil;
    }

    return record;
}
#pragma mark - retrieve todo
- (NSArray<LCTodo*>*)retrieveTodos
{
    AVQuery* query = [AVQuery queryWithClassName:[LCTodo parseClassName]];
    [query whereKey:@"isHidden" equalTo:@(NO)];
    [query whereKey:@"user" equalTo:_lcUser];
    [query setLimit:kFetchLimitPerQueue];

    NSError* error = nil;
    NSArray<LCTodo*>* array = [query findObjects:&error];
    if (error && error.code != 101) {  //101意思是没有这个表
        [SCLAlertHelper errorAlertWithContent:error.localizedDescription];
        DDLogError(@"2-1. %s", __func__);
        return nil;
    }

    return array;
}
#pragma mark - MagicRecord methods
#pragma mark - retrieve data that needs to sync
- (NSArray<CDTodo*>*)fetchTodoHasSynchronized:(BOOL)synchronized lastRecordIsUpdateAt:(NSDate*)updateAt
{
    NSMutableArray* arguments = [NSMutableArray new];
    NSString* predicateFormat = @"user = %@ and syncStatus != %@ and updatedAt <= %@";
    [arguments addObjectsFromArray:@[ _cdUser, @(SyncStatusSynchronized), updateAt ]];
    if (synchronized)
        predicateFormat = [predicateFormat stringByAppendingString:@" and objectId != nil"];
    else
        predicateFormat = [predicateFormat stringByAppendingString:@" and objectId = nil"];

    NSPredicate* filter = [NSPredicate predicateWithFormat:predicateFormat argumentArray:[arguments copy]];
    NSFetchRequest* request = [CDTodo MR_requestAllWithPredicate:filter];
    [request setFetchLimit:kFetchLimitPerQueue];
    request.sortDescriptors = @[ [[NSSortDescriptor alloc] initWithKey:@"updatedAt" ascending:NO] ];
    NSArray<CDTodo*>* data = [CDTodo MR_executeFetchRequest:request];

    return data;
}
#pragma mark - both MagicRecord and LeanCloud methods
#pragma mark - insert sync record
- (CDSyncRecord*)insertAndGetSyncRecord
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

    [lcSyncRecord save:&error];
    if (error) {
        DDLogError(@"2. %s ::: %@", __func__, error.localizedDescription);
        return nil;
    }

    __block CDSyncRecord* cdSyncRecord = nil;
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext* localContext) {
        // Mark: 在其他线程中创建的实体，在初始化时就要传入当前线程的上下文对象，不然存不进去。
        cdSyncRecord = [CDSyncRecord syncRecordFromLCSyncRecord:lcSyncRecord inContext:localContext];
    }];

    return cdSyncRecord;
}
#pragma mark - helper
- (void)returnBlock:(void (^)(bool succeed))complete
{
    [[GCDQueue mainQueue] sync:^{
        return complete(NO);
    }];
}
- (NSDate*)serverDate
{
    NSDictionary* parameters = [NSDictionary dictionaryWithObjects:@[ kLeanCloudAppID, kLeanCloudAppKey ] forKeys:@[ @"X-LC-Id", @"X-LC-Key" ]];
    AFHTTPRequestOperationManager* manager = [AFHTTPRequestOperationManager manager];
    NSError* error = nil;
    NSDictionary* responseObject = [manager syncGET:kGetServerDateApiUrl parameters:parameters operation:nil error:&error];
    if (error) {
        DDLogError(@"2. 获取服务器时间出错：%@", error.localizedDescription);
        return nil;
    }

    NSDate* serverDate = [DateUtil dateFromISO8601String:responseObject[@"iso"]];
    NSInteger intervalFromServer = fabs([serverDate timeIntervalSince1970] - [[NSDate date] timeIntervalSince1970]);
    if (intervalFromServer > kInvalidTimeInterval) {
        DDLogError(@"2. 本地时间和服务器时间相差过大，禁止同步");
        [SCLAlertHelper errorAlertWithContent:@"手机时间和正常时间相差过大，请调整时间后再试。"];
        return nil;
    }

    return serverDate;
}
@end
