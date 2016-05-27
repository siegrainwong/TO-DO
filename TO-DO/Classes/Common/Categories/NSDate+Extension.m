//
//  NSDate+Extension.m
//  TO-DO
//
//  Created by Siegrain on 16/5/24.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "DateUtil.h"
#import "NSDate+Extension.h"

@implementation NSDate (Extension)
- (NSString*)stringInYearMonthDay
{
    return [DateUtil dateString:self withFormat:@"yyyy-MM-dd"];
}
- (NSDate*)dateInYearMonthDay
{
    return [DateUtil stringToDate:[self stringInYearMonthDay] format:@"yyyy-MM-dd"];
}
@end
