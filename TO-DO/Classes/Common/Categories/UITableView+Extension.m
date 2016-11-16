//
//  UITableView+Extension.m
//  TO-DO
//
//  Created by Siegrain on 16/5/19.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "UITableView+Extension.h"

@implementation UITableView (Extension)
- (void)resizeTableHeaderView
{
    UIView* headerView = self.tableHeaderView;

    if (!headerView) return;

    // Mark: tableHeaderView 不认约束
    CGFloat height = [headerView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    CGRect frame = headerView.frame;
    frame.size.height = height;
    headerView.frame = frame;

    self.tableHeaderView = headerView;
}
@end
