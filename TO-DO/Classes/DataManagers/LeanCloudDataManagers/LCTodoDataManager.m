//
//  HomeDataManager.m
//  TO-DO
//
//  Created by Siegrain on 16/5/24.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "DateUtil.h"
#import "FieldValidator.h"
#import "SGImageUpload.h"
#import "LCTodo.h"
#import "LCTodoDataManager.h"
#import "LCUser.h"
#import "NSDate+Extension.h"
#import "NSString+Extension.h"
#import "SCLAlertHelper.h"

/* localization dictionary keys */
static NSString* const kPictureUploadFailedKey = @"PictureUploadFailed";

@interface
LCTodoDataManager ()
@property (nonatomic, readwrite, strong) LCTodo* model;
@end

@implementation LCTodoDataManager
@synthesize localDictionary = _localDictionary;
#pragma mark - localization
- (void)localizeStrings
{
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
#pragma mark - retrieve
- (void)retrieveDataWithUser:(LCUser*)user date:(NSDate*)date complete:(void (^)(bool succeed, NSDictionary* dataDictionary, NSInteger dataCount))complete
{
    AVQuery* query = [AVQuery queryWithClassName:[LCTodo parseClassName]];
    [query whereKey:@"user" equalTo:user];
    [query whereKey:@"isDeleted" equalTo:@(NO)];
    [query whereKey:@"isCompleted" equalTo:@(NO)];
    if (date) {
        date = [DateUtil dateInYearMonthDay:date];
        [query whereKey:@"deadline" greaterThanOrEqualTo:date];
        [query whereKey:@"deadline" lessThanOrEqualTo:[date dateByAddingTimeInterval:kTimeIntervalDay]];
    }
    [query orderByAscending:@"deadline"];

    ApplicationNetworkIndicatorVisible(YES);
    [query findObjectsInBackgroundWithBlock:^(NSArray<LCTodo*>* objects, NSError* error) {
        if (error) {
            [SCLAlertHelper errorAlertWithContent:error.localizedDescription];
            ApplicationNetworkIndicatorVisible(NO);
            return complete(NO, nil, 0);
        }

        NSInteger dataCount = objects.count;
        NSMutableDictionary* dataDictionary = [NSMutableDictionary new];

        NSMutableArray* dataInSameDay;
        NSString* dateString;
        for (LCTodo* todo in objects) {
            NSString* newDateString = todo.deadline.stringInYearMonthDay;
            if (![dateString isEqualToString:newDateString]) {
                dateString = newDateString;
                dataInSameDay = [NSMutableArray new];
                dataDictionary[dateString] = dataInSameDay;
            }
            [dataInSameDay addObject:todo];
        }
        ApplicationNetworkIndicatorVisible(NO);
        return complete(YES, [dataDictionary copy], dataCount);
    }];
}
#pragma mark - insertion
#pragma mark - commit
- (void)insertTodo:(LCTodo*)todo complete:(void (^)(bool succeed))complete
{
    _model = todo;

    [self uploadPicture:^(bool succeed) {
        if (!succeed) return complete(NO);

        [_model saveInBackgroundWithBlock:^(BOOL succeeded, NSError* error) {
            if (!succeeded)
                [SCLAlertHelper errorAlertWithContent:error.localizedDescription];

            return complete(succeeded);
        }];
    }];
}
#pragma mark - upload image
- (void)uploadPicture:(void (^)(bool succeed))complete
{
    if (!_model.photoImage) return complete(YES);

    [SGImageUpload uploadImage:_model.photoImage type:SGImageTypeOriginal prefix:GetPicturePrefix(kUploadPrefixUser, _model.user.objectId) completion:^(bool error, NSString* path) {
        if (error) {
            [SCLAlertHelper errorAlertWithContent:_localDictionary[kPictureUploadFailedKey]];

            return complete(NO);
        }

        _model.photo = path;
        return complete(YES);
    }];
}

#pragma mark - modification
#pragma mark - modify
- (void)modifyTodo:(LCTodo*)todo complete:(void (^)(bool succeed))complete
{
    todo.fetchWhenSave = YES;
    ApplicationNetworkIndicatorVisible(YES);
    [todo saveEventually:^(BOOL succeeded, NSError* error) {
        ApplicationNetworkIndicatorVisible(NO);
        //        if (error) {
        //            [SCLAlertHelper errorAlertWithContent:error.localizedDescription];
        //            return complete(NO);
        //        }
        return complete(YES);
    }];
}
@end
