//
//  UIView+SSTextSize.m
//  SSDynamicText
//
//  Created by Jonathan Hersh on 10/4/13.
//  Copyright (c) 2013 Splinesoft. All rights reserved.
//

#import "UIView+SSTextSize.h"
#import "UIApplication+SSTextSize.h"
#import <objc/runtime.h>

static char kTextSizeChangedBlockKey;
static char kDefaultFontDescriptorKey;

NSString * const kSSDynamicDefaultFontName = @"SSDynamicDefaultFontName";
NSString * const kSSDynamicDefaultBaseSize = @"SSDynamicDefaultBaseSize";

@implementation UIView (SSTextSize)

#pragma mark - default font descriptor

- (UIFontDescriptor *)defaultFontDescriptor {
    return (UIFontDescriptor *)objc_getAssociatedObject(self, &kDefaultFontDescriptorKey);
}

- (void)setDefaultFontDescriptor:(UIFontDescriptor *)defaultFontDescriptor {
    objc_setAssociatedObject(self, &kDefaultFontDescriptorKey, defaultFontDescriptor, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    [self preferredContentSizeDidChange];
}

#pragma mark - text size changes

- (void)ss_startObservingTextSizeChangesWithBlock:(SSTextSizeChangedBlock)block {
    NSParameterAssert(block);
    
    [self ss_stopObservingTextSizeChanges];
    
    objc_setAssociatedObject(self, &kTextSizeChangedBlockKey, block, OBJC_ASSOCIATION_COPY);
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(preferredContentSizeDidChange)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
    
    [self preferredContentSizeDidChange];
}

- (void)ss_stopObservingTextSizeChanges {
    objc_setAssociatedObject(self, &kTextSizeChangedBlockKey, nil, OBJC_ASSOCIATION_ASSIGN);
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIContentSizeCategoryDidChangeNotification
                                                  object:nil];
}

- (void)preferredContentSizeDidChange {
    NSInteger newDelta = [UIApplication sharedApplication].preferredFontSizeDelta;
    
    SSTextSizeChangedBlock changeBlock = (SSTextSizeChangedBlock)objc_getAssociatedObject(self, &kTextSizeChangedBlockKey);
    
    if (changeBlock) {
        changeBlock(newDelta);
    }
    
    [self invalidateIntrinsicContentSize];
    [self setNeedsDisplay];
}

#pragma mark - Default Fonts

- (NSString *)ss_defaultFontName {
    NSString *defaultFontName = [NSBundle mainBundle].infoDictionary[kSSDynamicDefaultFontName];
    return (defaultFontName ?: [UIFont systemFontOfSize:[self ss_defaultBaseSize]].fontName);
}

- (CGFloat)ss_defaultBaseSize {
    CGFloat defaultBaseSize = [[NSBundle mainBundle].infoDictionary[kSSDynamicDefaultBaseSize] floatValue];
    return (defaultBaseSize == 0.0f ? 16.0f : defaultBaseSize);
}

- (void)setupDefaultFontDescriptorBasedOnFont:(UIFont *)font {
    NSString *fontName;
    CGFloat baseSize = 0.0f;

    if (font) {
        fontName = font.fontName;
        baseSize = font.pointSize;
    }

    fontName = (fontName ?: self.ss_defaultFontName);
    baseSize = (baseSize ?: self.ss_defaultBaseSize);

    self.defaultFontDescriptor = (font.fontDescriptor ?: [UIFontDescriptor fontDescriptorWithName:fontName
                                                                                             size:baseSize]);
}

@end
