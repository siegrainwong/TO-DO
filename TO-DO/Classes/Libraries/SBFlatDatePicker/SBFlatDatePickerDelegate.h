//
//  SBFlatDatePickerDelegate.h
//  SBFlatDatePicker
//
//  Created by Solomon Bier on 2/19/15.
//  Copyright (c) 2015 Solomon Bier. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SBFlatDatePicker;

//Protocol to return the date
@protocol SBFLatDatePickerDelegate <NSObject>

@optional
- (void)flatDatePicker:(SBFlatDatePicker *)datePicker saveDate:(NSDate *)date;

@end
