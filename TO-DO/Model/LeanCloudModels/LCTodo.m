//
//  SGTodo.m
//  TO-DO
//
//  Created by Siegrain on 16/5/21.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "CDTodo.h"
#import "LCTodo.h"

@implementation LCTodo
@dynamic title;
@dynamic sgDescription;
@dynamic deadline;
@dynamic location;
@dynamic user;
@dynamic status;
@dynamic isHidden;
@dynamic isCompleted;
@dynamic photo;
@dynamic syncVersion;
@dynamic localCreatedAt;
@dynamic localUpdatedAt;

+ (LCTodo*)lcTodoWithCDTodo:(CDTodo*)cdTodo
{
    LCTodo* lcTodo = [LCTodo object];
    lcTodo.title = cdTodo.title;
    lcTodo.sgDescription = cdTodo.sgDescription;
    lcTodo.deadline = cdTodo.deadline;
    lcTodo.location = cdTodo.location;
    lcTodo.user = [LCUser currentUser];
    lcTodo.status = [cdTodo.status integerValue];
    lcTodo.isHidden = [cdTodo.isHidden boolValue];
    lcTodo.isCompleted = [cdTodo.isCompleted boolValue];
    lcTodo.photo = cdTodo.photo;
    lcTodo.syncVersion = [cdTodo.syncVersion integerValue];
    lcTodo.localUpdatedAt = cdTodo.updatedAt;
    lcTodo.localCreatedAt = cdTodo.createdAt;

    return lcTodo;
}
+ (NSArray<LCTodo*>*)lcTodoArrayWithCDTodoArray:(NSArray<CDTodo*>*)cdArray
{
    __weak typeof(self) weakSelf = self;
    __block NSMutableArray<LCTodo*>* lcArray = [NSMutableArray new];
    [cdArray enumerateObjectsUsingBlock:^(CDTodo* cdTodo, NSUInteger idx, BOOL* stop) {
        [lcArray addObject:[weakSelf lcTodoWithCDTodo:cdTodo]];
    }];

    return lcArray;
}
+ (NSString*)parseClassName
{
    return @"Todo";
}
@end
