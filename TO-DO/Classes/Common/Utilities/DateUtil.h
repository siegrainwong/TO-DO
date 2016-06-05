//
//  DateUtil.h
//  zhihuDaily
//
//  Created by Siegrain on 16/3/16.
//  Copyright © 2016年 siegrain.zhihuDaily. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSInteger const kTimeIntervalHour = 60 * 60;
static NSInteger const kTimeIntervalDay = kTimeIntervalHour * 24;

@interface DateUtil : NSObject
+ (NSDateFormatter*)sharedDateFormatter;

/*字符串转NSDate*/
+ (NSDate*)stringToDate:(NSString*)dateString format:(NSString*)format;
/*获取该NSDate中的日期部分*/
+ (NSDate*)dateInYearMonthDay:(NSDate*)date;
/*NSDate转字符串*/
+ (NSString*)dateString:(NSDate*)date withFormat:(NSString*)format;
/*获取当前的时间标识*/
+ (NSString*)dateIdentifierNow;
/*从某个格式的时间字符串转到另一个格式的时间字符串*/
+ (NSString*)dateString:(NSString*)originalStr
             fromFormat:(NSString*)fromFormat
               toFormat:(NSString*)toFormat;
/*获取尽量短的本地化时间字符串*/
+ (NSString*)localizedShortDateString:(NSDate*)date;
+ (NSString*)localizedShortDateStringFromInterval:(NSTimeInterval)interval;
/*获取两个日期之间的DateComponent*/
+ (NSDateComponents*)componentsBetweenDate:(NSDate*)date andDate:(NSDate*)otherDate;
/*根据ISO8601时间返回NSDate*/
+ (NSDate*)dateFromISO8601String:(NSString*)string;
@end
