//
//  HSDatePickerViewController+Configure.m
//  TO-DO
//
//  Created by Siegrain on 16/5/27.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "HSDatePickerViewController+Configure.h"
#import "Macros.h"
#import "NSDateFormatter+Extension.h"

@implementation HSDatePickerViewController (Configure)
- (void)configure
{
    if (isChina) {
        self.dateFormatter = [NSDateFormatter dateFormatterWithFormatString:@"MMM d ccc"];
        self.monthAndYearLabelDateFormater = [NSDateFormatter dateFormatterWithFormatString:@"yyyy MMMM"];
    }
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
}
@end
