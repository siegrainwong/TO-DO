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
 *  绘制指定颜色的图片
 *
 *  @param color <#color description#>
 *
 *  @return <#return value description#>
 */
+ (UIImage*)imageWithColor:(UIColor*)color;
/**
 *  高效率绘制圆角的方法
 *
 *  @param radius <#radius description#>
 *  @param size   <#size description#>
 *
 *  @return <#return value description#>
 */
- (UIImage*)imageAddCornerWithRadius:(CGFloat)radius andSize:(CGSize)size;
@end
