//
//  SSDynamicTextSizeChanger.h
//  SSDynamicText
//
//  Created by Remigiusz Herba on 15/09/15.
//  Copyright (c) 2015 Splinesoft. All rights reserved. 
//

@import Foundation;

#import "SSDynamicAttributedTextSizable.h"
#import "UIView+SSTextSize.h"

@interface SSDynamicTextSizeChanger : NSObject <SSDynamicAttributedTextSizable>

/**
 * The default font descriptor used by view.
 * Its size is adjusted up (or down) based on the user's preferred text size.
 * Updating this will change the view's font.
 */
@property (nonatomic, strong, nullable) UIFontDescriptor *defaultFontDescriptor;

/**
 * The default block called by view when font size change.
 */
@property (nonatomic, readonly, nullable) SSTextSizeChangedBlock changeHandler;

/**
 * Block which is called when SSDynamicTextSizeChanger want to change font, view should configure this block.
 */
@property (nonatomic, copy, nullable) void(^fontChangeBlock)(UIFont * __nullable font);

/**
 * Block which is called when SSDynamicTextSizeChanger want to change attributedText, view should configure this block.
 */
@property (nonatomic, copy, nullable) void(^attributedTextChangeBlock)(NSAttributedString * __nullable attributedString);

@end
