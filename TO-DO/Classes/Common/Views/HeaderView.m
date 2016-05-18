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

static CGFloat const kAvatarSizeMultipliedByHeight = 0.16;
static CGFloat const kTitleLabelHeight = 40;

@implementation HeaderView {
    HeaderAvatarPosition avatarPosition;
    HeaderTitleAlignement titleAlignement;
}
#pragma mark - initial
+ (instancetype)headerViewWithAvatarPosition:(HeaderAvatarPosition)avatarPosition titleAlignement:(HeaderTitleAlignement)titleAlignement
{
    HeaderView* headerView = [[HeaderView alloc] init];
    headerView->avatarPosition = avatarPosition;
    headerView->titleAlignement = titleAlignement;
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

    [_avatarButton mas_makeConstraints:^(MASConstraintMaker* make) {
        make.centerX.equalTo(_headerImageView);
        if (avatarPosition == HeaderAvatarPositionCenter)
            make.top.offset(kScreenHeight * 0.18);
        else
            make.bottom.offset(0);
        make.width.offset(kScreenHeight * kAvatarSizeMultipliedByHeight);
        make.height.equalTo(_avatarButton.mas_width);
    }];

    [_headerTitleLabel mas_makeConstraints:^(MASConstraintMaker* make) {
        make.centerX.equalTo(_headerImageView);
        if (avatarPosition == HeaderAvatarPositionCenter && titleAlignement == HeaderTitleAlignementCenter)
            make.top.equalTo(_avatarButton.mas_bottom).offset(5);
        else
            make.centerY.offset(-30);
        make.height.offset(kTitleLabelHeight);
    }];
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
