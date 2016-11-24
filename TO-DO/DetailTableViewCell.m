//
// Created by Siegrain on 16/11/21.
// Copyright (c) 2016 com.siegrain. All rights reserved.
//

#import <SDAutoLayout/SDAutoLayout.h>
#import "DetailTableViewCell.h"
#import "SGBaseMapViewController.h"
#import "DetailModel.h"

static CGFloat const kIconSize = 18;

@interface DetailTableViewCell ()
@property(nonatomic, strong) DetailModel *model;

@property(nonatomic, strong) UIImageView *iconView;
@property(nonatomic, strong) UILabel *contentLabel;
@property(nonatomic, strong) UIImageView *photoView;
@property(nonatomic, strong) SGBaseMapViewController *mapViewController;
@end

@implementation DetailTableViewCell
#pragma mark - accessors

- (NSInteger)cellStyle {
    return self.reuseIdentifier.integerValue;
}

- (void)setModel:(DetailModel *)model {
    _model = model;
    
    _iconView.image = [UIImage imageNamed:model.iconName];
    if (model.content && model.content.length) {
        _contentLabel.text = model.content;
        _contentLabel.textColor = [UIColor blackColor];
    } else {
        _contentLabel.text = model.placeholder;
        _contentLabel.textColor = [SGHelper subTextColor];
    }
    
    [self setNeedsUpdateConstraints];
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
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _iconView = [UIImageView new];
    [self.contentView addSubview:_iconView];
    
    _contentLabel = [UILabel new];
    _contentLabel.numberOfLines = 0;
    _contentLabel.font = [SGHelper themeFontDefault];
    [self.contentView addSubview:_contentLabel];
    
    if (self.cellStyle == DetailCellStyleMap) {
        
    } else if (self.cellStyle == DetailCellStylePhoto) {
        
    }
}

- (void)bindConstraints {
    CGPoint space = CGPointMake(19, 14);
    
    _iconView.sd_layout
            .leftSpaceToView(self.contentView, space.x)
            .topSpaceToView(self.contentView, space.y)
            .heightIs(kIconSize)
            .widthEqualToHeight();
    
    _contentLabel.sd_layout
            .leftSpaceToView(_iconView, space.x)
            .topEqualToView(_iconView)
            .rightSpaceToView(self.contentView, space.x)
            .autoHeightRatio(0)
            .maxHeightIs(55);   //三排字刚好
    
    [self setupAutoHeightWithBottomView:_contentLabel bottomMargin:space.y];
}

- (void)updateConstraints {
    [super updateConstraints];
}

@end