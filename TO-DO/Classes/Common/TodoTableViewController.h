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
    /**
	 *  显示Cell和Section，首页用
	 */
    TodoTableViewControllerStyleCellAndSection,
    /**
	 *  隐藏Section，日历界面用
	 */
    TodoTableViewControllerStyleWithoutSection
};

@protocol TodoTableViewControllerDelegate<NSObject>
@optional
- (void)todoTableViewControllerDidReloadData;
@end

@class CDTodo;

/**
 *  代办事项列表
 */
@interface TodoTableViewController : UITableViewController<HSDatePickerViewControllerDelegate, MGSwipeTableCellDelegate>
/**
 *  代理
 */
@property (nonatomic, readwrite, weak) id<TodoTableViewControllerDelegate> delegate;
/**
 *  获取到的数据数量
 */
@property (nonatomic, readwrite, assign) NSInteger dataCount;
/**
 *  定时器，暴露出来只是为了方便释放
 */
@property (nonatomic, readwrite, strong) NSTimer* timer;

+ (instancetype)todoTableViewControllerWithStyle:(TodoTableViewControllerStyle)style;

/**
 *  获取数据
 *
 *  @param user <#user description#>
 *  @param date <#date description#>
 */
- (void)retrieveDataWithUser:(CDUser*)user date:(NSDate*)date;
- (void)insertTodo:(CDTodo*)model;
@end
