//
//  ImageUploader.h
//  TO-DO
//
//  Created by Siegrain on 16/5/12.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, UploadImageType) {
    UploadImageTypeOriginal,
    UploadImageTypeAvatar
};

/* Qiniu image style */
static NSString* const kImageStyleMidium = @"midium";
static NSString* const kImageStyleSmall = @"small";
static NSString* const kImageStyleThumbnail = @"thumb";

/* 
 upload path prefix
 example: o6yj5t1zc.bkt.clouddn.com/avatar/201605121823348059.jpg-thumb
 */
static NSString* const kUploadPrefixAvatar = @"avatar";

@interface ImageUploader : NSObject
+ (void)uploadImage:(UIImage*)image type:(UploadImageType)type prefix:(NSString*)prefix completion:(void (^)(bool error, NSString* path))completion;
@end
