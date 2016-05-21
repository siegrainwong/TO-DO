//
//  BaseViewController.h
//  TO-DO
//
//  Created by Siegrain on 16/5/19.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "HeaderView.h"
#import "Masonry.h"
#import "SGUser.h"
#import "TodoHelper.h"
#import <UIKit/UIKit.h>

/**
 *  基页（除登录）
 */
@interface BaseViewController : UIViewController {
    /**
	 *  头视图
	 */
    HeaderView* headerView;
    /**
	 *  当前用户
	 */
    SGUser* user;
}
- (void)setupView;
- (void)bindConstraints;

/**
 *  设置 NavBar 上的标题
 */
- (void)setMenuTitle:(NSString*)title;
@end
