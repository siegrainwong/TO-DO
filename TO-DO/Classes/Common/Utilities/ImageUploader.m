//
//  ImageUploader.m
//  TO-DO
//
//  Created by Siegrain on 16/5/12.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "DateUtil.h"
#import "ImageUploader.h"
#import "QiniuSDK.h"
#import "QiniuTokenGenerator.h"
#import "UIImage+Compression.h"

@implementation ImageUploader
#pragma mark - upload methods
+ (void)uploadImage:(UIImage*)image type:(UploadImageType)type prefix:(NSString*)prefix completion:(void (^)(bool error, NSString* path))completion
{
    NSData* imageData = UIImageJPEGRepresentation(image, 0.7);
    UIImage* compressedImage = [UIImage imageWithData:imageData];
    NSUInteger shouldCompressedsize = [self imageShouldCompressedSizeByType:type];
    if (shouldCompressedsize)
        compressedImage = [compressedImage imageCompressForWidth:300];
    imageData = UIImageJPEGRepresentation(compressedImage, 1);

    NSString* url = [NSString stringWithFormat:@"%@/%@%04d.jpg", prefix, [DateUtil dateIdentifierNow], arc4random() % 10000];
    NSString* key = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

    NSString* token = [QiniuTokenGenerator generateToken];
    QNUploadManager* upManager = [[QNUploadManager alloc] init];
    [upManager putData:imageData //upload image data
                   key:key //upload path
                 token:token //upload token
              complete:^(QNResponseInfo* info, NSString* key, NSDictionary* resp) {
                  completion(info.statusCode != 200, key);
              }
                option:nil];
}

#pragma mark - helper
/**
 *  根据上传图片类型决定其需要被压缩的尺寸
 */
+ (NSUInteger)imageShouldCompressedSizeByType:(UploadImageType)type
{
    switch (type) {
        case UploadImageTypeAvatar:
            return 300;

        default:
            break;
    }

    return 0;
}
@end
