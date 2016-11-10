//
//  MRTodoDataManager.m
//  TO-DO
//
//  Created by Siegrain on 16/6/1.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "CDUser.h"
#import "DateUtil.h"
#import "GCDQueue.h"
#import "SGImageUpload.h"
#import "MRTodoDataManager.h"
#import "NSDate+Extension.h"
#import "NSString+Extension.h"
#import "SCLAlertHelper.h"
#import "AppDelegate.h"

/* localization dictionary keys */
static NSString *const kTitleInvalidKey = @"TitleInvalid";
static NSString *const kDescriptionInvalidKey = @"DescriptionInvalid";
static NSString *const kTimeInvalidKey = @"TimeInvalid";
static NSString *const kLocationInvalidKey = @"LocationInvalid";
static NSString *const kPictureUploadFailedKey = @"PictureUploadFailed";

@interface
MRTodoDataManager ()
@property(nonatomic, readwrite, strong) CDTodo *model;
@end

@implementation MRTodoDataManager
@synthesize localDictionary = _localDictionary;
#pragma mark - localization

- (void)localizeStrings {
    _localDictionary = [NSMutableDictionary new];
    _localDictionary[kTitleInvalidKey] = ConcatLocalizedString1(@"Title", @" can not be empty");
    _localDictionary[kTimeInvalidKey] = ConcatLocalizedString1(@"Time", @" can not be empty");
    _localDictionary[kDescriptionInvalidKey] = ConcatLocalizedString1(@"Description", @" is invalid");
    _localDictionary[kLocationInvalidKey] = ConcatLocalizedString1(@"Location", @" is invalid");
    _localDictionary[kPictureUploadFailedKey] = NSLocalizedString(@"Failed to upload picture, please try again", nil);
}

- (instancetype)init {
    if (self = [super init]) {
        [self localizeStrings];
    }
    return self;
}

#pragma mark - retrieve

- (void)retrieveDataWithUser:(CDUser *)user date:(NSDate *)date complete:(void (^)(bool succeed, NSDictionary *dataDictionary, NSInteger dataCount))complete {
    NSMutableArray *arguments = [NSMutableArray new];
    NSString *predicateFormat = @"user = %@ and isHidden = %@ and isCompleted = %@";
    [arguments addObjectsFromArray:@[user, @(NO), @(NO)]];
    if (date) {
        predicateFormat = [predicateFormat stringByAppendingString:@" and deadline >= %@ and deadline <= %@"];
        [arguments addObjectsFromArray:@[date, [date dateByAddingTimeInterval:kTimeIntervalDay]]];
    }
    NSPredicate *filter = [NSPredicate predicateWithFormat:predicateFormat argumentArray:[arguments copy]];
    NSArray<CDTodo *> *data = [CDTodo MR_findAllSortedBy:@"deadline" ascending:YES withPredicate:filter];
    
    NSInteger dataCount = data.count;
    NSMutableDictionary *dataDictionary = [NSMutableDictionary new];
    
    NSMutableArray *dataInSameDay;
    NSString *dateString;
    for (CDTodo *todo in data) {
        NSString *newDateString = todo.deadline.stringInYearMonthDay;
        if (![dateString isEqualToString:newDateString]) {
            dateString = newDateString;
            dataInSameDay = [NSMutableArray new];
            dataDictionary[dateString] = dataInSameDay;
        }
        [dataInSameDay addObject:todo];
    }
    
    return complete(YES, [dataDictionary copy], dataCount);
}

- (BOOL)hasDataWithDate:(NSDate *)date user:(CDUser *)user {
    return [CDTodo MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"user = %@ AND isHidden = %@ AND deadline >= %@ AND deadline <= %@", user, @(NO), date, [date dateByAddingTimeInterval:kTimeIntervalDay]]];
}

#pragma mark - insertion
#pragma mark - commit

- (BOOL)isInsertedTodo:(CDTodo *)todo {
    _model = todo;
    if (![self validate]) {
        // Mark: MagicalRecord 这个地方...新创建的实体如果验证失败的话，一定要记住移除它，不然它还在上下文中，等你下次保存的时候，会直接报错
        [todo MR_deleteEntity];
        return NO;
    }
    
    MR_saveAndWait();
    
    [self syncIfNeeded];
    return YES;
}

#pragma mark - validate

- (BOOL)validate {
    // 暂时不做正则验证
    // remove whitespaces
    _model.title = [_model.title stringByRemovingUnneccessaryWhitespaces];
    _model.sgDescription = [_model.sgDescription stringByRemovingUnneccessaryWhitespaces];
    
    // title validation
    if (!_model.title.length) {
        [SCLAlertHelper errorAlertWithContent:_localDictionary[kTitleInvalidKey]];
        return NO;
    }
    if ([SCLAlertHelper errorAlertValidateLengthWithString:_model.title minLength:1 maxLength:30 alertName:NSLocalizedString(@"Title", nil)]) {
        return NO;
    }
    
    // FIXME: 不是很懂这里为什么不能访问成员变量
    // deadline validation
    if (!_model.deadline) {
        [SCLAlertHelper errorAlertWithContent:_localDictionary[kTimeInvalidKey]];
        return NO;
    }
    // description validation
    if ([SCLAlertHelper errorAlertValidateLengthWithString:_model.sgDescription minLength:0 maxLength:200 alertName:NSLocalizedString(@"Description", nil)]) {
        return NO;
    }
    
    return YES;
}

#pragma mark - modify

- (BOOL)isModifiedTodo:(CDTodo *)todo {
    __weak typeof(self) weakSelf = self;
    [[GCDQueue globalQueueWithLevel:DISPATCH_QUEUE_PRIORITY_DEFAULT] sync:^{
        todo.syncStatus = @(SyncStatusWaiting);
        todo.syncVersion = @([todo.syncVersion integerValue] + 1);
        todo.updatedAt = [NSDate date];
        MR_saveAndWait();
    }];
    
    [self syncIfNeeded];
    
    return YES;
}

#pragma mark - private methods
- (void)syncIfNeeded {
    [[GCDQueue mainQueue] async:^{[[AppDelegate globalDelegate] synchronize:SyncModeAutomatically];}];
}
@end
