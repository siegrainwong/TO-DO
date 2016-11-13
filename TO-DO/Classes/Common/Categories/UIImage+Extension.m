//
//  UIImage+ResourceImage.m
//  TO-DO
//
//  Created by Siegrain on 16/5/7.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "UIImage+Extension.h"

@implementation UIImage (Extension)
+ (instancetype)imageAtResourcePath:(NSString*)imageName
{
    NSString* bundlePath = [[NSBundle mainBundle] resourcePath];
    UIImage* image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", bundlePath, imageName]];

    return image;
}
+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;
{
    UIGraphicsBeginImageContextWithOptions(newSize, NO, [UIScreen mainScreen].scale);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
+ (UIImage*)imageWithColor:(UIColor*)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage* theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}
- (UIImage*)imageAddCornerWithRadius:(CGFloat)radius andSize:(CGSize)size
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);

    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    UIBezierPath* path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(radius, radius)];
    CGContextAddPath(ctx, path.CGPath);
    CGContextClip(ctx);
    [self drawInRect:rect];
    CGContextDrawPath(ctx, kCGPathFillStroke);
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
@end
