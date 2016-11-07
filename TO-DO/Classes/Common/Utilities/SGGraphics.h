//
// Created by Siegrain on 16/11/3.
// Copyright (c) 2016 com.siegrain. All rights reserved.
//

@interface SGGraphics : NSObject
/**
 * 在已有图片上绘制线性渐变的盖板
 * @param image
 * @param paths
 * @param colors
 * @return
 */
+ (UIImage *)gradientImageWithImage:(UIImage *)image paths:(CGFloat[])paths colors:(NSArray<UIColor *> *)colors;

+ (UIImage *)gradientImageWithSize:(CGSize)size paths:(CGFloat[])paths colors:(NSArray<UIColor *> *)colors;
@end