//
//  UIFont+SSTextSize.m
//  SSDynamicText
//
//  Created by Jonathan Hersh on 5/16/13.
//  Copyright (c) 2013 Splinesoft. All rights reserved.
//

#import "UIFont+SSTextSize.h"
#import "UIApplication+SSTextSize.h"

@implementation UIFont (SSTextSize)

+ (instancetype)dynamicFontWithName:(NSString *)fontName baseSize:(CGFloat)baseSize {
    return [UIFont fontWithName:fontName
                           size:(baseSize + [UIApplication sharedApplication].preferredFontSizeDelta)];
}

@end
