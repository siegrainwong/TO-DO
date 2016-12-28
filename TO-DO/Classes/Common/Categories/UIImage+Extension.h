//
//  UIImage+ResourceImage.h
//  TO-DO
//
//  Created by Siegrain on 16/5/7.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Extension)
/**
 *  获取Resource Path下的图片
 *
 *  @param imageName <#imageName description#>
 *
 *  @return <#return value description#>
 */
+ (instancetype)imageAtResourcePath:(NSString*)imageName;
/**
 *  重新设置图片尺寸
 *
 *  @param image   <#image description#>
 *  @param newSize <#newSize description#>
 *
 *  @return <#return value description#>
 */
+ (instancetype)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;

+ (UIImage *)thumbnailWithCenterClip:(UIImage *)image size:(CGSize)size radius:(CGFloat)radius;

+ (UIImage *)thumbnailWithImageWithoutScale:(UIImage *)image size:(CGSize)size;

/**
 *  绘制指定颜色的图片
 *
 *  @param color <#color description#>
 *
 *  @return <#return value description#>
 */
+ (instancetype)imageWithColor:(UIColor*)color;
/**
 *  高效率绘制圆角的方法
 *
 *  @param radius <#radius description#>
 *  @param size   <#size description#>
 *
 *  @return <#return value description#>
 */
- (instancetype)imageAddCornerWithRadius:(CGFloat)radius andSize:(CGSize)size;
@end
