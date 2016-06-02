//
//  JVFloatingDrawerViewController.h
//  JVFloatingDrawer
//
//  Created by Julian Villella on 2015-01-11.
//  Copyright (c) 2015 JVillella. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JVFloatingDrawerAnimation;

typedef NS_ENUM(NSInteger, JVFloatingDrawerSide) {
    JVFloatingDrawerSideNone = 0,
    JVFloatingDrawerSideLeft,
    JVFloatingDrawerSideRight
};

@class JVFloatingDrawerView;

@interface JVFloatingDrawerViewController : UIViewController

#pragma mark - Managed View Controllers

@property (nonatomic, strong) UIViewController* centerViewController;
@property (nonatomic, strong) UIViewController* leftViewController;
@property (nonatomic, strong) UIViewController* rightViewController;

#pragma mark - Reveal Widths

@property (nonatomic, assign) CGFloat leftDrawerWidth;
@property (nonatomic, assign) CGFloat rightDrawerWidth;

#pragma mark - Interaction

@property (nonatomic, assign, getter=isDragToRevealEnabled) BOOL dragToRevealEnabled;

- (void)openDrawerWithSide:(JVFloatingDrawerSide)drawerSide animated:(BOOL)animated
                completion:(void (^)(BOOL finished))completion;

- (void)closeDrawerWithSide:(JVFloatingDrawerSide)drawerSide animated:(BOOL)animated
                 completion:(void (^)(BOOL finished))completion;

- (void)toggleDrawerWithSide:(JVFloatingDrawerSide)drawerSide animated:(BOOL)animated
                  completion:(void (^)(BOOL finished))completion;

#pragma mark - Animation

@property (nonatomic, strong) id<JVFloatingDrawerAnimation> animator;

#pragma mark - Background

@property (nonatomic, strong) UIImage* backgroundImage;

#pragma mark - Drawer root view
/**
 *  2016-06-02 20:27:00，我要在上面多加两个按钮，暴露出来满足需求
 */
@property (nonatomic, strong, readonly) JVFloatingDrawerView* drawerView;

@end
