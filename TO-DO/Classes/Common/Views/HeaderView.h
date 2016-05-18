//
//  HeaderView.h
//  TO-DO
//
//  Created by Siegrain on 16/5/14.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, HeaderAvatarPosition) {
    HeaderAvatarPositionBottom,
    HeaderAvatarPositionCenter
};

typedef NS_ENUM(NSInteger, HeaderTitleAlignement) {
    HeaderTitleAlignementCenter,
    HeaderTitleAlignementLeft
};

@interface HeaderView : UIView
/**
 *  头像按钮位置
 */
@property (nonatomic, readwrite, assign) HeaderAvatarPosition avatarPosition;
/**
 *  标题对其方式
 */
@property (nonatomic, readwrite, assign) HeaderTitleAlignement titleAlignement;
/**
 *  标题Label
 */
@property (nonatomic, readonly, strong) UILabel* headerTitleLabel;
/**
 *  副标题Label
 */
@property (nonatomic, readonly, strong) UILabel* headerSubtitleLabel;
/**
 *  背景ImageView
 */
@property (nonatomic, readonly, strong) UIImageView* headerImageView;
/**
 *  头像按钮
 */
@property (nonatomic, readonly, strong) UIButton* avatarButton;
/**
 *  右边的操作按钮
 */
@property (nonatomic, readonly, strong) UIButton* rightOperationButton;

/**
 *  头像按钮被按下的事件
 */
@property (nonatomic, readwrite, copy) void (^headerViewDidPressAvatarButton)();

+ (instancetype)headerView;
@end
