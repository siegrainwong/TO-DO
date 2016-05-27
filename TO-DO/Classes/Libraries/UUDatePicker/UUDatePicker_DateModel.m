//
//  UUDatePicker_DateModel.m
//  text_datepicker
//
//  Created by shake on 14-9-17.
//  Copyright (c) 2014年 uyiuyao. All rights reserved.
//

#import "UUDatePicker_DateModel.h"

@implementation UUDatePicker_DateModel

- (id)initWithDate:(NSDate *)date
{
    self = [super init];
    if (self) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyyMMddHHmm"];
        NSString *dateString = [formatter stringFromDate:date];

        self.year     = [dateString substringWithRange:NSMakeRange(0, 4)];
        self.month    = [dateString substringWithRange:NSMakeRange(4, 2)];
        self.day      = [dateString substringWithRange:NSMakeRange(6, 2)];
        self.hour     = [dateString substringWithRange:NSMakeRange(8, 2)];
        self.minute   = [dateString substringWithRange:NSMakeRange(10, 2)];
    }
    return self;
}

@end
