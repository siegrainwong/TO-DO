//
//  HomeDataManager.h
//  TO-DO
//
//  Created by Siegrain on 16/5/24.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "Localized.h"
#import <UIKit/UIKit.h>

@class LCUser;
@class LCTodo;

@interface LCTodoDataManager : NSObject<Localized>
/**
 *  获取待办事项
 *
 *  @param user     当前用户
 *  @param date     日期
 *  @param complete 完成
 */
- (void)retrieveDataWithUser:(LCUser*)user date:(NSDate*)date complete:(void (^)(bool succeed, NSDictionary* dataDictionary, NSInteger dataCount))complete;
/**
 *  修改待办事项
 *
 *  @param todo     实体
 *  @param complete 完成
 */
- (void)modifyTodo:(LCTodo*)todo complete:(void (^)(bool succeed))complete;
/**
 *  添加待办事项
 *
 *  @param todo     实体
 *  @param complete 完成
 */
- (void)insertTodo:(LCTodo*)todo complete:(void (^)(bool succeed))complete;
@end
