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
#import "TodoHelper.h"
#import "UIImage+Extension.h"

static CGFloat const kAvatarSizeMultipliedByHeight = 0.15;

@implementation HeaderView
#pragma mark - initial
+ (instancetype)headerView
{
    HeaderView* headerView = [[HeaderView alloc] init];
    [headerView setup];
    [headerView bindConstraints];

    return headerView;
}
- (void)setup
{
    _headerImageView = [[UIImageView alloc] init];
    _headerImageView.contentMode = UIViewContentModeScaleToFill;
    [self addSubview:_headerImageView];

    _headerTitleLabel = [[UILabel alloc] init];
    _headerTitleLabel.font = [TodoHelper themeFontWithSize:32];
    _headerTitleLabel.textColor = [UIColor whiteColor];
    [self addSubview:_headerTitleLabel];

    _avatarButton = [[UIButton alloc] init];
    _avatarButton.layer.masksToBounds = YES;
    _avatarButton.layer.cornerRadius = kScreenHeight * kAvatarSizeMultipliedByHeight / 2;
    [_avatarButton addTarget:self action:@selector(avatarButtonDidPress) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_avatarButton];

    _rightOperationButton = [[UIButton alloc] init];
    [_rightOperationButton addTarget:self action:@selector(rightOperationButtonDidPress) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_rightOperationButton];
}
- (void)bindConstraints
{
    [_headerImageView mas_makeConstraints:^(MASConstraintMaker* make) {
        make.left.right.top.offset(0);
        make.height.equalTo(self).multipliedBy(0.9);
    }];

    [_rightOperationButton mas_makeConstraints:^(MASConstraintMaker* make) {
        make.bottom.offset(-kScreenHeight * 0.08);
        make.right.offset(-20);
        make.width.offset(kScreenHeight * 0.1);
        make.height.equalTo(_rightOperationButton.mas_width);
    }];

    [self setAvatarPosition:_avatarPosition];
    [self setTitleAlignement:_titleAlignement];
}
#pragma mark - avatar button position change
- (void)setAvatarPosition:(HeaderAvatarPosition)avatarPosition
{
    _avatarPosition = avatarPosition;
    if (avatarPosition == HeaderAvatarPositionCenter) {
    } else {
        [_headerTitleLabel mas_remakeConstraints:^(MASConstraintMaker* make) {
            make.centerX.equalTo(_headerImageView);
            make.centerY.offset(-30);
            make.height.offset(80);
        }];
    }
}
#pragma mark - title label alignement change
- (void)setTitleAlignement:(HeaderTitleAlignement)titleAlignement
{
    _titleAlignement = titleAlignement;
    if (titleAlignement == HeaderTitleAlignementCenter) {
        [_avatarButton mas_remakeConstraints:^(MASConstraintMaker* make) {
            make.centerX.equalTo(_headerImageView);
            make.bottom.offset(0);
            make.width.offset(kScreenHeight * kAvatarSizeMultipliedByHeight);
            make.height.equalTo(_avatarButton.mas_width);
        }];
    } else {
    }
}
#pragma mark - avatar button event
- (void)avatarButtonDidPress
{
    if (_headerViewDidPressAvatarButton) _headerViewDidPressAvatarButton();
}
#pragma mark - right operation button event
- (void)rightOperationButtonDidPress
{
}
@end
