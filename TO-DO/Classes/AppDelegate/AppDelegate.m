//
//  AppDelegate.m
//  TO-DO
//
//  Created by Siegrain on 16/5/7.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "AppDelegate.h"
#import "CDTodo.h"
#import "CocoaLumberjack.h"
#import "DataKeys.h"
#import "DrawerTableViewController.h"
#import "HomeViewController.h"
#import "JTNavigationController.h"
#import "JVFloatingDrawerSpringAnimator.h"
#import "JVFloatingDrawerView.h"
#import "LCTodo.h"
#import "LCUser.h"
#import "LoginViewController.h"
#import "Macros.h"
#import "UIImage+Extension.h"
#import <AVOSCloud.h>

// FIXME: 每次进入一个新的ViewController，都会在AF库中的SecPolicy对象上发生几百b的内存泄漏，暂时无法解决

@interface
AppDelegate ()
@property (nonatomic, readwrite, strong) JVFloatingDrawerViewController* drawerViewController;
@end

@implementation AppDelegate
#pragma mark - application delegate
- (BOOL)application:(UIApplication*)application
  didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    [self setup];

    return YES;
}
- (void)applicationWillResignActive:(UIApplication*)application
{
}

- (void)applicationDidEnterBackground:(UIApplication*)application
{
}

- (void)applicationWillEnterForeground:(UIApplication*)application
{
}

- (void)applicationDidBecomeActive:(UIApplication*)application
{
}

- (void)applicationWillTerminate:(UIApplication*)application
{
    [MagicalRecord cleanUp];
}
#pragma mark - initial
- (void)setup
{
    [self setupLeanCloud];
    [self setupDrawerViewController];
    [self setupDDLog];
    [self setupMagicRecord];
    //    [self truncateLocalData];

    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];

    // validate user's login state
    //    [LCUser logOut];
    LCUser* user = [LCUser currentUser];
    if (user) {
        DDLogInfo(@"当前用户：%@", user.username);
        HomeViewController* homeViewController = [HomeViewController new];
        [self switchRootViewController:homeViewController isNavigation:YES];
    } else {
        [self switchRootViewController:[LoginViewController new] isNavigation:NO];
    }

    [self.window makeKeyAndVisible];
}
- (void)setupLeanCloud
{
    // setup leanCloud with appId and key
    [AVOSCloud setApplicationId:kLeanCloudAppID clientKey:kLeanCloudAppKey];

    // register subclasses
    [LCSync registerSubclass];
    [LCUser registerSubclass];
    [LCTodo registerSubclass];
}
- (void)setupDrawerViewController
{
    _drawerViewController = [JVFloatingDrawerViewController new];
    JVFloatingDrawerSpringAnimator* animator = [JVFloatingDrawerSpringAnimator new];
    animator.animationDuration = 0.5;
    animator.initialSpringVelocity = 2;
    animator.springDamping = 0.8;
    _drawerViewController.animator = animator;

    _drawerViewController.leftViewController = [DrawerTableViewController new];

    _drawerViewController.backgroundImage = [UIImage imageAtResourcePath:@"drawerbg"];
}
- (void)setupDDLog
{
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];  //允许颜色
    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor blueColor] backgroundColor:nil forFlag:DDLogFlagInfo];

    DDFileLogger* fileLogger = [[DDFileLogger alloc] init];  // File Logger
    fileLogger.rollingFrequency = 60 * 60 * 24;              // 24 hour rolling
    fileLogger.logFileManager.maximumNumberOfLogFiles = 7;   //最长保留一周
    [DDLog addLogger:fileLogger];
}
- (void)setupMagicRecord
{
    [MagicalRecord setupAutoMigratingCoreDataStack];
}
- (void)truncateLocalData
{
    [CDUser MR_truncateAll];
    [CDTodo MR_truncateAll];
}
#pragma mark -
- (void)switchRootViewController:(UIViewController*)viewController isNavigation:(BOOL)isNavigation
{
    if (isNavigation) {
        JTNavigationController* navigationController = [[JTNavigationController alloc] initWithRootViewController:viewController];
        _drawerViewController.centerViewController = navigationController;
    }
    self.window.rootViewController = isNavigation ? _drawerViewController : viewController;
}
#pragma mark - JVDrawer
- (void)toggleDrawer:(id)sender animated:(BOOL)animated
{
    [_drawerViewController toggleDrawerWithSide:JVFloatingDrawerSideLeft animated:animated completion:nil];
}
- (void)setCenterViewController:(UIViewController*)viewController
{
    _drawerViewController.centerViewController = viewController;
}
#pragma mark -
+ (AppDelegate*)globalDelegate
{
    return (AppDelegate*)[UIApplication sharedApplication].delegate;
}
@end
