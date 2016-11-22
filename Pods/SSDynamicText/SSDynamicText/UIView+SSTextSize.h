//
//  UIView+SSTextSize.h
//  SSDynamicText
//
//  Created by Jonathan Hersh on 10/4/13.
//  Copyright (c) 2013 Splinesoft. All rights reserved.
//

@import UIKit;

UIKIT_EXTERN NSString * __nonnull const kSSDynamicDefaultFontName;
UIKIT_EXTERN NSString * __nonnull const kSSDynamicDefaultBaseSize;

@interface UIView (SSTextSize)

typedef void (^SSTextSizeChangedBlock) (NSInteger);

/**
 * The default font descriptor used by this view.
 * Its size is adjusted up (or down) based on the user's preferred text size.
 * Updating this will change the view's font.
 */
@property (nonatomic, strong, nullable) UIFontDescriptor *defaultFontDescriptor;

/**
 * Default FontName if set in Info.plist or systemFontName if not set.
 * Key: kSSDynamicDefaultFontName
 */
@property (nonatomic, readonly, nonnull) NSString *ss_defaultFontName;

/**
 * DefaultBaseSize if set in Info.plist or 16.0f if not set.
 * Key: kSSDynamicDefaultBaseSize
 */
@property (nonatomic, readonly) CGFloat ss_defaultBaseSize;

/*
 * Begin observing changes to the user's preferred text size with the given callback block.
 * When the user changes her preferred text size, the callback block is called with the
 * new text size delta from the default.
 */
- (void)ss_startObservingTextSizeChangesWithBlock:(nonnull SSTextSizeChangedBlock)block;

/**
 * Stop observing changes to text size.
 */
- (void)ss_stopObservingTextSizeChanges;

/**
 * Force a recalculation of our preferred text size.
 */
- (void)preferredContentSizeDidChange;

/**
 * Sets `defaultFontDescriptor` based on font parameter.
 * If font parameter is `nil`, sets `defaultFontDesciptor` with default font name and default base size.
 * @see defaultFontDescriptor, ss_defaultFontName, ss_defaultBaseSize.
 */
- (void)setupDefaultFontDescriptorBasedOnFont:(nullable UIFont *)font;

@end
