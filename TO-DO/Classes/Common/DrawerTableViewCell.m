//
//  JVDrawerTableViewCell.m
//  JVFloatingDrawer
//
//  Created by Julian Villella on 2015-01-15.
//  Copyright (c) 2015 JVillella. All rights reserved.
//

#import "DrawerTableViewCell.h"
#import "Macros.h"
#import "SGHelper.h"
#import "UIView+SDAutoLayout.h"

@interface
DrawerTableViewCell ()
@property (nonatomic, readwrite, strong) UIImageView* iconImageView;
@property (nonatomic, readwrite, strong) UILabel* titleLabel;
@end

@implementation DrawerTableViewCell
#pragma mark - accessors
+ (CGFloat)leftSpaceFromView
{
    return kScreenHeight * 0.05;
}
#pragma mark - initial
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];

        [self setup];
    }
    return self;
}
- (void)setup
{
    _titleLabel = [UILabel new];
    _titleLabel.font = [SGHelper themeFontWithSize:18];
    _titleLabel.textColor = ColorWithRGB(0xDDDDDD);
    [self.contentView addSubview:_titleLabel];

    _iconImageView = [UIImageView new];
    [self.contentView addSubview:_iconImageView];

    _titleLabel.sd_layout
      .centerYEqualToView(self.contentView)
      .leftSpaceToView(self.contentView, [DrawerTableViewCell leftSpaceFromView])
      .rightSpaceToView(self.contentView, 10)
      .heightIs(20);

    _iconImageView.sd_layout
      .centerYEqualToView(_titleLabel)
      .rightSpaceToView(_titleLabel, 5)
      .widthIs(20)
      .heightEqualToWidth();
}

#pragma mark - hightlight cell
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    [self highlightCell:selected];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    [self highlightCell:highlighted];
}

- (void)highlightCell:(BOOL)highlight
{
    UIColor* tintColor = ColorWithRGB(0xCCCCCC);
    if (highlight) tintColor = [UIColor whiteColor];

    _titleLabel.textColor = tintColor;
    _iconImageView.tintColor = tintColor;
}

#pragma mark - accessors
- (void)setTitle:(NSString*)title
{
    _titleLabel.text = title;
}
- (void)setIcon:(UIImage*)icon
{
    _iconImageView.image = [icon imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

@end
