//
//  MRTodoDataManager.m
//  TO-DO
//
//  Created by Siegrain on 16/6/1.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "CDUser.h"
#import "DateUtil.h"
#import "ImageUploader.h"
#import "MRTodoDataManager.h"
#import "NSDate+Extension.h"
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
#pragma mark - retrieve
- (void)retrieveDataWithUser:(CDUser*)user date:(NSDate*)date complete:(void (^)(bool succeed, NSDictionary* dataDictionary, NSInteger dataCount))complete
{
    NSMutableArray* arguments = [NSMutableArray new];
    NSString* predicateFormat = @"user = %@ and isHidden = %@ and isCompleted = %@";
    [arguments addObjectsFromArray:@[ user, @(NO), @(NO) ]];
    if (date) {
        predicateFormat = [predicateFormat stringByAppendingString:@" and deadline >= %@ and deadline <= %@"];
        [arguments addObjectsFromArray:@[ date, [date dateByAddingTimeInterval:kTimeIntervalDay] ]];
    }
    NSPredicate* filter = [NSPredicate predicateWithFormat:predicateFormat argumentArray:[arguments copy]];
    NSArray<CDTodo*>* data = [CDTodo MR_findAllSortedBy:@"deadline" ascending:YES withPredicate:filter];

    NSInteger dataCount = data.count;
    NSMutableDictionary* dataDictionary = [NSMutableDictionary new];

    NSMutableArray* dataInSameDay;
    NSString* dateString;
    for (CDTodo* todo in data) {
        NSString* newDateString = todo.deadline.stringInYearMonthDay;
        if (![dateString isEqualToString:newDateString]) {
            dateString = newDateString;
            dataInSameDay = [NSMutableArray new];
            dataDictionary[dateString] = dataInSameDay;
        }
        [dataInSameDay addObject:todo];
    }

    return complete(YES, [dataDictionary copy], dataCount);
}
#pragma mark - insertion
#pragma mark - commit
- (void)insertTodo:(CDTodo*)todo complete:(void (^)(bool succeed))complete
{
    _model = todo;
    if (![self validate]) return complete(NO);

    [self saveWithBlock:complete];
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
#pragma mark - modify
- (void)modifyTodo:(CDTodo*)todo complete:(void (^)(bool succeed))complete
{
    __weak typeof(self) weakSelf = self;
    dispatch_queue_t serialQueue = dispatch_queue_create("todoModifySerialQueue", DISPATCH_QUEUE_SERIAL);
    dispatch_sync(serialQueue, ^{
        todo.syncStatus = @(SyncStatusWaiting);
        todo.syncVersion = @([todo.syncVersion integerValue] + 1);
        todo.updatedAt = [NSDate date];
        [weakSelf saveWithBlock:complete];
    });
}
@end
