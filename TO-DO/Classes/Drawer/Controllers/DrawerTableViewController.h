//
//  JVLeftDrawerTableViewController.h
//  JVFloatingDrawer
//
//  Created by Julian Villella on 2015-01-15.
//  Copyright (c) 2015 JVillella. All rights reserved.
//

#import "Localized.h"
#import <UIKit/UIKit.h>

@interface DrawerTableViewController : UITableViewController<Localized>
/**
 * 指示是否正在同步
 */
@property(nonatomic, assign) BOOL isSyncing;
@end
