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
/**
 *  获取指定大小的系统字体
 *
 *  @param size <#size description#>
 *
 *  @return <#return value description#>
 */
+ (UIFont*)themeFontWithSize:(CGFloat)size;

+ (UIFont *)themeFontDefault;

+ (UIColor *)themeColorSubTitle;

+ (UIColor *)themeColorGray;

+ (UIColor *)themeColorLightGray;

/**
 *  根据状态获取主题颜色
 *
 *  @return <#return value description#>
 */
+ (UIColor*)themeColorNormal;
+ (UIColor*)themeColorHighlighted;
+ (UIColor*)themeColorDisabled;

/**
 *
 *  创建并配置一个图像选取器，根据sourceType来决定打开摄像头还是媒体库
 *
 *  @param sourceType <#sourceType description#>
 *  @param target     <#target description#>
 */
+ (void)pickPictureFromSource:(UIImagePickerControllerSourceType)sourceType target:(UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate>*)target error:(BOOL*)error;

/**
 *  配置一个用来选取图像的 ActionSheet
 *
 *  @param viewController <#viewController description#>
 *  @param cameraHandler  <#cameraHandler description#>
 *  @param albumHandler   <#albumHandler description#>
 */
+ (void)pictureActionSheetFrom:(UIViewController*)viewController selectCameraHandler:(void (^)())cameraHandler selectAlbumHandler:(void (^)())albumHandler;

/**
 *  获取本地化格式的日期字符串
 *
 *  @param date <#date description#>
 *
 *  @return <#return value description#>
 */
+ (NSString*)localizedFormatDate:(NSDate*)date;

/**
 *  非重点文字颜色
 */
+ (UIColor*)subTextColor;
@end
