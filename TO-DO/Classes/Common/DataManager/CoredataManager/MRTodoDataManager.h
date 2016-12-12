//
//  MRTodoDataManager.h
//  TO-DO
//
//  Created by Siegrain on 16/6/1.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "CDTodo.h"
#import "Localized.h"

static NSString *const kDataNotCompleteTaskKey = @"Not complete";
static NSString *const kDataCompletedTaskKey = @"Completed";

typedef void (^retrieveResult)(BOOL succeed, NSDictionary *data, NSInteger count);

@interface MRTodoDataManager : NSObject <Localized>
#pragma mark - retrieve
- (void)tasksWithUser:(CDUser *)user status:(NSNumber *)status isComplete:(NSNumber *)isComplete complete:(retrieveResult)complete;

- (void)tasksWithUser:(CDUser *)user date:(NSDate *)date complete:(retrieveResult)complete;

- (BOOL)hasDataWithDate:(NSDate *)date user:(CDUser *)user;

#pragma mark - modify
- (BOOL)modifyTask:(CDTodo *)todo;

- (void)tasksWithUser:(CDUser *)user keyword:(NSString *)keyword status:(NSNumber *)status isComplete:(NSNumber *)isComplete complete:(retrieveResult)complete;

- (BOOL)InsertTask:(CDTodo *)todo;
@end
