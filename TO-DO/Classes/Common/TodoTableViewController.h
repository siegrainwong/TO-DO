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
    TodoTableViewControllerStyleCellAndSection,
    TodoTableViewControllerStyleWithoutSection
};

@protocol TodoTableViewControllerDelegate<NSObject>
@optional
- (void)todoTableViewControllerDidReloadData;
@end

@class LCTodo;

@interface TodoTableViewController : UITableViewController<HSDatePickerViewControllerDelegate, MGSwipeTableCellDelegate>
@property (nonatomic, readwrite, weak) id<TodoTableViewControllerDelegate> delegate;
@property (nonatomic, readwrite, assign) NSInteger dataCount;

+ (instancetype)todoTableViewControllerWithStyle:(TodoTableViewControllerStyle)style;

- (void)retrieveDataWithUser:(LCUser*)user date:(NSDate*)date;
- (void)insertTodo:(LCTodo*)model;
@end
