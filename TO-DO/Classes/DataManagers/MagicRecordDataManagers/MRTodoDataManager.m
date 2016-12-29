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
static NSString *const kPhotoSaveFailedKey = @"PictureUploadFailed";

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
    _localDictionary[kPhotoSaveFailedKey] = Localized(@"Failed to save photo, please check your storage on device and try again");
}

- (instancetype)init {
    if (self = [super init]) {
        [self localizeStrings];
    }
    return self;
}

#pragma mark - retrieve

- (void)tasksWithUser:(CDUser *)user status:(NSNumber *)status isComplete:(NSNumber *)isComplete complete:(retrieveResult)complete {
    return [self tasksWithUser:user keyword:nil status:status isComplete:isComplete complete:complete];
}

- (void)tasksWithUser:(CDUser *)user keyword:(NSString *)keyword status:(NSNumber *)status isComplete:(NSNumber *)isComplete complete:(retrieveResult)complete {
    NSPredicate *filter = [self predicateWithUser:user date:nil keyword:keyword status:status isComplete:isComplete];
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
            dataDictionary[todo.deadline] = dataInSameDay;
        }
        [dataInSameDay addObject:todo];
    }
    
    return complete(YES, [dataDictionary copy], dataCount);
}

- (void)tasksWithUser:(CDUser *)user date:(NSDate *)date complete:(retrieveResult)complete {
    NSPredicate *filter = [self predicateWithUser:user date:date keyword:nil status:nil isComplete:@(NO)];
    NSArray<CDTodo *> *tasks = [CDTodo MR_findAllSortedBy:@"deadline" ascending:YES withPredicate:filter];
    filter = [self predicateWithUser:user date:date keyword:nil status:nil isComplete:@(YES)];
    NSArray<CDTodo *> *completedTasks = [CDTodo MR_findAllSortedBy:@"completedAt" ascending:YES withPredicate:filter];
    
    NSInteger dataCount = tasks.count + completedTasks.count;
    NSMutableDictionary *dataDictionary = [NSMutableDictionary new];
    dataDictionary[kDataNotCompleteTaskKey] = tasks;
    dataDictionary[kDataCompletedTaskKey] = completedTasks;
    
    return complete(YES, [dataDictionary copy], dataCount);
}

- (BOOL)hasDataWithDate:(NSDate *)date user:(CDUser *)user {
    return (BOOL) [CDTodo MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"user = %@ AND isHidden = %@ AND deadline >= %@ AND deadline <= %@", user, @(NO), date, [date dateByAddingTimeInterval:kTimeIntervalDay]]];
}

#pragma mark - commit

- (BOOL)InsertTask:(CDTodo *)todo {
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

- (BOOL)modifyTask:(CDTodo *)todo {
    _model = todo;
    if (![self validate]) return NO;
    
    [[GCDQueue globalQueueWithLevel:DISPATCH_QUEUE_PRIORITY_DEFAULT] sync:^{
        [todo markAsModified];
        MR_saveAndWait();
        
        [self syncIfNeeded];
    }];
    
    return YES;
}

- (void)scheduleNotification {
    UILocalNotification *notification = [UILocalNotification new];
    notification.fireDate = _model.deadline;
    notification.alertBody = _model.title;
}

#pragma mark - validate

- (BOOL)validate {
    // 暂时不做正则验证
    // remove whitespaces
    _model.title = [_model.title stringByRemovingUnnecessaryWhitespaces];
    _model.sgDescription = [_model.sgDescription stringByRemovingUnnecessaryWhitespaces];
    
    // title validation
    if (!_model.title.length) {
        [SCLAlertHelper errorAlertWithContent:_localDictionary[kTitleInvalidKey]];
        return NO;
    }
    if ([SCLAlertHelper errorAlertValidateLengthWithString:_model.title minLength:1 maxLength:kMaxLengthOfTitle alertName:NSLocalizedString(@"Title", nil)]) {
        return NO;
    }
    
    // deadline validation
    if (!_model.deadline) {
        [SCLAlertHelper errorAlertWithContent:_localDictionary[kTimeInvalidKey]];
        return NO;
    }
    // description validation
    if ([SCLAlertHelper errorAlertValidateLengthWithString:_model.sgDescription minLength:0 maxLength:kMaxLengthOfDescription alertName:NSLocalizedString(@"Description", nil)]) {
        return NO;
    }
    
    // 存储照片，如果失败了返回
    if (_model.photoData) {
        [_model saveImageWithBlock:^(BOOL succeed) {
            if (!succeed) [SGHelper errorAlertWithMessage:_localDictionary[kPhotoSaveFailedKey]];
        }];
    }
    
    return YES;
}

#pragma mark - private methods

- (void)syncIfNeeded {
    [[GCDQueue mainQueue] async:^{[[AppDelegate globalDelegate] synchronize:SyncModeAutomatically isForcing:NO];}];
}

- (NSPredicate *)predicateWithUser:(CDUser *)user date:(NSDate *)date keyword:(NSString *)keyword status:(NSNumber *)status isComplete:(NSNumber *)isComplete {
    NSMutableArray *arguments = [NSMutableArray new];
    NSString *predicateFormat = @"user = %@ and isHidden = %@";
    [arguments addObjectsFromArray:@[user, @(NO)]];
    if (isComplete) {
        predicateFormat = [predicateFormat stringByAppendingString:@" and isCompleted = %@"];
        [arguments addObject:isComplete];
    }
    if (date) {
        predicateFormat = [predicateFormat stringByAppendingString:@" and deadline >= %@ and deadline <= %@"];
        [arguments addObjectsFromArray:@[date, [date dateByAddingTimeInterval:kTimeIntervalDay]]];
    }
    if (keyword) {
        predicateFormat = [predicateFormat stringByAppendingString:@" and (sgDescription CONTAINS %@ or title CONTAINS %@ or explicitAddress CONTAINS %@ or generalAddress CONTAINS %@)"];
        [arguments addObjectsFromArray:@[keyword, keyword, keyword, keyword]];
    }
    if (status) {
        predicateFormat = [predicateFormat stringByAppendingString:@" and status = %@"];
        [arguments addObject:status];
    }
    NSPredicate *filter = [NSPredicate predicateWithFormat:predicateFormat argumentArray:[arguments copy]];
    return filter;
}
@end
