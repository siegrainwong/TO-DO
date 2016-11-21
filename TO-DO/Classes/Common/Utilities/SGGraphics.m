//
// Created by Siegrain on 16/11/3.
// Copyright (c) 2016 com.siegrain. All rights reserved.
//

#import "SGGraphics.h"


@implementation SGGraphics
+ (UIImage *)gradientImageWithImage:(UIImage *)image paths:(CGFloat[])paths colors:(NSArray<UIColor *> *)colors {
	UIImage* result = [image copy];
	
    CGSize size = [result size];
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(size.width, size.height), NO, 0);
    //调用这个方法的效果应该是将该图片的Context附着在当前Context上
    [result drawInRect:CGRectMake(0, 0, size.width, size.height)];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSMutableArray *cgColors = [NSMutableArray new];
    [colors enumerateObjectsUsingBlock:^(UIColor *obj, NSUInteger idx, BOOL *stop) {
        [cgColors addObject:(id) obj.CGColor];
    }];
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) [cgColors copy], paths);
    CGColorSpaceRelease(colorSpace);
    
    CGPoint startPoint = (CGPoint) {0, 0};
    CGPoint endPoint = (CGPoint) {0, size.height};
    CGContextDrawLinearGradient(ctx, gradient, startPoint, endPoint, 0);
    CGGradientRelease(gradient);
    
    result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return result;
}

+ (UIImage *)gradientImageWithSize:(CGSize)size paths:(CGFloat[])paths colors:(NSArray<UIColor *> *)colors {
    UIImage * image = [UIImage new];
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(size.width, size.height), NO, 0);
    //调用这个方法的效果应该是将该图片的Context附着在当前Context上
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSMutableArray *cgColors = [NSMutableArray new];
    [colors enumerateObjectsUsingBlock:^(UIColor *obj, NSUInteger idx, BOOL *stop) {
        [cgColors addObject:(id) obj.CGColor];
    }];
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) [cgColors copy], paths);
    CGColorSpaceRelease(colorSpace);
    
    CGPoint startPoint = (CGPoint) {0, 0};
    CGPoint endPoint = (CGPoint) {0, size.height};
    CGContextDrawLinearGradient(ctx, gradient, startPoint, endPoint, 0);
    CGGradientRelease(gradient);
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
@end
