//
//  JVDrawerTableViewCell.m
//  JVFloatingDrawer
//
//  Created by Julian Villella on 2015-01-15.
//  Copyright (c) 2015 JVillella. All rights reserved.
//

#import "DrawerTableViewCell.h"
#import "Macros.h"
#import "TodoHelper.h"
#import "UIView+SDAutoLayout.h"

@implementation DrawerTableViewCell {
    UIImageView* iconImageView;
    UILabel* titleLabel;
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
    titleLabel = [UILabel new];
    titleLabel.font = [TodoHelper themeFontWithSize:17];
    titleLabel.textColor = ColorWithRGB(0xDDDDDD);
    [self.contentView addSubview:titleLabel];

    iconImageView = [UIImageView new];
    [self.contentView addSubview:iconImageView];

    titleLabel.sd_layout
      .centerYEqualToView(self.contentView)
      .leftSpaceToView(self.contentView, 30)
      .rightSpaceToView(self.contentView, 10)
      .heightIs(20);

    iconImageView.sd_layout
      .centerYEqualToView(titleLabel)
      .rightSpaceToView(titleLabel, 5)
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
    UIColor* tintColor = [UIColor whiteColor];
    if (highlight) {
        tintColor = [UIColor colorWithWhite:1.0 alpha:0.6];
    }

    titleLabel.textColor = tintColor;
    iconImageView.tintColor = tintColor;
}

#pragma mark - accessors
- (void)setTitle:(NSString*)title
{
    titleLabel.text = title;
}
- (void)setIcon:(UIImage*)icon
{
    iconImageView.image = [icon imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

@end
