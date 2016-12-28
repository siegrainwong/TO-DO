//
//  SGHeaderView.m
//  TO-DO
//
//  Created by Siegrain on 16/5/14.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "SGHeaderView.h"
#import "Masonry.h"
#import "SGRectangleView.h"
#import "SGGraphics.h"

static CGFloat const kAvatarButtonSizeMultipliedByHeight = 0.16;
static CGFloat const kTitleLabelHeight = 40;
static CGFloat const kRectangleHeight = 40;
static CGFloat const kTitleSpacingX = 25;
static void *const kHeaderViewKVOContext = (void *) &kHeaderViewKVOContext;

@interface SGHeaderView ()
@property(nonatomic, readonly, strong) UIImageView *backgroundImageView;
@property(nonatomic, readwrite, assign) HeaderAvatarPosition avatarPosition;
@property(nonatomic, readwrite, assign) NSTextAlignment titleAlignment;
@property(nonatomic, strong) SGRectangleView *rectangleView;
@property(nonatomic, strong) UIImage *image;

@property(nonatomic, assign) BOOL isStickMode;
@end

@implementation SGHeaderView
#pragma mark - release

- (void)dealloc {
    DDLogWarn(@"%s", __func__);
}

#pragma mark - accessors

- (CGFloat)rightOperationButtonSize {
    return kScreenWidth * 0.17f;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    _rectangleView.color = backgroundColor;
}

- (void)setImage:(UIImage *)image style:(HeaderMaskStyle)style {
    if (style == HeaderMaskStyleLight) {
        CGFloat paths[] = {0, .7, 1};
        NSArray *colors = @[ColorWithRGBA(0x6563A4, .2), ColorWithRGBA(0x6563A4, .2), ColorWithRGBA(0x6563A4, .35)];
        _backgroundImageView.backgroundColor = [UIColor clearColor];
        _backgroundImageView.image = [SGGraphics gradientImageWithImage:image paths:paths colors:colors];
    } else if (style == HeaderMaskStyleDark) {
        CGFloat paths[] = {0, .5, 1};
        NSArray *colors = @[ColorWithRGBA(0xFFFFFF, .0), ColorWithRGBA(0x555555, .5), ColorWithRGBA(0x000000, .8)];
        _backgroundImageView.backgroundColor = ColorWithRGB(0x9092AC);
        _backgroundImageView.image = [SGGraphics gradientImageWithImage:image paths:paths colors:colors];
    }else if (style == HeaderMaskStyleMedium) {
        CGFloat paths[] = {0, .5, 1};
        NSArray *colors = @[ColorWithRGBA(0xFFFFFF, .0), ColorWithRGBA(0x999999, .5), ColorWithRGBA(0x000000, .5)];
        _backgroundImageView.backgroundColor = ColorWithRGB(0x9092AC);
        _backgroundImageView.image = [SGGraphics gradientImageWithImage:image paths:paths colors:colors];
    }
}

#pragma mark - initial

+ (instancetype)headerViewWithAvatarPosition:(HeaderAvatarPosition)avatarPosition titleAlignement:(NSTextAlignment)titleAlignment {
    SGHeaderView *headerView = [[SGHeaderView alloc] init];
    headerView.avatarPosition = avatarPosition;
    headerView.titleAlignment = titleAlignment;
    [headerView setup];
    [headerView bindConstraints];
    
    return headerView;
}

- (void)setup {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    _backgroundImageView = [[UIImageView alloc] init];
    _backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    _backgroundImageView.clipsToBounds = YES;
    [self addSubview:_backgroundImageView];
    
    _rectangleView = [SGRectangleView new];
    [self addSubview:_rectangleView];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [SGHelper themeFontWithSize:32];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.textAlignment = _titleAlignment;
    [self addSubview:_titleLabel];
    
    _subtitleLabel = [[UILabel alloc] init];
    _subtitleLabel.font = [SGHelper themeFontWithSize:12];
    _subtitleLabel.textColor = [SGHelper themeColorLightGray];
    _subtitleLabel.textAlignment = _titleAlignment;
    [self addSubview:_subtitleLabel];
    
    _avatarButton = [[UIButton alloc] init];
    _avatarButton.layer.masksToBounds = YES;
    _avatarButton.layer.cornerRadius = kScreenHeight * kAvatarButtonSizeMultipliedByHeight / 2;
    [_avatarButton addTarget:self action:@selector(avatarButtonDidPress) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_avatarButton];
    
    _rightOperationButton = [[UIButton alloc] init];
    _rightOperationButton.layer.masksToBounds = YES;
    _rightOperationButton.layer.cornerRadius = self.rightOperationButtonSize / 2;
    _rightOperationButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [_rightOperationButton setImage:[UIImage imageNamed:@"header_add"] forState:UIControlStateNormal];
    [_rightOperationButton addTarget:self action:@selector(rightOperationButtonDidPress) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_rightOperationButton];
}

- (void)bindConstraints {
    __weak __typeof(self) weakSelf = self;
    [_backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.offset(0);
        if (weakSelf.avatarPosition == HeaderAvatarPositionBottom) {
            make.height.equalTo(weakSelf).multipliedBy(0.9);
            make.top.offset(0);
        } else {
            make.height.equalTo(weakSelf);
            make.bottom.offset(0);
        }
    }];
    
    [_rectangleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(0);
        make.bottom.equalTo(weakSelf.backgroundImageView.mas_bottom);
        make.width.offset(kScreenWidth);
        make.height.offset(kRectangleHeight);
    }];
    
    [_rightOperationButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakSelf.rectangleView).offset(-kRectangleHeight / 2 + 5);
        make.right.offset(-20);
        make.width.offset(weakSelf.rightOperationButtonSize);
        make.height.equalTo(weakSelf.rightOperationButton.mas_width);
    }];
    
    [_avatarButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_backgroundImageView);
        make.bottom.offset((CGFloat) (weakSelf.avatarPosition == HeaderAvatarPositionCenter ? -kScreenHeight * 0.25 : 0));
        make.width.offset(kScreenHeight * kAvatarButtonSizeMultipliedByHeight);
        make.height.equalTo(weakSelf.avatarButton.mas_width);
    }];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(kTitleSpacingX);
        make.right.offset(-kTitleSpacingX);
        if (_avatarPosition == HeaderAvatarPositionCenter)
            make.top.equalTo(weakSelf.avatarButton.mas_bottom).offset(5);
        else
            make.centerY.offset(-30);
        make.height.offset(kTitleLabelHeight);
    }];
    
    [_subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.titleLabel.mas_bottom).offset(5);
        make.height.offset(20);
        make.left.right.equalTo(_titleLabel);
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
@end

@implementation SGHeaderView (ParallaxHeader)

- (void)removeFromSuperview {
    if (_parallaxScrollView) [_parallaxScrollView removeObserver:self forKeyPath:NSStringFromSelector(@selector(contentOffset)) context:kHeaderViewKVOContext];
}

#pragma mark - accessors

- (void)setParallaxScrollView:(UIScrollView *)parallaxScrollView {
    _parallaxScrollView = parallaxScrollView;
    
    if (_parallaxScrollView)[_parallaxScrollView addObserver:self forKeyPath:NSStringFromSelector(@selector(contentOffset)) options:NSKeyValueObservingOptionNew context:kHeaderViewKVOContext];
}

- (void)setParallaxHeight:(CGFloat)parallaxHeight {
    _parallaxHeight = parallaxHeight;
    
    [_backgroundImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.offset(0);
        make.height.offset(_parallaxHeight);
    }];
}

#pragma mark - KVO

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

#pragma mark - private methods

- (void)scrollView:(UIScrollView *)scrollView didScrollToPoint:(CGPoint)contentOffset {
    CGFloat offset = contentOffset.y + 64;
    [self updateHeaderFrameWithOffsetY:offset];
    [self setHeaderStickWithOffsetY:offset];
    
    [_parallaxScrollView bringSubviewToFront:self];
}

- (void)setHeaderStickWithOffsetY:(CGFloat)y {
    if (!self.parallaxMinimumHeight) return;
    
    CGFloat needsToStick = self.parallaxHeight - y <= self.parallaxMinimumHeight;
    if (needsToStick) {
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.offset(y - (self.parallaxHeight - self.parallaxMinimumHeight));
        }];
        self.isStickMode = YES;
    } else if (!needsToStick && self.isStickMode) {
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.offset(CGFLOAT_MIN);
        }];
        self.isStickMode = NO;
    }
}

- (void)updateHeaderFrameWithOffsetY:(CGFloat)y {
    CGFloat offset = y - self.parallaxIgnoreInset;
    if (self.height - offset < self.parallaxMinimumHeight || self.height - offset < 0) return;
    
    //Mark: 这里只需要修改背景图的约束，其他约束不要动
    [self.backgroundImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.offset(self.height - offset);
    }];
}

@end
