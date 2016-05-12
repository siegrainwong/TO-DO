//
//  NSString+Encrytion.h
//  TO-DO
//
//  Created by Siegrain on 16/5/12.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Encrytion)
- (NSString*)md5;
- (NSString*)sha1;
- (NSString*)base64;
- (NSString*)hmacsha1_base64:(NSString*)key;

@end
