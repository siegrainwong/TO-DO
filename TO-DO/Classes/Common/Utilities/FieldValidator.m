//
//  ValidateUtil.m
//  TO-DO
//
//  Created by Siegrain on 16/5/9.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "FieldValidator.h"

@implementation FieldValidator
//邮箱
+ (BOOL)validateEmail:(NSString*)email
{
    NSString* emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate* emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

//用户名
+ (BOOL)validateUserName:(NSString*)name
{
    NSString* userNameRegex = @"^[A-Za-z0-9]+$";
    NSPredicate* userNamePredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", userNameRegex];
    BOOL B = [userNamePredicate evaluateWithObject:name];
    return B;
}

//密码
+ (BOOL)validatePassword:(NSString*)passWord
{
    NSString* passWordRegex = @"^[a-zA-Z0-9]+$";
    NSPredicate* passWordPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", passWordRegex];
    return [passWordPredicate evaluateWithObject:passWord];
}

//昵称
+ (BOOL)validateNickname:(NSString*)nickname
{
    NSString* nicknameRegex = @"^[\u4e00-\u9fa5]+$";
    NSPredicate* passWordPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", nicknameRegex];
    return [passWordPredicate evaluateWithObject:nickname];
}

//验证中文英文数字
+ (BOOL)validateName:(NSString*)name
{
    NSString* regex = @"^[\u4e00-\u9fa5A-Za-z0-9\\s*]+$";
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [predicate evaluateWithObject:name];
}

//身份证号
+ (BOOL)validateIdentityCard:(NSString*)identityCard
{
    BOOL flag;
    if (identityCard.length <= 0) {
        flag = NO;
        return flag;
    }
    NSString* regex2 = @"^(\\d{14}|\\d{17})(\\d|[xX])$";
    NSPredicate* identityCardPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex2];
    return [identityCardPredicate evaluateWithObject:identityCard];
}
@end
