//
//  CDTodo+CoreDataProperties.h
//  TO-DO
//
//  Created by Siegrain on 16/11/18.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "CDTodo.h"


NS_ASSUME_NONNULL_BEGIN

@interface CDTodo (CoreDataProperties)

+ (NSFetchRequest<CDTodo *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSDate *createdAt;
@property (nullable, nonatomic, copy) NSDate *deadline;
@property (nullable, nonatomic, copy) NSString *explicitAddress;
@property (nullable, nonatomic, copy) NSString *generalAddress;
@property (nullable, nonatomic, copy) NSString *identifier;
@property (nullable, nonatomic, copy) NSNumber *isCompleted;
@property (nullable, nonatomic, copy) NSNumber *isHidden;
@property (nullable, nonatomic, copy) NSNumber *latitude;
@property (nullable, nonatomic, copy) NSNumber *longitude;
@property (nullable, nonatomic, copy) NSString *objectId;
@property (nullable, nonatomic, copy) NSString *photoPath;
@property (nullable, nonatomic, copy) NSString *photoUrl;
@property (nullable, nonatomic, copy) NSString *sgDescription;
@property (nullable, nonatomic, copy) NSNumber *status;
@property (nullable, nonatomic, copy) NSNumber *syncStatus;
@property (nullable, nonatomic, copy) NSNumber *syncVersion;
@property (nullable, nonatomic, copy) NSString *title;
@property (nullable, nonatomic, copy) NSDate *updatedAt;
@property (nullable, nonatomic, copy) NSDate *completedAt;
@property (nullable, nonatomic, copy) NSDate *deletedAt;
@property (nullable, nonatomic, retain) CDUser *user;

@end

NS_ASSUME_NONNULL_END
