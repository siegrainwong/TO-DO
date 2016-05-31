//
//  AppDelegate.m
//  TO-DO
//
//  Created by Siegrain on 16/5/7.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "AppDelegate.h"
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
    [self saveContext];
}
#pragma mark - initial
- (void)setup
{
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];

    [self setupLeanCloud];
    [self setup_drawerViewController];

    // validate user's login state
    //    [LCUser logOut];
    LCUser* user = [LCUser currentUser];
    if (user) {
        NSLog(@"当前用户：%@", user.username);
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
    [LCUser registerSubclass];
    [LCTodo registerSubclass];
}
- (void)setup_drawerViewController
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

#pragma mark - Core Data stack
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL*)applicationDocumentsDirectory
{
    // The directory the application uses to store the Core Data store file. This
    // code uses a directory named "Siegrain.TO_DO" in the application's documents
    // directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                   inDomains:NSUserDomainMask]
      lastObject];
}

- (NSManagedObjectModel*)managedObjectModel
{
    // The managed object model for the application. It is a fatal error for the
    // application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL* modelURL =
      [[NSBundle mainBundle] URLForResource:@"TO_DO"
                              withExtension:@"momd"];
    _managedObjectModel =
      [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator*)persistentStoreCoordinator
{
    // The persistent store coordinator for the application. This implementation
    // creates and returns a coordinator, having added the store for the
    // application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }

    // Create the coordinator and store

    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
      initWithManagedObjectModel:[self managedObjectModel]];
    NSURL* storeURL = [[self applicationDocumentsDirectory]
      URLByAppendingPathComponent:@"TO_DO.sqlite"];
    NSError* error = nil;
    NSString* failureReason =
      @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                   configuration:nil
                                                             URL:storeURL
                                                         options:nil
                                                           error:&error]) {
        // Report any error we got.
        NSMutableDictionary* dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] =
          @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error =
          [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN"
                              code:9999
                          userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You
        // should not use this function in a shipping application, although it may
        // be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext*)managedObjectContext
{
    // Returns the managed object context for the application (which is already
    // bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }

    NSPersistentStoreCoordinator* coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc]
      initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext
{
    NSManagedObjectContext* managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError* error = nil;
        if ([managedObjectContext hasChanges] &&
            ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error
            // appropriately.
            // abort() causes the application to generate a crash log and terminate.
            // You should not use this function in a shipping application, although it
            // may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
