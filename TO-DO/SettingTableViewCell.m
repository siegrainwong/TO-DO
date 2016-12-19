//
// Created by Siegrain on 16/12/19.
// Copyright (c) 2016 com.siegrain. All rights reserved.
//

#import "SettingTableViewCell.h"
#import "SettingModel.h"
#import "UIImage+Extension.h"
#import "UIView+SDAutoLayout.h"

static CGFloat const kIconSize = 18;
static CGFloat const kSpacingY = 14;

@interface SettingTableViewCell ()
@property(nonatomic, strong) SettingModel *model;

@property(nonatomic, strong) UIImageView *iconView;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *contentLabel;
@end

@implementation SettingTableViewCell
#pragma mark - accessors

- (void)setModel:(SettingModel *)model {
    _model = model;
    
    _iconView.image = [UIImage imageNamed:model.iconName];
    _titleLabel.text = model.title;
    _contentLabel.text = model.content;
    
    [self setNeedsUpdateConstraints];
    //Mark: iOS 10: 不加这句他不会执行updateConstraints
    [self updateConstraintsIfNeeded];
}

#pragma mark - initial

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupViews];
        [self bindConstraints];
    }
    return self;
}

- (void)setupViews {
    self.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageWithColor:ColorWithRGBA(0xFF3366, .2)]];
    
    _iconView = [UIImageView new];
    [self.contentView addSubview:_iconView];
    
    _titleLabel = [UILabel new];
    _titleLabel.font = [SGHelper themeFontDefault];
    [self.contentView addSubview:_titleLabel];
    
    _contentLabel = [UILabel new];
    _contentLabel.font = [SGHelper themeFontDefault];
    _contentLabel.textColor = [SGHelper subTextColor];
    [self.contentView addSubview:_contentLabel];
}

- (void)bindConstraints {
    CGPoint space = CGPointMake(19, kSpacingY);
    
    _iconView.sd_layout
            .leftSpaceToView(self.contentView, space.x)
            .topSpaceToView(self.contentView, space.y)
            .heightIs(kIconSize)
            .widthEqualToHeight();
    
    _titleLabel.sd_layout
            .leftSpaceToView(_iconView, space.x)
            .centerYEqualToView(_iconView)
            .widthIs(100)
            .heightRatioToView(_iconView, 1);
    
    _contentLabel.sd_layout
            .leftSpaceToView(_titleLabel, space.x)
            .centerYEqualToView(_titleLabel)
            .rightSpaceToView(self.contentView, space.x)
            .heightRatioToView(_iconView, 1);
}

- (void)updateConstraints {
    [super updateConstraints];
    
    UIView *bottomView = _titleLabel;
    [self setupAutoHeightWithBottomView:bottomView bottomMargin:kSpacingY];
}
@end