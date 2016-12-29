//
//  AppDelegate.h
//  TO-DO
//
//  Created by Siegrain on 16/5/7.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "CDUser.h"
#import "JVFloatingDrawerViewController.h"
#import "LCUser.h"
#import "RealReachability.h"
#import "SGSyncManager.h"
#import <CoreData/CoreData.h>
#import "LocalConnection.h"
#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property(strong, nonatomic) UIWindow *window;

@property(nonatomic, readonly, strong) LCUser *lcUser;
@property(nonatomic, readonly, strong) CDUser *cdUser;

@property(nonatomic, readonly, strong) JVFloatingDrawerViewController *drawerViewController;
@property(nonatomic, readonly, strong) RealReachability *reachability;

/* 全局访问器 */
+ (AppDelegate *)globalDelegate;

/* 首页Key */
+ (NSString *)homeViewControllerKey;

/* 沙盒目录 */
- (NSString *)sandboxUrl;

/**
 * 同步入口
 * @param syncType 同步类型
 * @param isForcing 忽略用户设置强制同步
 */
- (void)synchronize:(SyncMode)syncType isForcing:(BOOL)isForcing;

/**
 *  切换根控制器
 */
- (void)switchRootViewController:(UIViewController *)viewController isNavigation:(BOOL)isNavigation key:(NSString *)key;

/**
 *  切换到抽屉视图
 */
- (void)toggleDrawer:(id)sender animated:(BOOL)animated;

/**
 *  切换Drawer的目标视图
 */
- (void)setCenterViewController:(UIViewController *)viewController key:(NSString *)key;

/**
 *  登录后调用该方法配置用户
 */
- (void)setupUser;

/**
 * 注销入口
 */
- (void)logOut;

- (void)clearStateHolder;

/**
 * 登录入口
 */
- (void)logIn;
@end
