//
//  MRTodoDataManager.m
//  TO-DO
//
//  Created by Siegrain on 16/6/1.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "ImageUploader.h"
#import "MRTodoDataManager.h"
#import "NSString+Extension.h"
#import "SCLAlertHelper.h"

/* localization dictionary keys */
static NSString* const kTitleInvalidKey = @"TitleInvalid";
static NSString* const kDescriptionInvalidKey = @"DescriptionInvalid";
static NSString* const kTimeInvalidKey = @"TimeInvalid";
static NSString* const kLocationInvalidKey = @"LocationInvalid";
static NSString* const kPictureUploadFailedKey = @"PictureUploadFailed";

@interface
MRTodoDataManager ()
@property (nonatomic, readwrite, strong) CDTodo* model;
@end

@implementation MRTodoDataManager
@synthesize localDictionary = _localDictionary;

#pragma mark - insertion
#pragma mark - commit
- (BOOL)insertTodo:(CDTodo*)todo
{
    _model = todo;
    if (![self validate]) return NO;

    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];

    return YES;
}
#pragma mark - validate
- (BOOL)validate
{
    // 暂时不做正则验证
    // remove whitespaces
    _model.title = [_model.title stringByRemovingUnneccessaryWhitespaces];
    _model.sgDescription = [_model.sgDescription stringByRemovingUnneccessaryWhitespaces];
    _model.location = [_model.location stringByRemovingUnneccessaryWhitespaces];

    // title validation
    if (!_model.title.length) {
        [SCLAlertHelper errorAlertWithContent:_localDictionary[kTitleInvalidKey]];
        return NO;
    }
    if ([SCLAlertHelper errorAlertValidateLengthWithString:_model.title minLength:1 maxLength:30 alertName:NSLocalizedString(@"Title", nil)]) {
        return NO;
    }

    // deadline validation
    if (!_model.deadline) {
        [SCLAlertHelper errorAlertWithContent:_localDictionary[kTimeInvalidKey]];
        return NO;
    }
    // description validation
    if ([SCLAlertHelper errorAlertValidateLengthWithString:_model.sgDescription minLength:0 maxLength:200 alertName:NSLocalizedString(@"Description", nil)]) {
        return NO;
    }
    //location validation
    if ([SCLAlertHelper errorAlertValidateLengthWithString:_model.location minLength:0 maxLength:50 alertName:NSLocalizedString(@"Location", nil)]) {
        return NO;
    }

    return YES;
}
@end
