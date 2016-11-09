//
//  SGHelper.h
//  TO-DO
//
//  Created by Siegrain on 16/5/7.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "Localized.h"
#import <UIKit/UIKit.h>

static NSInteger const kPopHeightWhenKeyboardShow = 170;

@interface SGHelper : NSObject
#pragma mark - fonts & colors

+ (UIFont *)themeFontWithSize:(CGFloat)size;

+ (UIFont *)themeFontDefault;

+ (UIColor *)themeColorGray;

+ (UIColor *)themeColorLightGray;

+ (UIColor *)subTextColor;

+ (UIColor *)themeColorRed;

+ (UIColor *)buttonColorHighlighted;

+ (UIColor *)buttonColorDisabled;

#pragma mark - photo picker
+ (void)photoPickerFromTarget:(UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate> *)viewController;

#pragma mark - alerts

/*转菊花*/
+ (void)waitingAlert;

/*隐藏提示*/
+ (void)dismissAlert;

/*错误提示*/
+ (void)errorAlertWithMessage:(NSString *)message;

/*文本提示*/
+ (void)alertWithMessage:(NSString *)message;

#pragma mark - date
/**
 *  获取本地化格式的日期字符串
 *
 *  @param date <#date description#>
 *
 *  @return <#return value description#>
 */
+ (NSString *)localizedFormatDate:(NSDate *)date;
@end
