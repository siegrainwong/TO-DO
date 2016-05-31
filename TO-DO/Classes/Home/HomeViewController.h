//
//  HomeViewController.h
//  TO-DO
//
//  Created by Siegrain on 16/5/13.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "BaseViewController.h"
#import "Localized.h"
#import "TodoTableViewController.h"

/**
 *  首页
 */
@interface HomeViewController : BaseViewController<Localized, TodoTableViewControllerDelegate>
@end
