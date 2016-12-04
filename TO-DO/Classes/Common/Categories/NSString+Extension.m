//
//  NSString+Extension.m
//  TO-DO
//
//  Created by Siegrain on 16/5/10.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "NSString+Extension.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (Extension)
- (NSString *)stringByRemovingUnnecessaryWhitespaces {
    NSCharacterSet *whitespaces = [NSCharacterSet whitespaceCharacterSet];
    NSPredicate *noEmptyStrings = [NSPredicate predicateWithFormat:@"SELF != ''"];
    
    NSArray *parts = [self componentsSeparatedByCharactersInSet:whitespaces];
    NSArray *filteredArray = [parts filteredArrayUsingPredicate:noEmptyStrings];
    
    return [filteredArray componentsJoinedByString:@" "];
}

- (NSInteger)bytesFromString {
    int unicode = 0;
    for (int i = 0; i < [self length]; i++) {
        int a = [self characterAtIndex:i];
        if (a >= 0x4e00 && a <= 0x9fff)
            unicode++;
    }
    NSInteger length = [self length] + unicode;
    return length;
}

@end
