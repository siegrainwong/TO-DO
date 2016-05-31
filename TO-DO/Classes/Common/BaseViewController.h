//
//  BaseViewController.h
//  TO-DO
//
//  Created by Siegrain on 16/5/19.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "HeaderView.h"
#import "LCUser.h"
#import "Masonry.h"
#import "TodoHelper.h"
#import <UIKit/UIKit.h>

/**
 *  基页（除登录）
 */
@interface BaseViewController : UIViewController
/**
 *  右侧导航栏按钮
 */
@property (nonatomic, readonly, strong) UIButton* rightNavigationButton;
/**
 *  头视图
 */
@property (nonatomic, readwrite, strong) HeaderView* headerView;
/**
 *  当前用户
 */
@property (nonatomic, readonly, strong) LCUser* user;
/**
 *  在viewDidDisappear时释放该视图
 */
@property (nonatomic, readwrite, assign) BOOL releaseWhileDisappear;

- (void)setupView;
- (void)bindConstraints;

/**
 *  设置 NavBar 上的标题
 */
- (void)setMenuTitle:(NSString*)title;
@end
