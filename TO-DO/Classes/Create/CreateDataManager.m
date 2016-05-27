//
//  CreateDataManager.m
//  TO-DO
//
//  Created by Siegrain on 16/5/21.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "CreateDataManager.h"
#import "FieldValidator.h"
#import "ImageUploader.h"
#import "LCTodo.h"
#import "Macros.h"
#import "NSString+Extension.h"
#import "SCLAlertHelper.h"

/* localization dictionary keys */
static NSString* const kTitleInvalidKey = @"TitleInvalid";
static NSString* const kDescriptionInvalidKey = @"DescriptionInvalid";
static NSString* const kTimeInvalidKey = @"TimeInvalid";
static NSString* const kLocationInvalidKey = @"LocationInvalid";
static NSString* const kPictureUploadFailedKey = @"PictureUploadFailed";

@implementation CreateDataManager {
    LCTodo* model;
}
@synthesize localDictionary = _localDictionary;
#pragma mark - localization
- (void)localizeStrings
{
    _localDictionary[kTitleInvalidKey] = ConcatLocalizedString1(@"Title", @" can not be empty");
    _localDictionary[kTimeInvalidKey] = ConcatLocalizedString1(@"Time", @" can not be empty");
    _localDictionary[kDescriptionInvalidKey] = ConcatLocalizedString1(@"Description", @" is invalid");
    _localDictionary[kLocationInvalidKey] = ConcatLocalizedString1(@"Location", @" is invalid");
    _localDictionary[kPictureUploadFailedKey] = NSLocalizedString(@"Failed to upload picture, please try again", nil);
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
#pragma mark - commit
- (void)handleCommit:(LCTodo*)todo complete:(void (^)(bool succeed))complete
{
    model = todo;
    if (![self validate]) return complete(NO);

    [self uploadPicture:^(bool succeed) {
        if (!succeed) return complete(NO);

        [model saveInBackgroundWithBlock:^(BOOL succeeded, NSError* error) {
            if (!succeeded)
                [SCLAlertHelper errorAlertWithContent:error.localizedDescription];

            return complete(succeeded);
        }];
    }];
}
#pragma mark - uploadImage
- (void)uploadPicture:(void (^)(bool succeed))complete
{
    if (!model.photoImage) return complete(YES);

    [ImageUploader uploadImage:model.photoImage type:UploadImageTypeOriginal prefix:GetPicturePrefix(kUploadPrefixUser, model.user.objectId) completion:^(bool error, NSString* path) {
        if (error) {
            [SCLAlertHelper errorAlertWithContent:_localDictionary[kPictureUploadFailedKey]];

            return complete(NO);
        }

        model.photo = path;
        return complete(YES);
    }];
}
#pragma mark - validate
- (BOOL)validate
{
    // 暂时不做正则验证
    // remove whitespaces
    model.title = [model.title stringByRemovingUnneccessaryWhitespaces];
    model.sgDescription = [model.sgDescription stringByRemovingUnneccessaryWhitespaces];
    model.location = [model.location stringByRemovingUnneccessaryWhitespaces];

    // title validation
    if (!model.title.length) {
        [SCLAlertHelper errorAlertWithContent:_localDictionary[kTitleInvalidKey]];
        return NO;
    }
    if ([SCLAlertHelper errorAlertValidateLengthWithString:model.title minLength:1 maxLength:20 alertName:NSLocalizedString(@"Title", nil)]) {
        return NO;
    }

    // deadline validation
    if (!model.deadline) {
        [SCLAlertHelper errorAlertWithContent:_localDictionary[kTimeInvalidKey]];
        return NO;
    }
    // description validation
    if ([SCLAlertHelper errorAlertValidateLengthWithString:model.sgDescription minLength:0 maxLength:200 alertName:NSLocalizedString(@"Description", nil)]) {
        return NO;
    }
    //location validation
    if ([SCLAlertHelper errorAlertValidateLengthWithString:model.location minLength:0 maxLength:50 alertName:NSLocalizedString(@"Location", nil)]) {
        return NO;
    }

    return YES;
}
@end
