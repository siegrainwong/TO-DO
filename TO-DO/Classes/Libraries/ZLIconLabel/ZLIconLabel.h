//
//  ZLIconLabel.h
//  ZLIconLabel
//
//  Created by apple on 16/4/11.
//  Copyright © 2016年 ANGELEN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+Extension.h"

typedef NS_ENUM(NSUInteger, ZLIconLabelPosition) {
    ZLIconLabelPositionLeft, // 文本左边
    ZLIconLabelPositionRight, // 文本右边
};

@interface ZLIconLabel : UILabel

/** Image that will be placed with a text*/
@property (nonatomic, strong) UIImage *icon;

/** Position of an image */
@property (nonatomic, assign) ZLIconLabelPosition iconPosition;

/** Additional spacing between text and image */
@property (nonatomic, assign) CGFloat iconPadding;

@end
