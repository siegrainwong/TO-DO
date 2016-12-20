//
//  CDUser+CoreDataProperties.h
//  TO-DO
//
//  Created by Siegrain on 16/12/20.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "CDUser.h"


NS_ASSUME_NONNULL_BEGIN

@interface CDUser (CoreDataProperties)

+ (NSFetchRequest<CDUser *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *avatar;
@property (nullable, nonatomic, retain) NSData *avatarData;
@property (nullable, nonatomic, copy) NSDate *createdAt;
@property (nullable, nonatomic, copy) NSString *email;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *objectId;
@property (nullable, nonatomic, copy) NSString *phoneIdentifier;
@property (nullable, nonatomic, copy) NSDate *updatedAt;
@property (nullable, nonatomic, copy) NSString *username;
@property (nullable, nonatomic, copy) NSNumber *enableAutoSync;
@property (nullable, nonatomic, copy) NSNumber *enableAutoReminder;
@property (nullable, nonatomic, copy) NSDate *lastSyncTime;
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
