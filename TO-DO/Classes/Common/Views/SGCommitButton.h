//
//  SGCommitButton.h
//  TO-DO
//
//  Created by Siegrain on 16/5/19.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 *  上传按钮
 */
@interface SGCommitButton : UIControl
/**
 *  按钮
 */
@property (nonatomic, readonly, strong) UIButton* button;
/**
 *  菊花
 */
@property (nonatomic, readonly, strong) UIActivityIndicatorView* indicator;
@property (nonatomic, readwrite, copy) void (^commitButtonDidPress)();

+ (instancetype)commitButton;

/**
 *  开始转菊花（包括状态栏菊花），并禁用按钮
 */
- (void)setAnimating:(BOOL)isAnimating;
@end
