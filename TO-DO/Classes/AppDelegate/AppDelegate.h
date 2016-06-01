//
//  AppDelegate.h
//  TO-DO
//
//  Created by Siegrain on 16/5/7.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder<UIApplicationDelegate>

@property (strong, nonatomic) UIWindow* window;

+ (AppDelegate*)globalDelegate;

/**
 *  切换根控制器
 */
- (void)switchRootViewController:(UIViewController*)viewController isNavigation:(BOOL)isNavigation;
/**
 *  切换到抽屉视图
 */
- (void)toggleDrawer:(id)sender animated:(BOOL)animated;
/**
 *  切换目标视图
 */
- (void)setCenterViewController:(UIViewController*)viewController;
@end
