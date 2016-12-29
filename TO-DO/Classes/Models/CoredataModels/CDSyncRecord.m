//
//  CDSyncRecord.m
//  TO-DO
//
//  Created by Siegrain on 16/6/4.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "CDSyncRecord.h"
#import "CDUser.h"
#import "LCSyncRecord.h"

@implementation CDSyncRecord
#pragma mark - convert
+ (instancetype)syncRecordFromLCSyncRecord:(LCSyncRecord*)lcSyncRecord inContext:(NSManagedObjectContext*)context
{
    CDSyncRecord* syncRecord = [CDSyncRecord MR_createEntityInContext:context];
    syncRecord.objectId = lcSyncRecord.objectId;
    syncRecord.isFinished = @(lcSyncRecord.isFinished);
    syncRecord.user = [CDUser userWithLCUser:lcSyncRecord.user inContext:context];
    syncRecord.syncBeginTime = lcSyncRecord.syncBeginTime;
    syncRecord.syncEndTime = lcSyncRecord.syncEndTime;
    syncRecord.createdAt = lcSyncRecord.createdAt;
    syncRecord.updatedAt = lcSyncRecord.updatedAt ? lcSyncRecord.updatedAt : syncRecord.createdAt;
    syncRecord.syncType = @(lcSyncRecord.syncType);
    syncRecord.recordMark = lcSyncRecord.recordMark;

    return syncRecord;
}

#pragma mark - MagicRecord
+ (NSString*)MR_entityName
{
    return @"SyncRecord";
}
@end
