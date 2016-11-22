//
//  UIFont+SSTextSize.h
//  SSDynamicText
//
//  Created by Jonathan Hersh on 5/16/13.
//  Copyright (c) 2013 Splinesoft. All rights reserved.
//

@import UIKit;

@interface UIFont (SSTextSize)

/**
 * Create a UIFont object using the specified font name and base size.
 * The actual size of the returned font is adjusted by
 * the user's current preferred font size (specified in Settings.app).
 * @param fontName Name of the font to use
 * @param baseSize Base size to use, offset by the user's preferred size.
 */
+ (nullable instancetype)dynamicFontWithName:(nonnull NSString *)fontName
                                    baseSize:(CGFloat)baseSize;

@end
