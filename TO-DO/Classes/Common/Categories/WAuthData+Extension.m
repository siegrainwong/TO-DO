//
//  WAuthData+Extension.m
//  TO-DO
//
//  Created by Siegrain on 16/5/11.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "WAuthData+Extension.h"

@implementation WAuthData (Extension)
/**
 *  获取去掉权限信息的uid
 *
 *  @return <#return value description#>
 */
- (NSString*)suid
{
    return [self.uid stringByReplacingOccurrencesOfString:@"simplelogin:" withString:@""];
}
@end
