//
//  TodoTableViewController.h
//  TO-DO
//
//  Created by Siegrain on 16/5/31.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "SGBaseViewController.h"
#import "UIViewController+ESSeparatorInset.h"
#import <SDAutoLayout/UITableView+SDAutoTableViewCellHeight.h>
#import "AppDelegate.h"

@protocol SGBaseTableViewControllerDelegate <NSObject>
/**
 * 在滚动时调用
 * @param y
 */
- (void)tableViewDidScrollToY:(CGFloat)y;
@end

@interface SGBaseTableViewController : UITableViewController<SGTableViews>
@property(nonatomic, weak) id <SGBaseTableViewControllerDelegate> delegate;
@end