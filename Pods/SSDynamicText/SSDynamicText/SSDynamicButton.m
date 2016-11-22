//
//  SSDynamicButton.m
//  SSDynamicText
//
//  Created by Adam Grzegorowski on 18/07/15.
//  Copyright (c) 2015 Splinesoft. All rights reserved. 
//

#import "SSDynamicButton.h"
#import "UIApplication+SSTextSize.h"
#import "UIView+SSTextSize.h"
#import "NSAttributedString+SSTextSize.h"

@interface SSDynamicButton ()

@property (nonatomic, strong) NSMutableDictionary *baseAttributedTitlesDictionary;

@end

@implementation SSDynamicButton

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }

    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];

    NSAssert(self.buttonType == UIButtonTypeCustom, @"Change SSDynamicButton.buttonType to UIButtonTypeCustom in your nib");
    [self setupDefaultFontDescriptorBasedOnFont:self.titleLabel.font];

    [self setup];
}

+ (instancetype)buttonWithFont:(NSString *)fontName baseSize:(CGFloat)size {
    UIFontDescriptor *fontDescriptor = [UIFontDescriptor fontDescriptorWithName:fontName size:size];

    return [self buttonWithFontDescriptor:fontDescriptor];
}

+ (instancetype)buttonWithFontDescriptor:(UIFontDescriptor *)descriptor {
    SSDynamicButton *button = [self new];
    button.defaultFontDescriptor = descriptor;
    return button;
}

- (void)dealloc {
    [self ss_stopObservingTextSizeChanges];
    [self removeTitleLabelFontObserver];
}

- (void)setAttributedTitle:(NSAttributedString *)title forState:(UIControlState)state {
    NSNumber *key = @(state);
    if (title) {
        [self.baseAttributedTitlesDictionary setObject:title forKey:key];
    } else {
        [self.baseAttributedTitlesDictionary removeObjectForKey:key];
    }
    [self changeAttributedTitle:title forState:state withFontSizeDelta:[UIApplication sharedApplication].preferredFontSizeDelta];
}

#pragma mark - Private methods

- (void)setup {
    __weak typeof(self) weakSelf = self;

    [self addTitleLabelFontObserver];

    SSTextSizeChangedBlock changeHandler = ^(NSInteger newDelta) {

        [weakSelf changeFontWithDelta:newDelta];
        [weakSelf changeAttributedStringWithDelta:newDelta];
    };

    [self ss_startObservingTextSizeChangesWithBlock:changeHandler];
}

- (void)changeFontWithDelta:(NSInteger)newDelta {
    CGFloat preferredSize = [self.defaultFontDescriptor.fontAttributes[UIFontDescriptorSizeAttribute] floatValue];
    preferredSize += newDelta;

    [self removeTitleLabelFontObserver];
    self.titleLabel.font = [UIFont fontWithDescriptor:self.defaultFontDescriptor
                                                 size:preferredSize];

    [self addTitleLabelFontObserver];
}

- (void)changeAttributedTitle:(NSAttributedString *)attributedTitle forState:(UIControlState)state withFontSizeDelta:(NSInteger)newDelta {
    [super setAttributedTitle:[attributedTitle ss_attributedStringWithAdjustedFontSizeWithDelta:newDelta] forState:state];
}

- (void)changeAttributedStringWithDelta:(NSInteger)newDelta {
    [self.baseAttributedTitlesDictionary enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, NSAttributedString *title, BOOL *stop) {
        [self changeAttributedTitle:title forState:key.unsignedIntegerValue withFontSizeDelta:newDelta];
    }];
}

#pragma mark - Accessors

- (NSMutableDictionary *)baseAttributedTitlesDictionary {
    if (_baseAttributedTitlesDictionary == nil) {
        _baseAttributedTitlesDictionary = [NSMutableDictionary dictionary];
    }
    return _baseAttributedTitlesDictionary;
}

#pragma mark - Font observing

- (void)addTitleLabelFontObserver {
#if !TARGET_INTERFACE_BUILDER
    [self.titleLabel addObserver:self forKeyPath:NSStringFromSelector(@selector(font)) options:NSKeyValueObservingOptionNew context:NULL];
#endif
}

- (void)removeTitleLabelFontObserver {
#if !TARGET_INTERFACE_BUILDER
    [self.titleLabel removeObserver:self forKeyPath:NSStringFromSelector(@selector(font))];
#endif
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(font))]) {

        NSInteger newDelta = [UIApplication sharedApplication].preferredFontSizeDelta;
        [self setupDefaultFontDescriptorBasedOnFont:self.titleLabel.font];

        [self changeFontWithDelta:newDelta];
        [self changeAttributedStringWithDelta:newDelta];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
