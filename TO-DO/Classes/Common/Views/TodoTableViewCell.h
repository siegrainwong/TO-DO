//
//  TodoTableViewCell.h
//  TO-DO
//
//  Created by Siegrain on 16/5/23.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "MGSwipeTableCell.h"
#import <UIKit/UIKit.h>

static CGFloat const kCellHorizontalInsetsRatioByScreenHeight = 0.034;
static CGFloat const kCellVerticalInsetsRatioByScreenHeight = 0.04;

typedef NS_ENUM(NSInteger, TodoIdentifier) {
    TodoIdentifierNormal,
    TodoIdentifierTimeline
};

typedef NS_ENUM(NSInteger, TodoSwipeOperation) {
    TodoSwipeOperationComplete,
    TodoSwipeOperationSnooze,
    TodoSwipeOperationRemove,
    TodoSwipeOperationRevert,
};

#define kTodoIdentifierArray (@[ @"Normal", @"Timeline" ])

@class CDTodo;
@class TodoTableViewCell;

typedef BOOL (^todoSwipedBlock)(TodoTableViewCell *sender, TodoSwipeOperation operation);

/**
 *  待办事项Cell
 */
@interface TodoTableViewCell : MGSwipeTableCell
@property(nonatomic, strong) CDTodo *model;

@property(nonatomic, copy) todoSwipedBlock todoDidSwipe;

@end