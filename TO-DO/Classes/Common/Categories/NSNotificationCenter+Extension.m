//
//  NSNotificationCenter+Extension.m
//  TO-DO
//
//  Created by Siegrain on 16/5/20.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "NSNotificationCenter+Extension.h"
#import <UIKit/UIKit.h>

@implementation NSNotificationCenter (Extension)
+ (void)attachKeyboardObservers:(id)target keyboardWillShowSelector:(SEL)showSelector keyboardWillHideSelector:(SEL)hideSelector
{
    [[self defaultCenter] addObserver:target
                             selector:showSelector
                                 name:UIKeyboardWillShowNotification
                               object:nil];
    [[self defaultCenter] addObserver:target
                             selector:hideSelector
                                 name:UIKeyboardWillHideNotification
                               object:nil];
}
@end
