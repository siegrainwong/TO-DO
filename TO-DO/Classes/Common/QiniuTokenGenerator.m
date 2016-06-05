//
//  QiniuTokenGenerator.m
//  TO-DO
//
//  Created by Siegrain on 16/5/12.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "NSString+Encrytion.h"
#import "QiniuTokenGenerator.h"

static NSString* const kBucketName = @"sgtodo";

@implementation QiniuTokenGenerator
+ (NSString*)generateToken
{
    NSInteger deadline = (NSInteger)[[[NSDate date] dateByAddingTimeInterval:60 * 60] timeIntervalSince1970];
    NSString* uploadPolicy = [NSString stringWithFormat:@"{\"scope\":\"%@\",\"deadline\":%ld}", kBucketName, (long)deadline];

    NSString* encoded = [uploadPolicy base64];
    NSString* encodedSigned = [encoded hmacsha1_base64:@"fr9pgEGk8HpUrwZzcyI4ZGHB1QK-bP9-6ksYyTzN"];

    NSString* token = [NSString stringWithFormat:@"%@:%@:%@", @"8Xq81lMXRoiVvWToPuxTu3x0_vpk0d0qdZLQ2si-", encodedSigned, encoded];

    return token;
}
@end
