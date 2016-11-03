//
//  HeaderView.m
//  TO-DO
//
//  Created by Siegrain on 16/5/14.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "HeaderView.h"
#import "Macros.h"
#import "Masonry.h"
#import "SGHelper.h"
#import "UIImage+Extension.h"
#import "CALayer+FSExtension.h"
#import "SGRectangleView.h"

static CGFloat const kAvatarButtonSizeMultipliedByHeight = 0.16;
static CGFloat const kRightOperationButtonSizeMultipliedByHeight = 0.1;
static CGFloat const kTitleLabelHeight = 40;
static CGFloat const kRectangleHeight = 40;

@interface
HeaderView ()
@property(nonatomic, readonly, strong) UIImageView *backgroundImageView;
@property(nonatomic, readwrite, assign) HeaderAvatarPosition avatarPosition;
@property(nonatomic, readwrite, assign) HeaderTitleAlignement titleAlignment;
@property(nonatomic, strong) SGRectangleView *rectangleView;
@property(nonatomic, strong) CAGradientLayer *maskLayer;
@end

@implementation HeaderView
#pragma mark - initial

+ (instancetype)headerViewWithAvatarPosition:(HeaderAvatarPosition)avatarPosition titleAlignement:(HeaderTitleAlignement)titleAlignement {
    HeaderView *headerView = [[HeaderView alloc] init];
    headerView.avatarPosition = avatarPosition;
    headerView.titleAlignment = titleAlignement;
    [headerView setup];
    [headerView bindConstraints];
    
    return headerView;
}

- (UIImage *)maskWithImage:(UIImage *)image {
    CGSize size = [image size];
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(size.width * 2, size.height), NO, 0);
    [image drawAtPoint:CGPointMake(0, 0)];
    [image drawAtPoint:CGPointMake(size.width, 0)];
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return result;
}

- (void)setup {
//    _maskLayer = [CAGradientLayer layer];
//    _maskLayer.borderWidth = 0;
//    _maskLayer.colors = @[(id) [UIColor clearColor].CGColor, (id) [UIColor colorWithWhite:0 alpha:0.85].CGColor];
//    _maskLayer.locations = @[@0.0F, @1.0F];
    
    _backgroundImageView = [[UIImageView alloc] init];
    _backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    _backgroundImageView.image = [self maskWithImage:self.backgroundImage];
//    [_backgroundImageView.layer insertSublayer:_maskLayer atIndex:0];
    [self addSubview:_backgroundImageView];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [SGHelper themeFontWithSize:32];
    _titleLabel.textColor = [UIColor whiteColor];
    [self addSubview:_titleLabel];
    
    _subtitleLabel = [[UILabel alloc] init];
    _subtitleLabel.font = [SGHelper themeFontWithSize:12];
    _subtitleLabel.textColor = [SGHelper themeColorSubTitle];
    [self addSubview:_subtitleLabel];
    
    _avatarButton = [[UIButton alloc] init];
    _avatarButton.layer.masksToBounds = YES;
    _avatarButton.layer.cornerRadius = kScreenHeight * kAvatarButtonSizeMultipliedByHeight / 2;
    [_avatarButton addTarget:self action:@selector(avatarButtonDidPress) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_avatarButton];
    
    _rectangleView = [SGRectangleView new];
    [self addSubview:_rectangleView];
    
    _rightOperationButton = [[UIButton alloc] init];
    _rightOperationButton.layer.masksToBounds = YES;
    _rightOperationButton.layer.cornerRadius = kScreenHeight * kRightOperationButtonSizeMultipliedByHeight / 2;
    [_rightOperationButton addTarget:self action:@selector(rightOperationButtonDidPress) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_rightOperationButton];
}

- (void)bindConstraints {
    [_rectangleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.bottom.offset(0);
        make.width.offset(kScreenWidth);
        make.height.offset(kRectangleHeight);
    }];
    
    [_backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.offset(0);
        if (_avatarPosition == HeaderAvatarPositionBottom) {
            make.top.offset(0);
            make.height.equalTo(self).multipliedBy(0.9);
        } else {
            make.bottom.offset(0);
            make.height.equalTo(self);
        }
    }];
    
    [_rightOperationButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.offset(-6);
        make.right.offset(-20);
        make.width.offset(kScreenHeight * kRightOperationButtonSizeMultipliedByHeight);
        make.height.equalTo(_rightOperationButton.mas_width);
    }];
    
    [_avatarButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_backgroundImageView);
        make.bottom.offset((CGFloat) (_avatarPosition == HeaderAvatarPositionCenter ? -kScreenHeight * 0.23 : 0));
        make.width.offset(kScreenHeight * kAvatarButtonSizeMultipliedByHeight);
        make.height.equalTo(_avatarButton.mas_width);
    }];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_backgroundImageView);
        if (_avatarPosition == HeaderAvatarPositionCenter && _titleAlignment == HeaderTitleAlignmentCenter)
            make.top.equalTo(_avatarButton.mas_bottom).offset(5);
        else
            make.centerY.offset(-30);
        make.height.offset(kTitleLabelHeight);
    }];
    
    [_subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_titleLabel.mas_bottom).offset(5);
        make.height.offset(20);
        make.centerX.equalTo(_titleLabel);
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
//    if (!_maskLayer.frame.size.height) _maskLayer.frame = self.frame;
}

#pragma mark - avatar button event

- (void)avatarButtonDidPress {
    if (_headerViewDidPressAvatarButton) _headerViewDidPressAvatarButton();
}

#pragma mark - right operation button event

- (void)rightOperationButtonDidPress {
    if (_headerViewDidPressRightOperationButton) _headerViewDidPressRightOperationButton();
}

#pragma mark - release

- (void)dealloc {
    DDLogWarn(@"%s", __func__);
}
@end
