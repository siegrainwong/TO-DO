//
//  ImageUploader.m
//  TO-DO
//
//  Created by Siegrain on 16/5/12.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "ImageUploader.h"
#import "QiniuSDK.h"
#import "QiniuTokenGenerator.h"

@implementation ImageUploader
+ (void)uploadImage:(UIImage*)image prefix:(NSString*)prefix
{
    NSData* imageData = UIImageJPEGRepresentation(image, 0.5);

    NSString* url = [NSString stringWithFormat:@"%@/%@%04d.jpg", prefix, dateTime, arc4random() % 10000];
    NSString* key = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    NSString* token = [QiniuTokenGenerator generateToken];
    QNUploadManager* upManager = [[QNUploadManager alloc] init];
    [upManager putData:imageData
                   key:@"hello"
                 token:token
              complete:^(QNResponseInfo* info, NSString* key, NSDictionary* resp) {
                  NSLog(@"%@", info);
                  NSLog(@"%@", resp);
              }
                option:nil];
}
@end
