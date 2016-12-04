//
//  NSString+Extension.h
//  TO-DO
//
//  Created by Siegrain on 16/5/10.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Extension)
/**
 *  移除字符串中多余的空格
 *
 *  @return <#return value description#>
 */
- (NSString*)stringByRemovingUnnecessaryWhitespaces;
/**
 *  获取字符串的字节数（ASCII占1位，Unicode等中文字符占2位）
 *
 *  @return <#return value description#>
 */
- (NSInteger)bytesFromString;


@end
