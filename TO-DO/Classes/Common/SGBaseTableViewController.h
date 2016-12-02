//
//  SGFilterTableViewController.h
//  GamePlatform
//
//  Created by Siegrain on 16/8/19.
//  Copyright © 2016年 com.lurenwang.gameplatform. All rights reserved.
//

#import "SGBaseViewController.h"
#import "UIViewController+ESSeparatorInset.h"

@interface SGBaseTableViewController : SGBaseViewController<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, readonly, strong) UITableView* tableView;
@end