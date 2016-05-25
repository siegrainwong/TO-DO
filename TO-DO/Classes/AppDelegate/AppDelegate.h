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

@property (readonly, strong, nonatomic) NSManagedObjectContext* managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel* managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator* persistentStoreCoordinator;

- (void)saveContext;
- (NSURL*)applicationDocumentsDirectory;

+ (AppDelegate*)globalDelegate;

/**
 *  切换根控制器
 */
- (void)switchRootViewController:(UIViewController*)viewController isNavigation:(BOOL)isNavigation;
/**
 *  切换到抽屉视图
 */
- (void)toggleDrawer:(id)sender animated:(BOOL)animated;
@end
