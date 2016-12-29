//
//  CDSyncRecord.h
//  TO-DO
//
//  Created by Siegrain on 16/6/4.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CDUser;
@class LCSyncRecord;

NS_ASSUME_NONNULL_BEGIN

@interface CDSyncRecord : NSManagedObject
/**
 *  将LCSyncRecord实体转换为CDSyncRecord实体
 */
+ (instancetype)syncRecordFromLCSyncRecord:(LCSyncRecord*)lcSyncRecord inContext:(NSManagedObjectContext*)context;
@end

NS_ASSUME_NONNULL_END

#import "CDSyncRecord+CoreDataProperties.h"
