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

@implementation HomeDataManager
- (void)retrieveDataWithUser:(LCUser*)user complete:(void (^)(bool succeed, NSDictionary* data))complete
{
    AVQuery* query = [AVQuery queryWithClassName:[LCTodo parseClassName]];
    [query whereKey:@"user" equalTo:user];
    [query whereKey:@"status" equalTo:@(LCTodoStatusNotComplete)];
    [query whereKey:@"status" equalTo:@(LCTodoStatusOverdue)];
    [query whereKey:@"deadline" greaterThanOrEqualTo:[DateUtil dateString:[NSDate date] withFormat:@"yyyy-MM-dd"]];
    [query whereKey:@"deadline" lessThanOrEqualTo:[DateUtil dateString:[[NSDate date] dateByAddingTimeInterval:60 * 60 * 7] withFormat:@"yyyy-MM-dd"]];
    [query orderByDescending:@"deadline"];
    [query findObjectsInBackgroundWithBlock:^(NSArray* objects, NSError* error) {
        if (!error) {
            NSLog(@"%@", objects);
        } else {
            // 输出错误信息
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}
@end
