//
//  UIApplication+SSTextSize.m
//  SSDynamicText
//
//  Created by Jonathan Hersh on 10/4/13.
//  Copyright (c) 2013 Splinesoft. All rights reserved.
//

#import "UIApplication+SSTextSize.h"

@implementation UIApplication (SSTextSize)

- (NSInteger)preferredFontSizeDelta {
    static NSArray<NSString *> *fontSizes;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fontSizes = @[
          UIContentSizeCategoryExtraSmall,
          UIContentSizeCategorySmall,
          UIContentSizeCategoryMedium,
          UIContentSizeCategoryLarge,
          UIContentSizeCategoryExtraLarge,
          UIContentSizeCategoryExtraExtraLarge,
          UIContentSizeCategoryExtraExtraExtraLarge,
          UIContentSizeCategoryAccessibilityMedium,
          UIContentSizeCategoryAccessibilityLarge,
          UIContentSizeCategoryAccessibilityExtraLarge,
          UIContentSizeCategoryAccessibilityExtraExtraLarge,
          UIContentSizeCategoryAccessibilityExtraExtraExtraLarge,
        ];
    });
  
    NSUInteger currentSize = [fontSizes indexOfObject:self.preferredContentSizeCategory];
  
    if (currentSize == NSNotFound) {
        return 0;
    }
  
    // Default size is 'Large'
    return currentSize - [fontSizes indexOfObject:UIContentSizeCategoryLarge];
}

@end
