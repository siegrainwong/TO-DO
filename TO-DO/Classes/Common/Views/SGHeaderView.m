//
//  SGHeaderView.m
//  TO-DO
//
//  Created by Siegrain on 16/5/14.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import <SDAutoLayout/UIView+SDAutoLayout.h>
#import "SGHeaderView.h"
#import "Masonry.h"
#import "SGRectangleView.h"
#import "SGGraphics.h"
#import "UIView+Extentsion.h"

static CGFloat const kAvatarButtonSizeMultipliedByHeight = 0.16;
static CGFloat const kRightOperationButtonSizeMultipliedByHeight = 0.1;
static CGFloat const kTitleLabelHeight = 40;
static CGFloat const kRectangleHeight = 40;
static void *const kHeaderViewKVOContext = (void *) &kHeaderViewKVOContext;

@interface SGHeaderView ()
@property(nonatomic, readonly, strong) UIImageView *backgroundImageView;
@property(nonatomic, readwrite, assign) HeaderAvatarPosition avatarPosition;
@property(nonatomic, readwrite, assign) HeaderTitleAlignement titleAlignment;
@property(nonatomic, strong) SGRectangleView *rectangleView;

@property(nonatomic, assign) BOOL isStickMode;
@end

@implementation SGHeaderView
#pragma mark - release

- (void)dealloc {
    DDLogWarn(@"%s", __func__);
    if (_parallaxScrollView) [self removeObserver:_parallaxScrollView forKeyPath:NSStringFromSelector(@selector(contentOffset))];
}

#pragma mark - accessors

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    
    _rectangleView.color = backgroundColor;
}

- (BOOL)isAdjustTopInset {
    //根据导航栏的透明属性来判断
    if ([_parallaxScrollView.nextResponder isKindOfClass:[UIViewController class]]) {
        UIViewController *viewController = (UIViewController *) _parallaxScrollView.nextResponder;
        if (viewController.navigationController.navigationBar.translucent) return NO;
    }
    return YES;
}

- (void)setImage:(UIImage *)image {
    _image = image;
    CGFloat paths[] = {0, .7, 1};
    _backgroundImageView.image = [SGGraphics gradientImageWithImage:image paths:paths colors:@[ColorWithRGBA(0x6563A4, .2), ColorWithRGBA(0x6563A4, .2), ColorWithRGBA(0x6563A4, .35)]];
}

- (void)setParallaxScrollView:(UIScrollView *)parallaxScrollView {
    _parallaxScrollView = parallaxScrollView;
    
    [_parallaxScrollView addObserver:self forKeyPath:NSStringFromSelector(@selector(contentOffset)) options:NSKeyValueObservingOptionNew context:kHeaderViewKVOContext];
}

- (void)setParallaxHeight:(CGFloat)parallaxHeight {
    _parallaxHeight = parallaxHeight;
    
    [_backgroundImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.offset(0);
        make.height.offset(self.parallaxHeight);
    }];
}

#pragma mark - initial

+ (instancetype)headerViewWithAvatarPosition:(HeaderAvatarPosition)avatarPosition titleAlignement:(HeaderTitleAlignement)titleAlignment {
    SGHeaderView *headerView = [[SGHeaderView alloc] init];
    headerView.avatarPosition = avatarPosition;
    headerView.titleAlignment = titleAlignment;
    [headerView setup];
    [headerView bindConstraints];
    
    return headerView;
}

- (void)setup {
    _backgroundImageView = [[UIImageView alloc] init];
    _backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    _backgroundImageView.clipsToBounds = YES;
    [self addSubview:_backgroundImageView];
    
    _rectangleView = [SGRectangleView new];
    [self addSubview:_rectangleView];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [SGHelper themeFontWithSize:32];
    _titleLabel.textColor = [UIColor whiteColor];
    [self addSubview:_titleLabel];
    
    _subtitleLabel = [[UILabel alloc] init];
    _subtitleLabel.font = [SGHelper themeFontWithSize:12];
    _subtitleLabel.textColor = [SGHelper themeColorLightGray];
    [self addSubview:_subtitleLabel];
    
    _avatarButton = [[UIButton alloc] init];
    _avatarButton.layer.masksToBounds = YES;
    _avatarButton.layer.cornerRadius = kScreenHeight * kAvatarButtonSizeMultipliedByHeight / 2;
    [_avatarButton addTarget:self action:@selector(avatarButtonDidPress) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_avatarButton];
    
    _rightOperationButton = [[UIButton alloc] init];
    _rightOperationButton.layer.masksToBounds = YES;
    _rightOperationButton.layer.cornerRadius = kScreenHeight * kRightOperationButtonSizeMultipliedByHeight / 2;
    [_rightOperationButton addTarget:self action:@selector(rightOperationButtonDidPress) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_rightOperationButton];
}

- (void)bindConstraints {
    [_backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.offset(0);
        if (_avatarPosition == HeaderAvatarPositionBottom) {
            make.top.offset(0);
            make.height.equalTo(self).multipliedBy(0.9);
        } else {
            make.bottom.offset(0);
            make.height.equalTo(self);
        }
    }];
    
    [_rectangleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(0);
        make.bottom.equalTo(_backgroundImageView.mas_bottom);
        make.width.offset(kScreenWidth);
        make.height.offset(kRectangleHeight);
    }];
    
    [_rightOperationButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.offset(-6);
        make.right.offset(-20);
        make.width.offset(kScreenHeight * kRightOperationButtonSizeMultipliedByHeight);
        make.height.equalTo(_rightOperationButton.mas_width);
    }];
    
    [_avatarButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_backgroundImageView);
        make.bottom.offset((CGFloat) (_avatarPosition == HeaderAvatarPositionCenter ? -kScreenHeight * 0.25 : 0));
        make.width.offset(kScreenHeight * kAvatarButtonSizeMultipliedByHeight);
        make.height.equalTo(_avatarButton.mas_width);
    }];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_backgroundImageView);
        if (_avatarPosition == HeaderAvatarPositionCenter && _titleAlignment == HeaderTitleAlignmentCenter)
            make.top.equalTo(_avatarButton.mas_bottom).offset(5);
        else
            make.centerY.offset(-30);
        make.height.offset(kTitleLabelHeight);
    }];
    
    [_subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_titleLabel.mas_bottom).offset(5);
        make.height.offset(20);
        make.centerX.equalTo(_titleLabel);
    }];
}

#pragma mark - avatar button event

- (void)avatarButtonDidPress {
    if (_headerViewDidPressAvatarButton) _headerViewDidPressAvatarButton();
}

#pragma mark - right operation button event

- (void)rightOperationButtonDidPress {
    if (_headerViewDidPressRightOperationButton) _headerViewDidPressRightOperationButton();
}

#pragma mark - parallax header

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == kHeaderViewKVOContext) {
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(contentOffset))]) {
            UIScrollView *scrollView = object;
            [self scrollView:scrollView didScrollToPoint:scrollView.contentOffset];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)scrollView:(UIScrollView *)scrollView didScrollToPoint:(CGPoint)contentOffset {
    [self updateHeaderFrameWithOffsetY:contentOffset.y];
    [self setHeaderStickWithOffsetY:contentOffset.y];
}

-(void)setHeaderStickWithOffsetY:(CGFloat)y{
    if(!_parallaxMinimumHeight) return;
    
    CGFloat offset = y + (self.isAdjustTopInset ? 64 : 0);
    CGFloat needsToStick = _parallaxHeight - offset <= _parallaxMinimumHeight;
    
    if (needsToStick) {
        if(_isStickMode){
            [self mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.offset(offset - (_parallaxHeight - _parallaxMinimumHeight));
            }];
        }else{
            [self mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.offset(0);
                make.width.offset(kScreenWidth);
                make.height.offset(_parallaxHeight);
                make.top.offset(offset - (_parallaxHeight - _parallaxMinimumHeight));
            }];
        }
        _isStickMode = YES;
    } else if (!needsToStick && _isStickMode) {
        _isStickMode = NO;
        [self mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.offset(0);
            make.width.offset(kScreenWidth);
            make.height.offset(_parallaxHeight);
            make.top.offset(0);
        }];
    }
}

- (void)updateHeaderFrameWithOffsetY:(CGFloat)y {
    if (self.height - y < _parallaxMinimumHeight || self.height - y < 0) return;
    
    //Mark: 这里只需要修改背景图的约束，其他约束不要动
    [self.backgroundImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.offset(self.height - y);
    }];
}
@end
