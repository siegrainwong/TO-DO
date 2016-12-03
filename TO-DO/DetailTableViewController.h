//
// Created by Siegrain on 16/11/21.
// Copyright (c) 2016 com.siegrain. All rights reserved.
//

#import "SGBaseTableViewController.h"

@class CDTodo;

@interface DetailTableViewController : SGBaseTableViewController
- (void)setModel:(CDTodo *)model;

/* 当TableView完成行高计算时调用，返回TableView总高度 */
@property(nonatomic, copy) void (^tableViewDidCalculateHeight)(CGFloat height);
@end