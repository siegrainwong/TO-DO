//
//  NSNotificationCenter+Extension.h
//  TO-DO
//
//  Created by Siegrain on 16/5/20.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNotificationCenter (Extension)
+ (void)attachKeyboardObservers:(id)target keyboardWillShowSelector:(SEL)showSelector keyboardWillHideSelector:(SEL)hideSelector;
@end
