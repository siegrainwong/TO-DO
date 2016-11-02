//
//  BaseViewController.h
//  TO-DO
//
//  Created by Siegrain on 16/5/19.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "CDUser.h"
#import "HeaderView.h"
#import "LCUser.h"
#import "Masonry.h"
#import "SGViews.h"

/**
 *  基页（除登录）
 */
@interface BaseViewController : UIViewController<SGViews>
/**
 *  右侧导航栏按钮
 */
@property (nonatomic, readonly, strong) UIButton* rightNavigationButton;
/**
 *  左侧导航栏按钮
 */
@property (nonatomic, readonly, strong) UIButton* leftNavigationButton;
/**
 *  头视图
 */
@property (nonatomic, readwrite, strong) HeaderView* headerView;
/**
 *  当前用户(LeanCloud)
 */
@property (nonatomic, readonly, strong) LCUser* lcUser;
/**
 *  当前用户(Coredata)
 */
@property (nonatomic, readonly, strong) CDUser* cdUser;
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
