//
//  CDUser+CoreDataProperties.h
//  TO-DO
//
//  Created by Siegrain on 16/6/2.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "CDUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface CDUser (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *avatar;
@property (nullable, nonatomic, retain) NSData *avatarData;
@property (nullable, nonatomic, retain) NSDate *createAt;
@property (nullable, nonatomic, retain) NSString *email;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *objectId;
@property (nullable, nonatomic, retain) NSString *username;
@property (nullable, nonatomic, retain) NSSet<CDTodo *> *todos;

@end

@interface CDUser (CoreDataGeneratedAccessors)

- (void)addTodosObject:(CDTodo *)value;
- (void)removeTodosObject:(CDTodo *)value;
- (void)addTodos:(NSSet<CDTodo *> *)values;
- (void)removeTodos:(NSSet<CDTodo *> *)values;

@end

NS_ASSUME_NONNULL_END
