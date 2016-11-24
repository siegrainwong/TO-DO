//
// Created by Siegrain on 16/11/21.
// Copyright (c) 2016 com.siegrain. All rights reserved.
//

#import <SDAutoLayout/SDAutoLayout.h>
#import "DetailTableViewCell.h"
#import "SGBaseMapViewController.h"
#import "DetailModel.h"

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
    if(model.content) {
        _contentLabel.text = model.content;
        _contentLabel.textColor = [UIColor blackColor];
    }
    else
    {
        _contentLabel.text = model.placeholder;
        _contentLabel.textColor = [SGHelper subTextColor];
    }
}

#pragma mark - initial

- (void)setupViews {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _iconView = [UIImageView new];
    [self.contentView addSubview:_iconView];
    
    _contentLabel = [UILabel new];
    _contentLabel.numberOfLines = 0;
    _contentLabel.font = [SGHelper themeFontDefault];
    [self.contentView addSubview:_contentLabel];
}

- (void)bindConstraints {
    _iconView.sd_layout
            .leftSpaceToView(self.contentView, 10)
            .topSpaceToView(self.contentView, 5)
            .heightIs(20)
            .widthEqualToHeight();
    
    _contentLabel.sd_layout
            .leftSpaceToView(_iconView, 10)
            .topEqualToView(_iconView)
            .rightSpaceToView(self.contentView, 10)
            .autoHeightRatio(0)
            .maxHeightIs(100);
    
    [self setupAutoHeightWithBottomView:_contentLabel bottomMargin:5];
}

@end