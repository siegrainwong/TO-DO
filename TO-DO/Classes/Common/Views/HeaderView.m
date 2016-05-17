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

static NSUInteger const kAvatarSizeDividedByView = 4;

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
    _headerTitleLabel.layer.opacity = 0;
    [self addSubview:_headerTitleLabel];

    _avatarButton = [[UIButton alloc] init];
    _avatarButton.layer.masksToBounds = YES;
    _avatarButton.layer.cornerRadius = kScreenWidth / 4 / 2;
    [_avatarButton addTarget:self action:@selector(avatarButtonDidPress) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_avatarButton];
}
- (void)bindConstraints
{
    [_headerImageView mas_makeConstraints:^(MASConstraintMaker* make) {
        make.left.right.top.offset(0);
        make.height.equalTo(self).multipliedBy(0.9);
    }];

    [_headerTitleLabel mas_makeConstraints:^(MASConstraintMaker* make) {
        make.centerX.equalTo(_headerImageView);
        make.centerY.offset(-30);
        make.height.offset(80);
    }];

    [_avatarButton mas_makeConstraints:^(MASConstraintMaker* make) {
        make.centerX.equalTo(_headerImageView);
        make.bottom.offset(0);
        make.width.equalTo(self).dividedBy(kAvatarSizeDividedByView);
        make.height.equalTo(_avatarButton.mas_width);
    }];
}
#pragma mark - avatar button event
- (void)avatarButtonDidPress
{
    if (_headerViewDidPressAvatarButton) _headerViewDidPressAvatarButton();
}
@end
