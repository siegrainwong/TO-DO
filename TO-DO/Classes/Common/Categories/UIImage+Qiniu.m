//
//  UIImage+Qiniu.m
//  TO-DO
//
//  Created by Siegrain on 16/5/18.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "SGAPIKeys.h"
#import "UIImage+AFNetworking.h"
#import "UIImage+Qiniu.h"

@implementation UIImage (Qiniu)
+ (instancetype)qn_imageWithString:(NSString*)string andStyle:(NSString*)style
{
    UIImage* result;
    NSString* url = [NSString stringWithFormat:@"%@%@-%@", kQiniuDomain, string, style];
    NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    result = [UIImage imageWithData:data];

    return result;
}
@end
