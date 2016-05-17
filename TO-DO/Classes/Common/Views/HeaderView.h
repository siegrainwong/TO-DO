//
//  HeaderView.h
//  TO-DO
//
//  Created by Siegrain on 16/5/14.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HeaderView : UIView
/**
 *  标题Label
 */
@property (nonatomic, readonly, strong) UILabel* headerTitleLabel;
/**
 *  背景ImageView
 */
@property (nonatomic, readonly, strong) UIImageView* headerImageView;
/**
 *  头像按钮
 */
@property (nonatomic, readonly, strong) UIButton* avatarButton;
@property (nonatomic, readwrite, copy) void (^headerViewDidPressAvatarButton)();

+ (instancetype)headerView;
@end
