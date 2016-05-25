//
//  HomeDataManager.m
//  TO-DO
//
//  Created by Siegrain on 16/5/24.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "DateUtil.h"
#import "HomeDataManager.h"
#import "LCTodo.h"
#import "LCUser.h"
#import "NSDate+Extension.h"
#import "SCLAlertHelper.h"

@implementation HomeDataManager
- (void)retrieveDataWithUser:(LCUser*)user complete:(void (^)(bool succeed, NSDictionary* dataDictionary, NSArray* dateArray, NSInteger dataCount))complete
{
    AVQuery* query = [AVQuery queryWithClassName:[LCTodo parseClassName]];
    [query whereKey:@"user" equalTo:user];
    [query whereKey:@"status" containedIn:@[ @(LCTodoStatusNotComplete), @(LCTodoStatusOverdue) ]];
    NSDate* today = [DateUtil dateInYearMonthDay:[NSDate date]];
    NSDate* yesterday = [today dateByAddingTimeInterval:-kTimeIntervalDay];
    // FIXME: 明明条件是大于昨天的时间，为什么会检索出12号的数据？
    [query whereKey:@"deadline" greaterThanOrEqualTo:yesterday];
    [query whereKey:@"deadline" lessThanOrEqualTo:[DateUtil dateInYearMonthDay:[today dateByAddingTimeInterval:kTimeIntervalDay * 1]]];
    [query orderByAscending:@"deadline"];
    [query findObjectsInBackgroundWithBlock:^(NSArray<LCTodo*>* objects, NSError* error) {
        if (error) {
            [SCLAlertHelper errorAlertWithContent:error.localizedDescription];
            return complete(NO, nil, nil, 0);
        }

        NSInteger dataCount = objects.count;
        NSMutableDictionary* dataDictionary = [NSMutableDictionary new];
        NSMutableArray* dateArray = [NSMutableArray new];

        NSMutableArray* dataInSameDay;
        NSString* dateString;
        for (LCTodo* todo in objects) {
            NSString* newDateString = todo.deadline.stringInYearMonthDay;
            if (![dateString isEqualToString:newDateString]) {
                dateString = newDateString;
                [dateArray addObject:dateString];
                dataInSameDay = [NSMutableArray new];
                dataDictionary[dateString] = dataInSameDay;
            }
            [dataInSameDay addObject:todo];
        }

        return complete(YES, [dataDictionary copy], [dateArray copy], dataCount);
    }];
}
@end
