//
//  TodoTableViewCell.h
//  TO-DO
//
//  Created by Siegrain on 16/5/23.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "MGSwipeTableCell.h"
#import <UIKit/UIKit.h>

static CGFloat const kCellHorizontalInsetsMuiltipledByHeight = 0.034;
static CGFloat const kCellVerticalInsetsMuiltipledByHeight = 0.04;

typedef NS_ENUM(NSInteger, TodoIdentifier) {
    TodoIdentifierNormal,
    TodoIdentifierTimeline
};
#define kTodoIdentifierArray (@[ @"Normal", @"Timeline" ])

@class CDTodo;

/**
 *  待办事项Cell
 */
@interface TodoTableViewCell : MGSwipeTableCell
@property (nonatomic, readwrite, strong) CDTodo* model;

@property (nonatomic, readwrite, copy) BOOL (^todoDidComplete)(TodoTableViewCell* cell);
@property (nonatomic, readwrite, copy) BOOL (^todoDidSnooze)(TodoTableViewCell* cell);
@property (nonatomic, readwrite, copy) BOOL (^todoDidRemove)(TodoTableViewCell* cell);

@end
