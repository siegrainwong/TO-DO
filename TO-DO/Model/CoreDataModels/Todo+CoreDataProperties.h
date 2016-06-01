//
//  Todo+CoreDataProperties.h
//  TO-DO
//
//  Created by Siegrain on 16/6/1.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Todo.h"

NS_ASSUME_NONNULL_BEGIN

@interface Todo (CoreDataProperties)

@property (nonatomic) int16_t status;
@property (nullable, nonatomic, retain) NSString *title;
@property (nonatomic) NSTimeInterval deadline;
@property (nullable, nonatomic, retain) NSString *sgDescription;
@property (nonatomic) BOOL isCompleted;
@property (nonatomic) BOOL isHidden;
@property (nullable, nonatomic, retain) NSString *photo;
@property (nullable, nonatomic, retain) NSString *location;
@property (nonatomic) NSTimeInterval createAt;
@property (nullable, nonatomic, retain) NSString *objectId;
@property (nullable, nonatomic, retain) NSData *photoImage;
@property (nonatomic) float cellHeight;
@property (nonatomic) NSTimeInterval lastDeadline;
@property (nonatomic) BOOL isReordering;
@property (nonatomic) int16_t syncStatus;
@property (nonatomic) int64_t syncVersion;
@property (nullable, nonatomic, retain) NSManagedObject *user;

@end

NS_ASSUME_NONNULL_END
