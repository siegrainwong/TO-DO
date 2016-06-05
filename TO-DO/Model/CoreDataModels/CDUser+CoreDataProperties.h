//
//  CDUser+CoreDataProperties.h
//  TO-DO
//
//  Created by Siegrain on 16/6/4.
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
@property (nullable, nonatomic, retain) NSString *email;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *username;
@property (nullable, nonatomic, retain) NSString *phoneIdentifier;
@property (nullable, nonatomic, retain) NSString *objectId;
@property (nullable, nonatomic, retain) NSDate *createdAt;
@property (nullable, nonatomic, retain) NSDate *updatedAt;
@property (nullable, nonatomic, retain) NSOrderedSet<CDSyncRecord *> *syncRecords;
@property (nullable, nonatomic, retain) NSOrderedSet<CDTodo *> *todos;

@end

@interface CDUser (CoreDataGeneratedAccessors)

- (void)insertObject:(CDSyncRecord *)value inSyncRecordsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromSyncRecordsAtIndex:(NSUInteger)idx;
- (void)insertSyncRecords:(NSArray<CDSyncRecord *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeSyncRecordsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInSyncRecordsAtIndex:(NSUInteger)idx withObject:(CDSyncRecord *)value;
- (void)replaceSyncRecordsAtIndexes:(NSIndexSet *)indexes withSyncRecords:(NSArray<CDSyncRecord *> *)values;
- (void)addSyncRecordsObject:(CDSyncRecord *)value;
- (void)removeSyncRecordsObject:(CDSyncRecord *)value;
- (void)addSyncRecords:(NSOrderedSet<CDSyncRecord *> *)values;
- (void)removeSyncRecords:(NSOrderedSet<CDSyncRecord *> *)values;

- (void)insertObject:(CDTodo *)value inTodosAtIndex:(NSUInteger)idx;
- (void)removeObjectFromTodosAtIndex:(NSUInteger)idx;
- (void)insertTodos:(NSArray<CDTodo *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeTodosAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInTodosAtIndex:(NSUInteger)idx withObject:(CDTodo *)value;
- (void)replaceTodosAtIndexes:(NSIndexSet *)indexes withTodos:(NSArray<CDTodo *> *)values;
- (void)addTodosObject:(CDTodo *)value;
- (void)removeTodosObject:(CDTodo *)value;
- (void)addTodos:(NSOrderedSet<CDTodo *> *)values;
- (void)removeTodos:(NSOrderedSet<CDTodo *> *)values;

@end

NS_ASSUME_NONNULL_END
