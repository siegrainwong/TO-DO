//
//  LoginDataManager.m
//  TO-DO
//
//  Created by Siegrain on 16/5/9.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "AppDelegate.h"
#import "CDUser.h"
#import "SGAPIKeys.h"
#import "FieldValidator.h"
#import "SGImageUpload.h"
#import "LCUser.h"
#import "LCUserDataManager.h"
#import "MRUserDataManager.h"
#import "NSObject+PropertyName.h"
#import "NSString+Extension.h"
#import "SCLAlertHelper.h"
#import "SCLAlertView.h"
#import "MRTodoDataManager.h"
#import <AVOSCloud.h>

/* localization dictionary keys */
static NSString *const kEmailInvalidKey = @"EmailInvalid";
static NSString *const kNameInvalidKey = @"NameInvalid";
static NSString *const kPasswordInvalidKey = @"PasswordInvalid";
static NSString *const kAvatarHaventSelectedKey = @"AvatarHaventSelected";
static NSString *const kPictureUploadFailedKey = @"PictureUploadFailed";
static NSString *const kNetworkUnreachable = @"kNetworkUnreachable";
static NSInteger const kPasswordIncorrectErrorCodeKey = 210;
static NSInteger const kUserDoesNotExistErrorCodeKey = 211;
static NSInteger const kEmailAlreadyTakenErrorCodeKey = 201;
static NSInteger const kLoginFailCountOverLimitErrorCodeKey = 1;

@interface
LCUserDataManager ()
@end

@implementation LCUserDataManager
@synthesize localDictionary = _localDictionary;
#pragma mark - localization

- (void)localizeStrings {
    _localDictionary[kNetworkUnreachable] = Localized(@"Please check your network connection");
    _localDictionary[kPasswordInvalidKey] = ConcatLocalizedString1(@"Password", @" is invalid");
    _localDictionary[kNameInvalidKey] = ConcatLocalizedString1(@"Name", @" is invalid");
    _localDictionary[kAvatarHaventSelectedKey] = NSLocalizedString(@"Please select your avatar", nil);
    _localDictionary[kPictureUploadFailedKey] = NSLocalizedString(@"Failed to upload picture, please try again", nil);
    _localDictionary[kEmailInvalidKey] = ConcatLocalizedString1(_isSignUp ? @"Name" : @"Username(Email)", @" is invalid");
    _localDictionary[@(kPasswordIncorrectErrorCodeKey)] = ConcatLocalizedString1(@"Password", @" is invalid");
    _localDictionary[@(kUserDoesNotExistErrorCodeKey)] = NSLocalizedString(@"User doesn't exist", nil);
    _localDictionary[@(kEmailAlreadyTakenErrorCodeKey)] = NSLocalizedString(@"Email has already been taken", nil);
    _localDictionary[@(kLoginFailCountOverLimitErrorCodeKey)] = NSLocalizedString(@"Failed login count over limit, reset your password or try again later(15 mins)", nil);
}

#pragma mark - initial

- (instancetype)init {
    if (self = [super init]) {
        _localDictionary = [NSMutableDictionary new];
        [self localizeStrings];
    }
    return self;
}

#pragma mark - handle sign up & sign in

- (void)commitWithUser:(LCUser *)user isSignUp:(BOOL)signUp complete:(SGUserResponse)complete {
    _isSignUp = signUp;
    if (![self validateWithUser:user isModify:NO]) return complete(NO, @"字段验证失败");
    
    MRUserDataManager *mrUserDataManager = [MRUserDataManager new];
    
    __weak __typeof(self) weakSelf = self;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    if (!_isSignUp) {   // sign in
        [LCUser logInWithUsernameInBackground:user.email password:user.password block:^(AVUser *user, NSError *error) {
            if (error) {
                [SCLAlertHelper errorAlertWithContent:_localDictionary[@(error.code)] ? _localDictionary[@(error.code)] : error.localizedDescription];
                return complete(NO, error.localizedDescription);
            }
            
            if (![CDUser userWithLCUser:(LCUser *) user]) [mrUserDataManager createUserByLCUser:(LCUser *) user];   //本地没有用户记录就创建
            return complete(YES, nil);
        }];
    } else {    //sign up
        //upload avatar
        [SGImageUpload uploadImage:user.avatarImage type:SGImageTypeAvatar prefix:kUploadPrefixAvatar completion:^(bool error, NSString *path) {
            if (error) {
                [SCLAlertHelper errorAlertWithContent:_localDictionary[kPictureUploadFailedKey]];
                
                return complete(NO, _localDictionary[kPictureUploadFailedKey]);
            }
            
            user.avatar = path;
            user.avatarImage = nil;
            [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {
                    [SCLAlertHelper errorAlertWithContent:_localDictionary[@(error.code)] ? _localDictionary[@(error.code)] : error.localizedDescription];
                    return complete(NO, error.localizedDescription);
                }
                CDUser *cdUser = [mrUserDataManager createUserByLCUser:user];
                [weakSelf insertPilotDataWithUser:cdUser];
                return complete(YES, nil);
            }];
        }];
    }
}

#pragma mark - modify user

- (void)modifyWithUser:(LCUser *)user complete:(void (^)(bool succeed))complete {
    if (![self validateWithUser:user isModify:YES]) return complete(NO);
    [SGHelper waitingAlert];
    [[AppDelegate globalDelegate].lcUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [SGHelper dismissAlert];
        if (error) {
            [SCLAlertHelper errorAlertWithContent:error.localizedDescription];
            return complete(NO);
        }
        
        CDUser *cdUser = [AppDelegate globalDelegate].cdUser;
        cdUser.username = user.username;
        cdUser.email = user.email;
        cdUser.name = user.name;
        
        MR_saveAndWait();
        return complete(YES);
    }];
}

#pragma mark - validate

- (BOOL)validateWithUser:(LCUser *)user isModify:(BOOL)isModify {
    if (isNetworkUnreachable) {
        [SCLAlertHelper errorAlertWithContent:_localDictionary[kNetworkUnreachable]];
        return NO;
    }
    
    // remove whitespaces
    user.name = [user.name stringByRemovingUnnecessaryWhitespaces];
    user.email = [user.email stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    user.password = [user.password stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (_isSignUp) {
        // avatar validation
        if (!user.avatarImage) {
            [SCLAlertHelper errorAlertWithContent:_localDictionary[kAvatarHaventSelectedKey]];
            return NO;
        }
        
        // name validation
        if ([SCLAlertHelper errorAlertValidateLengthWithString:user.name minLength:4 maxLength:kMaxLengthOfUserName alertName:NSLocalizedString(@"Name", nil)]) {
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
    
    if (!isModify) {    //编辑模式不做密码验证
        // password validation
        if ([SCLAlertHelper errorAlertValidateLengthWithString:user.password minLength:6 maxLength:kMaxLengthOfPassword alertName:NSLocalizedString(@"Password", nil)]) {
            return NO;
        } else if (![FieldValidator validatePassword:user.password]) {
            [SCLAlertHelper errorAlertWithContent:kPasswordInvalidKey];
            return NO;
        }
    }
    
    return YES;
}

#pragma mark - private methods

- (BOOL)insertPilotDataWithUser:(CDUser *)user {
    CDTodo *clickTask = [CDTodo newEntityWithInitialData];
    clickTask.title = Localized(@"Click task");
    clickTask.user = user;
    clickTask.sgDescription = Localized(@"See the details or edit it.");
    
    CDTodo *swipeTask = [CDTodo newEntityWithInitialData];
    swipeTask.title = Localized(@"Swipe task");
    swipeTask.user = user;
    swipeTask.sgDescription = Localized(@"Swipe left to complete, swipe right to snooze/delete.");
    
    MRTodoDataManager *dataManager = [MRTodoDataManager new];
    if (![dataManager InsertTask:clickTask] || ![dataManager InsertTask:swipeTask]) return NO;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kTaskChangedNotification object:self];
    
    return YES;
}
@end
