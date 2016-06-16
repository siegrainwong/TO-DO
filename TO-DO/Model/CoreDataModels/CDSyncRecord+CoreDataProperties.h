//
//  CDSyncRecord+CoreDataProperties.h
//  TO-DO
//
//  Created by Siegrain on 16/6/16.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "CDSyncRecord.h"

NS_ASSUME_NONNULL_BEGIN

@interface CDSyncRecord (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *commitCount;
@property (nullable, nonatomic, retain) NSDate *createdAt;
@property (nullable, nonatomic, retain) NSNumber *downloadCount;
@property (nullable, nonatomic, retain) NSNumber *isFinished;
@property (nullable, nonatomic, retain) NSString *objectId;
@property (nullable, nonatomic, retain) NSString *recordMark;
@property (nullable, nonatomic, retain) NSDate *syncBeginTime;
@property (nullable, nonatomic, retain) NSDate *syncEndTime;
@property (nullable, nonatomic, retain) NSNumber *syncType;
@property (nullable, nonatomic, retain) NSDate *updatedAt;
@property (nullable, nonatomic, retain) CDUser *user;

@end

NS_ASSUME_NONNULL_END
