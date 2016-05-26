//
//  HSDatePickerViewController+configure.m
//  TO-DO
//
//  Created by Siegrain on 16/5/26.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "HSDatePickerViewController+configure.h"
#import "Macros.h"
#import "NSDateFormatter+Extension.h"

@implementation HSDatePickerViewController (configure)
- (void)configure
{
    self.minDate = [[NSDate date] dateByAddingTimeInterval:-60 * 60];
    if (isChina) {
        self.dateFormatter = [NSDateFormatter dateFormatterWithFormatString:@"MMM d ccc"];
        self.monthAndYearLabelDateFormater = [NSDateFormatter dateFormatterWithFormatString:@"yyyy MMMM"];
    }
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
}
@end
