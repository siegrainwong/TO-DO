//
//  User+CoreDataProperties.h
//  TO-DO
//
//  Created by Siegrain on 16/6/1.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "User.h"

NS_ASSUME_NONNULL_BEGIN

@interface User (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *email;
@property (nullable, nonatomic, retain) NSString *username;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *avatar;
@property (nullable, nonatomic, retain) NSString *objectId;
@property (nonatomic) int16_t syncStatus;
@property (nonatomic) NSTimeInterval createAt;
@property (nonatomic) int64_t syncVersion;
@property (nullable, nonatomic, retain) NSData *avatarImage;
@property (nullable, nonatomic, retain) NSString *password;
@property (nullable, nonatomic, retain) NSSet<Todo *> *todos;

@end

@interface User (CoreDataGeneratedAccessors)

- (void)addTodosObject:(Todo *)value;
- (void)removeTodosObject:(Todo *)value;
- (void)addTodos:(NSSet<Todo *> *)values;
- (void)removeTodos:(NSSet<Todo *> *)values;

@end

NS_ASSUME_NONNULL_END
