//
//  SGImageUpload.h
//  TO-DO
//
//  Created by Siegrain on 16/5/12.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, SGImageType) {
    SGImageTypeOriginal,
    SGImageTypeAvatar,
    SGImageTypePhoto
};

static float const kSGDefaultImageQuality = 0.7;

/* 
 upload path prefix
 example: o6yj5t1zc.bkt.clouddn.com/avatar/201605121823348059.jpg-thumb
 */
static NSString *const kUploadPrefixAvatar = @"avatar/";
static NSString *const kUploadPrefixUser = @"user/";

@interface SGImageUpload : NSObject
+ (void)uploadImage:(UIImage *)image type:(SGImageType)type prefix:(NSString *)prefix completion:(void (^)(bool error, NSString *path))completion;

+ (NSData *)dataWithImage:(UIImage *)image type:(SGImageType)type quality:(float)quality;
@end
