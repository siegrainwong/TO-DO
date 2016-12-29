//
// Created by Siegrain on 16/11/21.
// Copyright (c) 2016 com.siegrain. All rights reserved.
//

#import <SDAutoLayout/SDAutoLayout.h>
#import "DetailTableViewCell.h"
#import "SGBaseMapViewController.h"
#import "DetailModel.h"
#import "SDWebImageManager.h"
#import "GCDQueue.h"
#import "UIImageView+WebCache.h"

static CGFloat const kIconSize = 18;
static CGFloat const kSpacingY = 14;

static CGFloat const kContentMaxHeight = 55;

@interface DetailTableViewCell ()
@property(nonatomic, strong) DetailModel *model;

@property(nonatomic, strong) UIImageView *iconView;
@property(nonatomic, strong) UILabel *contentLabel;
@property(nonatomic, strong) UIImageView *photoView;
@property(nonatomic, strong) SGBaseMapViewController *mapViewController;
@end

@implementation DetailTableViewCell
#pragma mark - accessors

- (CGFloat)mapHeight {
    return (CGFloat) (kScreenHeight * 0.26);
}

- (CGFloat)photoHeight {
    return (CGFloat) (kScreenHeight * 0.17);
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
    
    if (model.photoPath) {
        _photoView.image = [UIImage imageWithContentsOfFile:SGPhotoPath(model.identifier)];
    } else if (model.photoUrl) {
        [_photoView sd_setImageWithURL:[NSURL URLWithString:model.photoUrl]];
    }
    
    _mapViewController.coordinate = model.location;
    
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
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageWithColor:ColorWithRGBA(0xFF3366, .2)]];
    
    _iconView = [UIImageView new];
    [self.contentView addSubview:_iconView];
    
    _contentLabel = [UILabel new];
    _contentLabel.numberOfLines = 0;
    _contentLabel.font = [SGHelper themeFontDefault];
    [self.contentView addSubview:_contentLabel];
    
    _photoView = [UIImageView new];
    _photoView.contentMode = UIViewContentModeScaleAspectFill;
    _photoView.clipsToBounds = YES;
    [self.contentView addSubview:_photoView];
    
    _mapViewController = [SGBaseMapViewController new];
    _mapViewController.isEditing = NO;
    [self.contentView addSubview:_mapViewController.view];
}

- (void)bindConstraints {
    CGPoint space = CGPointMake(19, kSpacingY);
    
    _iconView.sd_layout
            .leftSpaceToView(self.contentView, space.x + 2)
            .topSpaceToView(self.contentView, space.y)
            .heightIs(kIconSize)
            .widthEqualToHeight();
    
    _contentLabel.sd_layout
            .leftSpaceToView(_iconView, space.x)
            .topEqualToView(_iconView)
            .rightSpaceToView(self.contentView, space.x)
            .autoHeightRatio(0)
            .maxHeightIs(kContentMaxHeight);   //三排字刚好
    
    _photoView.sd_layout
            .leftSpaceToView(_iconView, space.x)
            .topEqualToView(_iconView)
            .rightSpaceToView(self.contentView, space.x)
            .heightIs(self.photoHeight);
    
    _mapViewController.view.sd_layout
            .leftSpaceToView(_iconView, space.x)
            .topSpaceToView(_contentLabel, space.y)
            .rightSpaceToView(self.contentView, space.x)
            .heightIs(0);
}

- (void)updateConstraints {
    [super updateConstraints];
    
    UIView *bottomView = nil;
    if (_model.style == DetailCellStylePhoto && _model.hasPhoto) {
        _contentLabel.sd_layout.maxHeightIs(0);
        _mapViewController.view.sd_layout.heightIs(0);
        _photoView.sd_layout.heightIs(self.photoHeight);
        
        bottomView = _photoView;
    } else if (_model.style == DetailCellStyleMap && _model.content) {
        _contentLabel.sd_layout.maxHeightIs(kContentMaxHeight);
        _photoView.sd_layout.heightIs(0);
        _mapViewController.view.sd_layout.heightIs(self.mapHeight);
        
        bottomView = _mapViewController.view;
    } else {
        _contentLabel.sd_layout.maxHeightIs(kContentMaxHeight);
        _photoView.sd_layout.heightIs(0);
        _mapViewController.view.sd_layout.heightIs(0);
        
        bottomView = _contentLabel;
    }
    
    [self setupAutoHeightWithBottomView:bottomView bottomMargin:kSpacingY];
}

@end
