//
//  SSDynamicTextSizeChanger.m
//  SSDynamicText
//
//  Created by Remigiusz Herba on 15/09/15.
//  Copyright (c) 2015 Splinesoft. All rights reserved. 
//

#import "SSDynamicTextSizeChanger.h"
#import "NSAttributedString+SSTextSize.h"
#import "UIApplication+SSTextSize.h"

@interface SSDynamicTextSizeChanger()

@property (nonatomic, copy) NSAttributedString *baseAttributedText;

@end

@implementation SSDynamicTextSizeChanger

- (void)changeAttributedStringFontWithDelta:(NSInteger)newDelta {
    if (self.attributedTextChangeBlock) {
        self.attributedTextChangeBlock([self.baseAttributedText ss_attributedStringWithAdjustedFontSizeWithDelta:newDelta]);
    }
}

- (void)changeFontWithDelta:(NSInteger)newDelta {
    CGFloat preferredSize = [self.defaultFontDescriptor.fontAttributes[UIFontDescriptorSizeAttribute] floatValue];
    preferredSize += newDelta;

    if (self.fontChangeBlock) {
        self.fontChangeBlock([UIFont fontWithDescriptor:self.defaultFontDescriptor
                                                   size:preferredSize]);
    }
}

- (SSTextSizeChangedBlock)changeHandler {
    __weak typeof(self) weakSelf = self;
    
    SSTextSizeChangedBlock changeHandler = ^(NSInteger newDelta) {
        [weakSelf changeFontWithDelta:newDelta];
        if (weakSelf.baseAttributedText.length > 0) {
            [weakSelf changeAttributedStringFontWithDelta:newDelta];
        }
    };
    return changeHandler;
}

#pragma mark - SSDynamicAttributedTextSizable

- (NSAttributedString *)dynamicAttributedText {
    return self.baseAttributedText;
}

- (void)setDynamicAttributedText:(NSAttributedString *)attributedText {
    self.baseAttributedText = [attributedText copy];
    [self changeAttributedStringFontWithDelta:[UIApplication sharedApplication].preferredFontSizeDelta];
}

@end
