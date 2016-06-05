//
//  CDTodo.m
//  TO-DO
//
//  Created by Siegrain on 16/6/2.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "CDTodo.h"
#import "LCTodo.h"

@implementation CDTodo
@synthesize photoImage = _photoImage;
@synthesize cellHeight = _cellHeight;
@synthesize lastDeadline = _lastDeadline;
@synthesize isReordering = _isReordering;

#pragma mark - accessors
- (UIImage*)avatarPhoto
{
    if (!_photoImage) {
        _photoImage = [UIImage imageWithData:self.photoData];
    }
    return _photoImage;
}

+ (NSString*)MR_entityName
{
    return @"Todo";
}
#pragma mark - convert LCTodo to CDTodo
+ (instancetype)cdTodoWithLCTodo:(LCTodo*)lcTodo
{
    CDTodo* cdTodo = [CDTodo MR_createEntity];
    cdTodo.title = lcTodo.title;
    cdTodo.sgDescription = lcTodo.sgDescription;
    cdTodo.deadline = lcTodo.deadline;
    cdTodo.location = lcTodo.location;
    cdTodo.user = [CDUser userWithLCUser:lcTodo.user];
    cdTodo.status = @(lcTodo.status);
    cdTodo.isHidden = @(lcTodo.isHidden);
    cdTodo.isCompleted = @(lcTodo.isCompleted);
    cdTodo.photo = cdTodo.photo;
    cdTodo.createdAt = lcTodo.localCreatedAt;
    cdTodo.updatedAt = lcTodo.localUpdatedAt;
    cdTodo.syncVersion = @(lcTodo.syncVersion);
    cdTodo.objectId = lcTodo.objectId;

    return cdTodo;
}
@end
