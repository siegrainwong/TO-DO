//
//  ValidateUtil.h
//  TO-DO
//
//  Created by Siegrain on 16/5/9.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FieldValidator : NSObject
+ (BOOL)validateEmail:(NSString*)email;
+ (BOOL)validateUserName:(NSString*)name;
+ (BOOL)validatePassword:(NSString*)passWord;
+ (BOOL)validateNickname:(NSString*)nickname;
+ (BOOL)validateName:(NSString*)name;
+ (BOOL)validateIdentityCard:(NSString*)identityCard;
@end
