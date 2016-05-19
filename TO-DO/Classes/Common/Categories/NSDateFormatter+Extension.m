//
//  NSDateFormatter+Extension.m
//  TO-DO
//
//  Created by Siegrain on 16/5/19.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "NSDateFormatter+Extension.h"

@implementation NSDateFormatter (Extension)
+ (instancetype)dateFormatterWithFormatString:(NSString*)format
{
    NSDateFormatter* formatter = [NSDateFormatter new];
    formatter.dateFormat = format;
    return formatter;
}
@end
