//
// Created by Siegrain on 16/12/19.
// Copyright (c) 2016 com.siegrain. All rights reserved.
//

#import "SettingTableViewCell.h"
#import "SettingModel.h"
#import "UIImage+Extension.h"
#import "UIView+SDAutoLayout.h"

static CGFloat const kIndicatorSize = 13;

@interface SettingTableViewCell ()
@property(nonatomic, assign) SettingCellStyle style;
@property(nonatomic, strong) SettingModel *model;

@property(nonatomic, strong) UIImageView *iconView;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *contentLabel;
@property(nonatomic, strong) UIImageView *indicatorView;
@property(nonatomic, strong) UISwitch *switchView;
@end

@implementation SettingTableViewCell
#pragma mark - accessors

- (CGPoint)cellSpacing {
    return CGPointMake(kScreenWidth * kSpacingRatioToWidth, kScreenWidth * kSpacingRatioToWidth);
}

- (void)setModel:(SettingModel *)model {
    _model = model;
    
    if (model.iconName)
        _iconView.image = [UIImage imageNamed:model.iconName];
    else
        _iconView.image = [UIImage new];
    
    _titleLabel.text = model.title;
    _contentLabel.text = model.content;
    [_switchView setOn:model.isOn];
    
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
}

#pragma mark - initial

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _style = (SettingCellStyle) reuseIdentifier.integerValue;
        [self setupViews];
        [self bindConstraints];
    }
    return self;
}

- (void)setupViews {
    if (_style == SettingCellStyleNavigator) {
        self.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageWithColor:ColorWithRGBA(0xFF3366, .2)]];
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
    } else
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _iconView = [UIImageView new];
    [self.contentView addSubview:_iconView];
    
    _titleLabel = [UILabel new];
    _titleLabel.font = [SGHelper themeFontWithSize:16];
    [self.contentView addSubview:_titleLabel];
    
    _contentLabel = [UILabel new];
    _contentLabel.font = [SGHelper themeFontWithSize:16];
    _contentLabel.textColor = [SGHelper subTextColor];
    _contentLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:_contentLabel];
    
    if (_style == SettingCellStyleNavigator) {
        _indicatorView = [UIImageView new];
        _indicatorView.image = [UIImage imageNamed:@"indicator"];
        [self.contentView addSubview:_indicatorView];
    }
    
    if (_style == SettingCellStyleSwitch) {
        _switchView = [UISwitch new];
        _switchView.onTintColor = [SGHelper themeColorRed];
        [_switchView addTarget:self action:@selector(switchChanged) forControlEvents:UIControlEventValueChanged];
        [self.contentView addSubview:_switchView];
    }
}

- (void)bindConstraints {
    CGPoint space = self.cellSpacing;
    
    _iconView.sd_layout
            .leftSpaceToView(self.contentView, space.x)
            .topSpaceToView(self.contentView, space.y)
            .heightIs(kIconSize)
            .widthIs(kIconSize);
    
    _titleLabel.sd_layout
            .leftSpaceToView(_iconView, space.x)
            .centerYEqualToView(_iconView)
            .widthIs(0)
            .heightRatioToView(_iconView, 1);
    
    _contentLabel.sd_layout
            .leftSpaceToView(_titleLabel, space.x)
            .centerYEqualToView(_titleLabel)
            .rightSpaceToView(self.contentView, space.x)
            .heightRatioToView(_iconView, 1);
    
    if (_style == SettingCellStyleSwitch) {
        _switchView.sd_layout
                .centerYEqualToView(_titleLabel)
                .rightSpaceToView(self.contentView, space.x)
                .widthIs(60)
                .heightRatioToView(_iconView, 1);
    }
    
    if (_style == SettingCellStyleNavigator) {
        _indicatorView.sd_layout
                .centerYEqualToView(_titleLabel)
                .leftSpaceToView(_contentLabel, (space.x - kIndicatorSize) / 2)
                .heightIs(kIndicatorSize)
                .widthIs(kIndicatorSize);
    }
}

- (void)updateConstraints {
    [super updateConstraints];
    
    CGSize titleSize = [_titleLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, kIconSize)];
    _titleLabel.sd_layout.widthIs(titleSize.width);
    
    if (_model.iconName) {
        _iconView.sd_layout.widthIs(kIconSize);
        _titleLabel.sd_layout.leftSpaceToView(_iconView, self.cellSpacing.x);
    } else {
        _iconView.sd_layout.widthIs(0);
        _titleLabel.sd_layout.leftSpaceToView(_iconView, 0);
    }
    
    [self setupAutoHeightWithBottomView:_titleLabel bottomMargin:self.cellSpacing.y];
}

#pragma mark -

- (void)switchChanged {
    if (_switchDidChange) _switchDidChange(_switchView.isOn);
}

@end