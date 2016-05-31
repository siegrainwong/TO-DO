//
//  HomeDataManager.m
//  TO-DO
//
//  Created by Siegrain on 16/5/24.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "DateUtil.h"
#import "LCTodo.h"
#import "LCUser.h"
#import "Macros.h"
#import "NSDate+Extension.h"
#import "SCLAlertHelper.h"
#import "TodoDataManager.h"

@implementation TodoDataManager
#pragma mark - retrieve
- (void)retrieveDataWithUser:(LCUser*)user date:(NSDate*)date complete:(void (^)(bool succeed, NSDictionary* dataDictionary, NSInteger dataCount))complete
{
    AVQuery* query = [AVQuery queryWithClassName:[LCTodo parseClassName]];
    [query whereKey:@"user" equalTo:user];
    [query whereKey:@"isDeleted" equalTo:@(NO)];
    [query whereKey:@"isCompleted" equalTo:@(NO)];
    if (date) {
        date = [DateUtil dateInYearMonthDay:date];
        [query whereKey:@"deadline" greaterThanOrEqualTo:date];
        [query whereKey:@"deadline" lessThanOrEqualTo:[date dateByAddingTimeInterval:kTimeIntervalDay]];
    }
    [query orderByAscending:@"deadline"];

    ApplicationNetworkIndicatorVisible(YES);
    [query findObjectsInBackgroundWithBlock:^(NSArray<LCTodo*>* objects, NSError* error) {
        if (error) {
            [SCLAlertHelper errorAlertWithContent:error.localizedDescription];
            ApplicationNetworkIndicatorVisible(NO);
            return complete(NO, nil, 0);
        }

        NSInteger dataCount = objects.count;
        NSMutableDictionary* dataDictionary = [NSMutableDictionary new];

        NSMutableArray* dataInSameDay;
        NSString* dateString;
        for (LCTodo* todo in objects) {
            NSString* newDateString = todo.deadline.stringInYearMonthDay;
            if (![dateString isEqualToString:newDateString]) {
                dateString = newDateString;
                dataInSameDay = [NSMutableArray new];
                dataDictionary[dateString] = dataInSameDay;
            }
            [dataInSameDay addObject:todo];
        }
        ApplicationNetworkIndicatorVisible(NO);
        return complete(YES, [dataDictionary copy], dataCount);
    }];
}
#pragma mark - modify
- (void)modifyTodo:(LCTodo*)todo complete:(void (^)(bool succeed))complete
{
    [todo saveInBackgroundWithBlock:^(BOOL succeeded, NSError* error) {
        if (error) {
            [SCLAlertHelper errorAlertWithContent:error.localizedDescription];
            return complete(NO);
        }
        return complete(YES);
    }];
}
@end
