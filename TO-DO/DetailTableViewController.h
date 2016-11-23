//
// Created by Siegrain on 16/11/21.
// Copyright (c) 2016 com.siegrain. All rights reserved.
//

#import "SGViews.h"

@class CDTodo;

@interface DetailTableViewController : UITableViewController<SGViews>
- (void)setModel:(CDTodo *)model;
@end