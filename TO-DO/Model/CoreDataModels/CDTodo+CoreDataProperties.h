//
//  CDTodo+CoreDataProperties.h
//  TO-DO
//
//  Created by Siegrain on 16/6/2.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "CDTodo.h"

NS_ASSUME_NONNULL_BEGIN

@interface CDTodo (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *cellHeight;
@property (nullable, nonatomic, retain) NSDate *createAt;
@property (nullable, nonatomic, retain) NSDate *deadline;
@property (nullable, nonatomic, retain) NSNumber *isCompleted;
@property (nullable, nonatomic, retain) NSNumber *isHidden;
@property (nullable, nonatomic, retain) NSNumber *isReordering;
@property (nullable, nonatomic, retain) NSDate *lastDeadline;
@property (nullable, nonatomic, retain) NSString *location;
@property (nullable, nonatomic, retain) NSString *objectId;
@property (nullable, nonatomic, retain) NSString *photo;
@property (nullable, nonatomic, retain) NSData *photoData;
@property (nullable, nonatomic, retain) NSString *sgDescription;
@property (nullable, nonatomic, retain) NSNumber *status;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) CDUser *user;

@end

NS_ASSUME_NONNULL_END
