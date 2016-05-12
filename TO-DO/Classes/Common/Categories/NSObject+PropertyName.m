//
//  NSObject+PropertyName.m
//  TO-DO
//
//  Created by Siegrain on 16/5/10.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "NSObject+PropertyName.h"
#import <objc/runtime.h>

@implementation NSObject (PropertyName)
- (NSString*)stringWithProperty:(id)property
{
    NSString* name = nil;

    uint32_t ivarCount;

    Ivar* ivars = class_copyIvarList([self class], &ivarCount);

    if (ivars) {
        for (uint32_t i = 0; i < ivarCount; i++) {
            Ivar ivar = ivars[i];

            name = [NSString stringWithUTF8String:ivar_getName(ivar)];
            if ([self valueForKey:name] == property) {
                break;
            }
        }

        free(ivars);
    }

    if ([name characterAtIndex:0] == '_') {
        name = [name stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
    }

    return name;
}
@end
