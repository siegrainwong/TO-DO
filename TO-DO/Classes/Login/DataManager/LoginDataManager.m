//
//  LoginDataManager.m
//  TO-DO
//
//  Created by Siegrain on 16/5/9.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "AppDelegate.h"
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
#import <AVOSCloud.h>

/* local localization dictionary keys */
static NSString* const kEmailInvalidKey = @"EmailInvalid";
static NSString* const kNameInvalidKey = @"NameInvalid";
static NSString* const kPasswordInvalidKey = @"PasswordInvalid";
static NSString* const kAvatarHaventSelectedKey = @"AvatarHaventSelected";
static NSString* const kAvatarUploadFailedKey = @"AvatarUploadFailed";
static NSInteger const kPasswordIncorrectErrorCodeKey = 210;
static NSInteger const kUserDoesNotExistErrorCodeKey = 211;
static NSInteger const kEmailAlreadyTakenErrorCodeKey = 201;
static NSInteger const kLoginFailCountOverLimitErrorCodeKey = 1;

@implementation LoginDataManager {
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
                        [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"LABEL_NAME", nil), NSLocalizedString(@"VALIDATE_INVALID", nil)]
                         forKey:kNameInvalidKey];
    [_localDictionary setObject:
                        [NSString stringWithFormat:@"%@", NSLocalizedString(@"VALIDATE_NO_AVATAR", nil)]
                         forKey:kAvatarHaventSelectedKey];
    [_localDictionary setObject:
                        [NSString stringWithFormat:@"%@", NSLocalizedString(@"ERROR_AVATAR_UPLOAD_FAILED", nil)]
                         forKey:kAvatarUploadFailedKey];
    [_localDictionary setObject:
                        [NSString stringWithFormat:@"%@%@",
                                                   isSignUp ? NSLocalizedString(@"LABLE_EMAIL", nil) : NSLocalizedString(@"LABEL_USERNAME(EMAIL)", nil), NSLocalizedString(@"VALIDATE_INVALID", nil)]
                         forKey:kEmailInvalidKey];
    [_localDictionary setObject:
                        [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"LABEL_PASSWORD", nil), NSLocalizedString(@"VALIDATE_INCORRECT", nil)]
                         forKey:@(kPasswordIncorrectErrorCodeKey)];
    [_localDictionary setObject:
                        [NSString stringWithFormat:@"%@", NSLocalizedString(@"VALIDATE_USER_DOESNT_EXIST", nil)]
                         forKey:@(kUserDoesNotExistErrorCodeKey)];
    [_localDictionary setObject:
                        [NSString stringWithFormat:@"%@", NSLocalizedString(@"VALIDATE_EMAIL_ALREADY_TAKEN", nil)]
                         forKey:@(kEmailAlreadyTakenErrorCodeKey)];
    [_localDictionary setObject:
                        [NSString stringWithFormat:@"%@", NSLocalizedString(@"VALIDATE_LOGIN_FAILCOUNT_OVERLIMIT", nil)]
                         forKey:@(kLoginFailCountOverLimitErrorCodeKey)];
}
#pragma mark - initial
- (instancetype)init
{
    if (self = [super init]) {
        _localDictionary = [NSMutableDictionary dictionary];
        [self localizeStrings];
    }
    return self;
}
#pragma mark - handle sign up & sign in
- (void)handleCommit:(SGUser*)user isSignUp:(BOOL)signUp complete:(void (^)(bool succeed))complete
{
    isSignUp = signUp;
    if (![self validate:user]) return complete(NO);

    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    // sign in
    if (!isSignUp) {
        [SGUser logInWithUsernameInBackground:user.email
                                     password:user.password
                                        block:^(AVUser* user, NSError* error) {
                                            if (error)
                                                [SCLAlertHelper errorAlertWithContent:_localDictionary[@(error.code)] ? _localDictionary[@(error.code)] : error.localizedDescription];

                                            return complete(!error);
                                        }];
    } else {
        [ImageUploader
          uploadImage:user.avatarImage
                 type:UploadImageTypeAvatar
               prefix:kUploadPrefixAvatar
           completion:^(bool error, NSString* path) {
               if (error) {
                   [SCLAlertHelper errorAlertWithContent:_localDictionary[kAvatarUploadFailedKey]];

                   return complete(NO);
               }

               user.avatar = path;

               [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError* error) {
                   if (error)
                       [SCLAlertHelper errorAlertWithContent:_localDictionary[@(error.code)] ? _localDictionary[@(error.code)] : error.localizedDescription];

                   return complete(!error);
               }];
           }];
    }
}
#pragma mark - validate
- (BOOL)validate:(SGUser*)user
{
    // remove whitespaces
    user.name = [user.name stringByRemovingUnneccessaryWhitespaces];
    user.email = [user.email stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    user.password = [user.password stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if (isSignUp) {
        // avatar validation
        if (!user.avatarImage) {
            [SCLAlertHelper errorAlertWithContent:_localDictionary[kAvatarHaventSelectedKey]];
            return NO;
        }

        // name validation
        if ([SCLAlertHelper errorAlertValidateLengthWithString:user.name minLength:4 maxLength:20 alertName:NSLocalizedString(@"LABEL_NAME", nil)]) {
            return NO;
        } else if (![FieldValidator validateName:user.name]) {
            [SCLAlertHelper errorAlertWithContent:_localDictionary[kNameInvalidKey]];
            return NO;
        }
    }

    // email validation
    if (![FieldValidator validateEmail:user.email]) {
        [SCLAlertHelper errorAlertWithContent:_localDictionary[kEmailInvalidKey]];
        return NO;
    }

    // password validation
    if ([SCLAlertHelper errorAlertValidateLengthWithString:user.password
                                                 minLength:6
                                                 maxLength:20
                                                 alertName:NSLocalizedString(@"LABEL_PASSWORD", nil)]) {
        return NO;
    } else if (![FieldValidator validatePassword:user.password]) {
        [SCLAlertHelper errorAlertWithContent:kPasswordInvalidKey];
        return NO;
    }

    return YES;
}
@end
