//
//  NSString+Encrytion.m
//  TO-DO
//
//  Created by Siegrain on 16/5/12.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "GTMBase64.h"
#import "NSString+Encrytion.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>

@implementation NSString (Encrytion)

- (NSString*)md5
{
    const char* cStr = [self UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (unsigned int)strlen(cStr), digest);

    NSMutableString* output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];

    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];

    return output;
}

- (NSString*)sha1
{
    const char* cstr = [self cStringUsingEncoding:NSUTF8StringEncoding];
    NSData* data = [NSData dataWithBytes:cstr length:self.length];

    uint8_t digest[CC_SHA1_DIGEST_LENGTH];

    CC_SHA1(data.bytes, (unsigned int)data.length, digest);

    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];

    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];

    return output;
}

- (NSString*)hmacsha1_base64:(NSString*)key
{
    const char* cKey = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char* cData = [self cStringUsingEncoding:NSASCIIStringEncoding];
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSData* HMACData = [NSData dataWithBytes:cHMAC length:sizeof(cHMAC)];
    //这里要用网络安全的加密方式，否则加密后的base64字符串中有"/"符号
    NSString* hash = [GTMBase64 stringByWebSafeEncodingData:HMACData padded:YES];

    return hash;
}

- (NSString*)base64
{
    NSData* data = [self dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    data = [GTMBase64 encodeData:data];
    NSString* output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return output;
}
@end
