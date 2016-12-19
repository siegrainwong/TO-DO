//
//  SGHeaderView.h
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

typedef NS_ENUM(NSInteger, HeaderMaskStyle) {
    HeaderMaskStyleLight,
    HeaderMaskStyleMedium,
    HeaderMaskStyleDark
};

@interface SGHeaderView : UIView
/**
 *  标题Label
 */
@property(nonatomic, readonly, strong) UILabel *titleLabel;
/**
 *  副标题Label
 */
@property(nonatomic, readonly, strong) UILabel *subtitleLabel;
/**
 *  头像按钮
 */
@property(nonatomic, readonly, strong) UIButton *avatarButton;
/**
 *  右边的操作按钮
 */
@property(nonatomic, readonly, strong) UIButton *rightOperationButton;
/**
 *  头像按钮被按下的事件
 */
@property(nonatomic, readwrite, copy) void (^headerViewDidPressAvatarButton)();
/**
 *  按下右操作按钮
 */
@property(nonatomic, readwrite, copy) void (^headerViewDidPressRightOperationButton)();

+ (instancetype)headerViewWithAvatarPosition:(HeaderAvatarPosition)avatarPosition titleAlignement:(NSTextAlignment)titleAlignment;

/**
 * 设置背景图
 * @param image 图片
 * @param style 蒙版样式
 */
- (void)setImage:(UIImage *)image style:(HeaderMaskStyle)style;

#pragma mark - parallax header
/**
 *  需要设置Parallax效果的ScrollView
 */
@property(nonatomic, weak) UIScrollView *parallaxScrollView;
/**
 *  parallaxScrollView的初始高度
 */
@property(nonatomic, assign) CGFloat parallaxHeight;
/**
 *  保留高度
 */
@property(nonatomic, assign) CGFloat parallaxMinimumHeight;
/**
 *  忽略的InsetTop
 */
@property(nonatomic, assign) CGFloat parallaxIgnoreInset;
@end

