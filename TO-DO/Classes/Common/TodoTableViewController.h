//
//  TodoTableViewController.h
//  TO-DO
//
//  Created by Siegrain on 16/5/31.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "HSDatePickerViewController.h"
#import "MGSwipeTableCell.h"
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TodoTableViewControllerStyle) {
    TodoTableViewControllerStyleHome,
    TodoTableViewControllerStyleCalendar
};

@protocol TodoTableViewControllerDelegate <NSObject>
@optional
/**
 * 在重新加载数据时调用
 */
- (void)todoTableViewControllerDidReloadData;

/**
 * 在更新任务后调用
 */
- (void)todoTableViewControllerDidUpdateTodo;

/**
 * 在滚动时调用
 * @param y
 */
- (void)todoTableViewDidScrollToY:(CGFloat)y;
@end

@class CDTodo;

/**
 *  代办事项列表
 */
@interface TodoTableViewController : UITableViewController <HSDatePickerViewControllerDelegate, MGSwipeTableCellDelegate>
/**
 *  代理
 */
@property(nonatomic, readwrite, weak) id <TodoTableViewControllerDelegate> delegate;
/**
 *  获取到的数据数量
 */
@property(nonatomic, readwrite, assign) NSInteger dataCount;
/*Header高度*/
@property(nonatomic, assign) CGFloat headerHeight;

@property(nonatomic, assign) TodoTableViewControllerStyle style;

+ (instancetype)todoTableViewControllerWithStyle:(TodoTableViewControllerStyle)style;

/**
 *  获取数据
 *
 *  @param user <#user description#>
 *  @param date <#date description#>
 */
- (void)retrieveDataWithUser:(CDUser *)user date:(NSDate *)date;

/**
 * 插入任务
 * @param model
 */
- (void)insertTodo:(CDTodo *)model;
@end
