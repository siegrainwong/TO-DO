//
//  CreateDataManager.m
//  TO-DO
//
//  Created by Siegrain on 16/5/21.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "CreateDataManager.h"
#import "SGTodo.h"

/* localization dictionary keys */
static NSString* const kEmailInvalidKey = @"EmailInvalid";
static NSString* const kNameInvalidKey = @"NameInvalid";
static NSString* const kPasswordInvalidKey = @"PasswordInvalid";
static NSString* const kAvatarHaventSelectedKey = @"AvatarHaventSelected";
static NSString* const kAvatarUploadFailedKey = @"AvatarUploadFailed";

@implementation CreateDataManager
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
#pragma mark - validate
- (BOOL)validate:(SGTodo*)todo
{
    //	// remove whitespaces
    //	user.name = [user.name stringByRemovingUnneccessaryWhitespaces];
    //	user.email = [user.email stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    //	user.password = [user.password stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    //
    //	if (isSignUp) {
    //		// avatar validation
    //		if (!user.avatarImage) {
    //			[SCLAlertHelper errorAlertWithContent:_localDictionary[kAvatarHaventSelectedKey]];
    //			return NO;
    //		}
    //
    //		// name validation
    //		if ([SCLAlertHelper errorAlertValidateLengthWithString:user.name minLength:4 maxLength:20 alertName:NSLocalizedString(@"LABEL_NAME", nil)]) {
    //			return NO;
    //		} else if (![FieldValidator validateName:user.name]) {
    //			[SCLAlertHelper errorAlertWithContent:_localDictionary[kNameInvalidKey]];
    //			return NO;
    //		}
    //	}
    //
    //	// email validation
    //	if (![FieldValidator validateEmail:user.email]) {
    //		[SCLAlertHelper errorAlertWithContent:_localDictionary[kEmailInvalidKey]];
    //		return NO;
    //	}
    //
    //	// password validation
    //	if ([SCLAlertHelper errorAlertValidateLengthWithString:user.password
    //												 minLength:6
    //												 maxLength:20
    //												 alertName:NSLocalizedString(@"LABEL_PASSWORD", nil)]) {
    //		return NO;
    //	} else if (![FieldValidator validatePassword:user.password]) {
    //		[SCLAlertHelper errorAlertWithContent:kPasswordInvalidKey];
    //		return NO;
    //	}

    return YES;
}
@end
