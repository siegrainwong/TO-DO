//
//  QiniuTokenGenerator.m
//  TO-DO
//
//  Created by Siegrain on 16/5/12.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "NSString+Encrytion.h"
#import "QiniuTokenGenerator.h"

@implementation QiniuTokenGenerator
+ (NSString *)generateToken {
    NSInteger deadline = (NSInteger) [[[NSDate date] dateByAddingTimeInterval:60 * 60] timeIntervalSince1970];
    NSString *uploadPolicy = [NSString stringWithFormat:@"{\"scope\":\"%@\",\"deadline\":%ld}", kQiniuBucketName, (long) deadline];
    
    NSString *encoded = [uploadPolicy base64];
    NSString *encodedSigned = [encoded hmacsha1_base64:kQiniuSK];
    
    NSString *token = [NSString stringWithFormat:@"%@:%@:%@", kQiniuAK, encodedSigned, encoded];
    
    return token;
}
@end
