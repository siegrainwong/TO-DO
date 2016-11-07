//
//  SGCommitButton.m
//  TO-DO
//
//  Created by Siegrain on 16/5/19.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "Masonry.h"
#import "SGCommitButton.h"
#import "SGHelper.h"
#import "UIImage+Extension.h"

@implementation SGCommitButton
#pragma mark - initial
+ (instancetype)commitButton
{
    SGCommitButton* commitButton = [SGCommitButton new];
    [commitButton setup];
    [commitButton bindConstraints];

    return commitButton;
}
- (void)setup
{
    _button = [[UIButton alloc] init];
    [_button setBackgroundImage:[UIImage imageWithColor:[SGHelper themeColorRed]]
                       forState:UIControlStateNormal];
    [_button setBackgroundImage:[UIImage imageWithColor:[SGHelper buttonColorHighlighted]]
                       forState:UIControlStateHighlighted];
    [_button setBackgroundImage:[UIImage imageWithColor:[SGHelper buttonColorDisabled]]
                       forState:UIControlStateDisabled];
    _button.titleLabel.font = [SGHelper themeFontWithSize:14];
    [_button addTarget:self action:@selector(buttonDidPress) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_button];

    _indicator = [[UIActivityIndicatorView alloc] init];
    _indicator.hidesWhenStopped = YES;
    [_button addSubview:_indicator];
}
- (void)bindConstraints
{
    __weak typeof(self) weakSelf = self;
    [_button mas_makeConstraints:^(MASConstraintMaker* make) {
        make.left.right.bottom.top.offset(0);
    }];

    [_indicator mas_makeConstraints:^(MASConstraintMaker* make) {
        make.centerY.offset(0);
        make.height.equalTo(weakSelf).dividedBy(2);
        make.width.equalTo(_indicator.mas_height);
        make.left.offset(20);
    }];
}
#pragma mark - methods
- (void)setAnimating:(BOOL)isAnimating
{
    if (isAnimating)
        [_indicator startAnimating];
    else
        [_indicator stopAnimating];

    [_button setEnabled:!isAnimating];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:isAnimating];
}
#pragma mark - event
- (void)buttonDidPress
{
    if (_commitButtonDidPress) _commitButtonDidPress();
}
#pragma mark - rewrite UIControl methods
- (void)setEnabled:(BOOL)enabled
{
    _button.enabled = enabled;
}
@end
