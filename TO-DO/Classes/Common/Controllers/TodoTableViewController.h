//
//  TodoTableViewController.h
//  TO-DO
//
//  Created by Siegrain on 16/5/31.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "HSDatePickerViewController.h"
#import "MGSwipeTableCell.h"
#import "SGBaseTableViewController.h"
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TodoTableViewControllerStyle) {
    TodoTableViewControllerStyleHome,
    TodoTableViewControllerStyleCalendar,
    TodoTableViewControllerStyleSearch
};

@protocol TodoTableViewControllerDelegate <SGBaseTableViewControllerDelegate>
@optional
/**
 * 在重新加载数据时调用
 */
- (void)todoTableViewControllerDidReloadData;

/**
 * 在更新任务后调用
 */
- (void)todoTableViewControllerDidUpdateTodo;
@end

@class CDTodo;

/**
 *  代办事项列表
 */
@interface TodoTableViewController : SGBaseTableViewController <HSDatePickerViewControllerDelegate, MGSwipeTableCellDelegate>
/**
 *  代理
 */
@property(nonatomic, weak) id <TodoTableViewControllerDelegate> delegate;
/**
 *  获取到的数据数量
 */
@property(nonatomic, assign) NSInteger dataCount;
/**
 * Header高度
 */
@property(nonatomic, assign) CGFloat headerHeight;
/**
 * 表格样式
 */
@property(nonatomic, assign) TodoTableViewControllerStyle style;
/**
 * 禁用Cell滑动
 */
@property(nonatomic, assign) BOOL disableCellSwiping;

/**
 *  获取数据
 *
 *  @param user <#user description#>
 *  @param date <#date description#>
 */
- (void)retrieveDataWithUser:(CDUser *)user date:(NSDate *)date status:(NSNumber *)status isComplete:(NSNumber *)isComplete keyword:(NSString *)keyword;
@end
