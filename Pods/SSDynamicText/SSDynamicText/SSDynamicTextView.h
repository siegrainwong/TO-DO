//
//  SSDynamicTextView.h
//  SSDynamicText
//
//  Created by Jonathan Hersh on 10/6/13.
//  Copyright (c) 2013 Splinesoft. All rights reserved.
//

@import UIKit;

#import "SSDynamicAttributedTextSizable.h"

@interface SSDynamicTextView : UITextView <SSDynamicAttributedTextSizable>

/**
 * Create a dynamic-sizing textview that will adjust its size in response to changes
 * to the user's preferred text size.
 */
+ (nonnull instancetype)textViewWithFont:(nonnull NSString *)fontName
                                baseSize:(CGFloat)size;

/**
 * Create a dynamic-sizing label using a base font descriptor.
 * If `descriptor` is nil, sets font descriptor with `-ss_defaultFontName` and `-ss_defaultBaseSize` values.
 * @see ss_defaultFontName, ss_defaultBaseSize.
 */
+ (nonnull instancetype)textViewWithFontDescriptor:(nullable UIFontDescriptor *)descriptor;

@end
