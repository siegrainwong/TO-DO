//
//  SGImageUpload.m
//  TO-DO
//
//  Created by Siegrain on 16/5/12.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "DateUtil.h"
#import "SGImageUpload.h"
#import "QiniuSDK.h"
#import "QiniuTokenGenerator.h"
#import "UIImage+Compression.h"

@implementation SGImageUpload
#pragma mark - upload methods

+ (void)uploadImage:(UIImage *)image type:(SGImageType)type prefix:(NSString *)prefix completion:(void (^)(bool error, NSString *path))completion {
    NSData *imageData = [self dataWithImage:image type:type quality:kSGDefaultImageQuality];
    NSString *url = [NSString stringWithFormat:@"%@%@%04d.jpg", prefix, [DateUtil dateIdentifierNow], arc4random() % 10000];
    NSString *key = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSString *token = [QiniuTokenGenerator generateToken];
    QNUploadManager *upManager = [[QNUploadManager alloc] init];
    [upManager putData:imageData key:key token:token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
        completion(info.statusCode != 200, key);
    } option:nil];
}

#pragma mark - helper

/**
 *  根据上传图片类型决定其需要被压缩的尺寸
 */
+ (NSUInteger)shouldCompressedSizeByType:(SGImageType)type {
    switch (type) {
        case SGImageTypeAvatar:
            return 300;
        case SGImageTypePhoto:
            return 600;
        case SGImageTypeOriginal:
            return 0;
        default:
            break;
    }
    
    return 0;
}

+ (NSData *)dataWithImage:(UIImage *)image type:(SGImageType)type quality:(float)quality {
    NSUInteger shouldCompressedSize = [self shouldCompressedSizeByType:type];
    UIImage *result = nil;
    if (shouldCompressedSize) result = [image imageCompressForWidth:shouldCompressedSize];
    return UIImageJPEGRepresentation(result, quality);
}
@end
