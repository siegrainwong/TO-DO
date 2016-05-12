//
//  LoginDataManager.m
//  TO-DO
//
//  Created by Siegrain on 16/5/9.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "DataKeys.h"
#import "FieldValidator.h"
#import "ImageUploader.h"
#import "LoginDataManager.h"
#import "Macros.h"
#import "NSObject+PropertyName.h"
#import "NSString+Extension.h"
#import "SCLAlertHelper.h"
#import "SCLAlertView.h"
#import "SGUser.h"
#import "WAuthData+Extension.h"
#import "Wilddog.h"

/* localization dictionary keys */
static NSString* const kEmailInvalidKey = @"EmailInvalid";
static NSString* const kAvatarHaventSelectedKey = @"AvatarHaventSelected";
static NSString* const kNameInvalidKey = @"NameInvalid";
static NSString* const kPasswordInvalidKey = @"PasswordInvalid";
static NSString* const kUsernameOrPasswordIncorrectKey = @"UsernameOrPasswordIncorrect";

@implementation LoginDataManager {
    Wilddog* usersDataRef;
    BOOL isSignUp;
}
@synthesize localDictionary = _localDictionary;

#pragma mark - localization
- (void)localizeStrings
{
    [_localDictionary setObject:
                        [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"LABLE_PASSWORD", nil), NSLocalizedString(@"VALIDATE_INVALID", nil)]
                         forKey:kPasswordInvalidKey];
    [_localDictionary setObject:
                        [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"LABEL_USERNAME(EMAIL)", nil), NSLocalizedString(@"VALIDATE_INCORRECT", nil)]
                         forKey:kUsernameOrPasswordIncorrectKey];
    [_localDictionary setObject:
                        [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"LABEL_NAME", nil), NSLocalizedString(@"VALIDATE_INVALID", nil)]
                         forKey:kNameInvalidKey];
    [_localDictionary setObject:
                        [NSString stringWithFormat:@"%@", NSLocalizedString(@"VALIDATE_NO_AVATAR", nil)]
                         forKey:kAvatarHaventSelectedKey];
    [_localDictionary setObject:
                        [NSString stringWithFormat:@"%@%@",
                                                   isSignUp ? NSLocalizedString(@"LABLE_EMAIL", nil) : NSLocalizedString(@"LABEL_USERNAME(EMAIL)", nil), NSLocalizedString(@"VALIDATE_INVALID", nil)]
                         forKey:kEmailInvalidKey];
}
#pragma mark - initial
- (instancetype)init
{
    if (self = [super init]) {
        usersDataRef = [[Wilddog alloc]
          initWithUrl:[NSString stringWithFormat:@"%@/%@", kWilddogConnectionString, kDATAKEY_USERS]];
        _localDictionary = [NSMutableDictionary dictionary];
        [self localizeStrings];
    }
    return self;
}
#pragma mark - handle sign up & sign in
- (void)handleCommit:(SGUser*)user isSignUp:(BOOL)signUp completion:(void (^)(bool error))completion
{
    isSignUp = signUp;

    [ImageUploader uploadImage:user.avatarImage];

    [self validateUser:user
            completion:^(Wilddog* userRef) {
                if (!userRef) {
                    if (completion) completion(YES);
                    return;
                }

                if (isSignUp) {
                    //TODO: upload avatar

                    // record user information
                    [userRef setValue:[user toDictionary]
                      withCompletionBlock:^(NSError* error, Wilddog* ref) {
                          if (completion) completion(NO);
                      }];
                } else {
                    // update last login time
                    [userRef updateChildValues:[user toDictionaryWithKeys:@[ PropertyName(user, user.lastLoginTime) ]]];
                    if (completion) completion(NO);
                }
            }];
}
#pragma mark - validate
/**
 *  验证用户数据有效性
 *
 *  @param completion 若为注册操作则参数返回新用户实体，若为登录操作则参数返回该用户实体，为空表明验证失败
 */
- (void)validateUser:(SGUser*)user completion:(void (^)(Wilddog* userRef))completion
{
    NSAssert(completion, @"completion must not be nil!");
    // local validate
    //
    if (isSignUp) {
        // avatar validation
        if (!user.avatarImage) {
            [SCLAlertHelper errorAlertWithContent:_localDictionary[kAvatarHaventSelectedKey]];
            return completion(nil);
        }

        // name validation
        if ([SCLAlertHelper errorAlertValidateLengthWithString:user.name minLength:4 maxLength:20 alertName:NSLocalizedString(@"LABEL_NAME", nil)]) {
            return completion(nil);
        } else if (![FieldValidator validateName:user.name]) {
            [SCLAlertHelper errorAlertWithContent:_localDictionary[kNameInvalidKey]];
            return completion(nil);
        }
    }
    // remove whitespaces
    user.name = [user.name stringByRemovingUnneccessaryWhitespaces];
    user.email = [user.email stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    user.password = [user.password stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    // email validation
    if (![FieldValidator validateEmail:user.email]) {
        [SCLAlertHelper errorAlertWithContent:_localDictionary[kEmailInvalidKey]];
        return completion(nil);
    }

    // password validation
    if ([SCLAlertHelper errorAlertValidateLengthWithString:user.password
                                                 minLength:6
                                                 maxLength:20
                                                 alertName:NSLocalizedString(@"LABEL_PASSWORD", nil)]) {
        return completion(nil);
    } else if (![FieldValidator validatePassword:user.password]) {
        [SCLAlertHelper errorAlertWithContent:kPasswordInvalidKey];
        return completion(nil);
    }

    // server validate
    //
    if (!isSignUp) {
        // validate with wilddog user authorization
        [usersDataRef authUser:user.email
                      password:user.password
           withCompletionBlock:^(NSError* error, WAuthData* authData) {
               if (error) {
                   [SCLAlertHelper errorAlertWithContent:kUsernameOrPasswordIncorrectKey];
                   return completion(nil);
               }

               // retrieve user data and return
               [[usersDataRef childByAppendingPath:authData.suid]
                 observeSingleEventOfType:WEventTypeValue
                                withBlock:^(WDataSnapshot* snapshot) {
                                    return completion(snapshot.ref);
                                }];
           }];
    } else {
        // create user on wilddog user database
        [usersDataRef createUser:user.email
                          password:user.password
          withValueCompletionBlock:^(NSError* error, NSDictionary* result) {
              if (error) {
                  [SCLAlertHelper errorAlertWithContent:error.localizedDescription];
                  return completion(nil);
              }

              NSString* suid = [result[@"uid"] stringByReplacingOccurrencesOfString:@"simplelogin:" withString:@""];
              return completion([usersDataRef childByAppendingPath:suid]);
          }];
    }
}

#pragma mark - release
- (void)dealloc
{
    [usersDataRef removeAllObservers];
}
@end
