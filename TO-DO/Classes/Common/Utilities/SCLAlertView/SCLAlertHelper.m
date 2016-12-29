//
//  SCLAlertHelper.m
//  TO-DO
//
//  Created by Siegrain on 16/5/9.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "NSString+Extension.h"
#import "SCLAlertHelper.h"
#import "SCLAlertView.h"

@implementation SCLAlertHelper
+ (void)errorAlertWithContent:(NSString*)content
{
    SCLAlertView* alert = [[SCLAlertView alloc] initWithNewWindow];
    [alert showError:NSLocalizedString(@"Error", nil) subTitle:content closeButtonTitle:@"OK" duration:0];
}
+ (BOOL)errorAlertValidateLengthWithString:(NSString*)string minLength:(NSUInteger)min maxLength:(NSUInteger)max alertName:(NSString*)name
{
    NSString* validateString = nil;
    NSInteger errorLength = 0;

    if ([string bytesFromString] < min) {
        validateString = NSLocalizedString(@" is too short, minimum is ", nil);
        errorLength = min;
    } else if ([string bytesFromString] > max) {
        validateString = NSLocalizedString(@" is too long, maximum is ", nil);
        errorLength = max;
    }

    if (validateString)
        [self errorAlertWithContent:[NSString stringWithFormat:@"%@%@%ld", name, validateString, (long)errorLength]];

    return (BOOL)validateString;
}

@end
