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
#import "LCUser.h"
#import "LoginDataManager.h"
#import "Macros.h"
#import "NSObject+PropertyName.h"
#import "NSString+Extension.h"
#import "SCLAlertHelper.h"
#import "SCLAlertView.h"
#import <AVOSCloud.h>

/* localization dictionary keys */
static NSString* const kEmailInvalidKey = @"EmailInvalid";
static NSString* const kNameInvalidKey = @"NameInvalid";
static NSString* const kPasswordInvalidKey = @"PasswordInvalid";
static NSString* const kAvatarHaventSelectedKey = @"AvatarHaventSelected";
static NSString* const kPictureUploadFailedKey = @"PictureUploadFailed";
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
    _localDictionary[kPasswordInvalidKey] = ConcatLocalizedString1(@"Password", @" is invalid");
    _localDictionary[kNameInvalidKey] = ConcatLocalizedString1(@"Name", @" is invalid");
    _localDictionary[kAvatarHaventSelectedKey] = NSLocalizedString(@"Please select your avatar", nil);
    _localDictionary[kPictureUploadFailedKey] = NSLocalizedString(@"Failed to upload picture, please try again", nil);
    _localDictionary[kEmailInvalidKey] = ConcatLocalizedString1(isSignUp ? @"Name" : @"Username(Email)", @" is invalid");
    _localDictionary[@(kPasswordIncorrectErrorCodeKey)] = ConcatLocalizedString1(@"Password", @" is invalid");
    _localDictionary[@(kUserDoesNotExistErrorCodeKey)] = NSLocalizedString(@"User doesn't exist", nil);
    _localDictionary[@(kEmailAlreadyTakenErrorCodeKey)] = NSLocalizedString(@"Email has already been taken", nil);
    _localDictionary[@(kLoginFailCountOverLimitErrorCodeKey)] = NSLocalizedString(@"Failed login count over limit, reset your password or try again later(15 mins)", nil);
}
#pragma mark - initial
- (instancetype)init
{
    if (self = [super init]) {
        _localDictionary = [NSMutableDictionary new];
        [self localizeStrings];
    }
    return self;
}
#pragma mark - handle sign up & sign in
- (void)handleCommit:(LCUser*)user isSignUp:(BOOL)signUp complete:(void (^)(bool succeed))complete
{
    isSignUp = signUp;
    if (![self validate:user]) return complete(NO);

    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    // sign in
    if (!isSignUp) {
        [LCUser logInWithUsernameInBackground:user.email password:user.password block:^(AVUser* user, NSError* error) {
            if (error)
                [SCLAlertHelper errorAlertWithContent:_localDictionary[@(error.code)] ? _localDictionary[@(error.code)] : error.localizedDescription];

            return complete(!error);
        }];
    } else {
        [ImageUploader uploadImage:user.avatarImage type:UploadImageTypeAvatar prefix:kUploadPrefixAvatar completion:^(bool error, NSString* path) {
            if (error) {
                [SCLAlertHelper errorAlertWithContent:_localDictionary[kPictureUploadFailedKey]];

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
- (BOOL)validate:(LCUser*)user
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
        if ([SCLAlertHelper errorAlertValidateLengthWithString:user.name minLength:4 maxLength:20 alertName:NSLocalizedString(@"Name", nil)]) {
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
    if ([SCLAlertHelper errorAlertValidateLengthWithString:user.password minLength:6 maxLength:20 alertName:NSLocalizedString(@"Password", nil)]) {
        return NO;
    } else if (![FieldValidator validatePassword:user.password]) {
        [SCLAlertHelper errorAlertWithContent:kPasswordInvalidKey];
        return NO;
    }

    return YES;
}
@end
