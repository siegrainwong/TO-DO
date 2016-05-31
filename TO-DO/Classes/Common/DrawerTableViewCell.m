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

@interface
DrawerTableViewCell ()
@property (nonatomic, readwrite, strong) UIImageView* iconImageView;
@property (nonatomic, readwrite, strong) UILabel* titleLabel;
@end

@implementation DrawerTableViewCell
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
    _titleLabel.font = [TodoHelper themeFontWithSize:17];
    _titleLabel.textColor = ColorWithRGB(0xDDDDDD);
    [self.contentView addSubview:_titleLabel];

    _iconImageView = [UIImageView new];
    [self.contentView addSubview:_iconImageView];

    _titleLabel.sd_layout
      .centerYEqualToView(self.contentView)
      .leftSpaceToView(self.contentView, 30)
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
    UIColor* tintColor = [UIColor whiteColor];
    if (highlight) {
        tintColor = [UIColor colorWithWhite:1.0 alpha:0.6];
    }

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
