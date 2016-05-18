//
//  UIImage+Qiniu.h
//  TO-DO
//
//  Created by Siegrain on 16/5/18.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import <UIKit/UIKit.h>

/* Qiniu image style */
static NSString* const kImageStyleMidium = @"midium";
static NSString* const kImageStyleSmall = @"small";
static NSString* const kImageStyleThumbnail = @"thumb";

@interface UIImage (Qiniu)
+ (instancetype)qn_imageWithString:(NSString*)string andStyle:(NSString*)style;
@end
