//
//  HomeDataManager.h
//  TO-DO
//
//  Created by Siegrain on 16/5/24.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LCUser;
@class LCTodo;

@interface HomeDataManager : UITableViewCell
/**
 *  获取首页数据（默认为昨天~明天的数据）
 *
 *  @param user     当前用户
 *  @param complete 完成
 */
- (void)retrieveDataWithUser:(LCUser*)user complete:(void (^)(bool succeed, NSDictionary* dataDictionary, NSInteger dataCount))complete;
/**
 *  修改待办事项
 *
 *  @param todo     实体
 *  @param complete 完成
 */
- (void)modifyTodo:(LCTodo*)todo complete:(void (^)(bool succeed))complete;
@end
