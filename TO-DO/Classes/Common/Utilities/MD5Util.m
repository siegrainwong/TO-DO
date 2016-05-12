//
//  MD5Util.m
//  zhihuDaily
//
//  Created by Siegrain on 16/3/17.
//  Copyright © 2016年 siegrain.zhihuDaily. All rights reserved.
//

#import "MD5Util.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation MD5Util
+ (NSString*)MD5ByAStr:(NSString*)aSourceStr
{
    const char* cStr = [aSourceStr UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (unsigned int)strlen(cStr), result);

    NSMutableString* ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH];
    for (NSInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02X", result[i]];
    }

    return ret;
}
@end
