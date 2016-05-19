//
//  AppDelegate.m
//  TO-DO
//
//  Created by Siegrain on 16/5/7.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "AppDelegate.h"
#import "DataKeys.h"
#import "HomeViewController.h"
#import "JTNavigationController.h"
#import "LoginViewController.h"
#import "Macros.h"
#import "SGUser.h"
#import "UIImage+Extension.h"
#import <AVOSCloud.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication*)application
  didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    [self setupLeanCloud];

    // validate user's login state
    //    [SGUser logOut];
    SGUser* user = [SGUser currentUser];
    if (user) {
        NSLog(@"当前用户：%@", user.username);
        [self switchRootViewController:[[HomeViewController alloc] init] isNavigation:YES];
    } else {
        [self switchRootViewController:[[LoginViewController alloc] init] isNavigation:NO];
    }

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
#pragma mark - LeanCloud methods
- (void)setupLeanCloud
{
    // setup leanCloud with appId and key
    [AVOSCloud setApplicationId:kLeanCloudAppID clientKey:kLeanCloudAppKey];

    // register subclasses
    [SGUser registerSubclass];
}
#pragma mark - appdelegate methods
- (void)switchRootViewController:(UIViewController*)viewController isNavigation:(BOOL)isNavigation
{
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];

    JTNavigationController* nav;
    if (isNavigation) {
        nav = [[JTNavigationController alloc] initWithRootViewController:viewController];
        nav.fullScreenPopGestureEnabled = YES;
    }

    self.window.rootViewController = isNavigation ? nav : viewController;

    [self.window makeKeyAndVisible];
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
