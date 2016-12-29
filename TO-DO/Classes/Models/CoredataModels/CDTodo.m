//
//  CDTodo.m
//  TO-DO
//
//  Created by Siegrain on 16/6/2.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "CDTodo.h"
#import "LCTodo.h"
#import "SGCoordinate.h"
#import "SGImageUpload.h"
#import "UIImage+Extension.h"
#import "AppDelegate.h"

@implementation CDTodo
@synthesize photoImage = _photoImage;
@synthesize rowHeight = _rowHeight;
@synthesize photoData = _photoData;
@synthesize coordinate = _coordinate;
@synthesize disableSwipeBehavior = _disableSwipeBehavior;

#pragma mark - accessors

- (SGCoordinate *)coordinate {
    if (!self.generalAddress) return nil;
    
    if (!_coordinate) {
        _coordinate = [SGCoordinate coordinateWithLatitude:self.latitude.doubleValue longitude:self.longitude.doubleValue];
        _coordinate.generalAddress = self.generalAddress;
        _coordinate.explicitAddress = self.explicitAddress;
    }
    
    return _coordinate;
}

- (void)setPhotoImage:(UIImage *)photoImage {
    _photoImage = photoImage;
    
    if (!_photoData && photoImage) _photoData = UIImageJPEGRepresentation(photoImage, 1);
}

+ (NSString *)MR_entityName {
    return @"Todo";
}

#pragma mark - public methods

- (void)markAsModified {
    self.syncStatus = @(SyncStatusWaiting);
    self.syncVersion = @([self.syncVersion integerValue] + 1);
    self.updatedAt = [NSDate date];
}

#pragma mark - save photo

- (void)saveImageWithBlock:(void (^ __nullable)(BOOL succeed))complete {
    if (!self.photoData) return;
    
    [[GCDQueue globalQueueWithLevel:DISPATCH_QUEUE_PRIORITY_DEFAULT] async:^void {
        NSString *folderPath = [SGHelper photoPath];
        NSFileManager *manager = [NSFileManager defaultManager];
        
        if (![manager fileExistsAtPath:folderPath]) [manager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
        
        self.photoPath = SGPhotoPath(self.identifier);
        self.photoImage = [UIImage imageWithData:self.photoData];
        
        if (![self.photoData writeToFile:self.photoPath atomically:YES]) return [self returnWithBlock:complete succeed:NO];
        NSData *thumbData = UIImageJPEGRepresentation([UIImage thumbnailWithCenterClip:self.photoImage size:kPhotoThumbSize radius:0], 0.5);
        if (![thumbData writeToFile:SGThumbPath(self.identifier) atomically:YES]) return [self returnWithBlock:complete succeed:NO];
        
        [self markAsModified];
        
        [self returnWithBlock:complete succeed:YES];
    }];
}

- (void)returnWithBlock:(void (^)(BOOL succeed))complete succeed:(BOOL)succeed {
    [[GCDQueue mainQueue] async:^{if (complete) complete(succeed);}];
}

#pragma mark - convert LCTodo to CDTodo

+ (instancetype)cdTodoWithLCTodo:(LCTodo *)lcTodo inContext:(NSManagedObjectContext *)context {
    /*
	 Mark: MagicalRecord
	 新实体必须在当前线程的上下文创建，否则会出现“Cocoa error: 133000”
	 */
    CDTodo *cdTodo = [CDTodo MR_createEntityInContext:context];
    cdTodo.user = [CDUser userWithLCUser:lcTodo.user inContext:context];
    cdTodo.objectId = lcTodo.objectId;
    [cdTodo cdTodoReplaceByLCTodo:lcTodo];
    
    return cdTodo;
}

- (instancetype)cdTodoReplaceByLCTodo:(LCTodo *)lcTodo {
    self.status = @(lcTodo.status);
    self.isHidden = @(lcTodo.isHidden);
    self.isCompleted = @(lcTodo.isCompleted);
    self.photoUrl = lcTodo.photo;
    self.createdAt = lcTodo.localCreatedAt;
    self.updatedAt = lcTodo.localUpdatedAt;
    self.syncVersion = @(lcTodo.syncVersion);
    self.title = lcTodo.title;
    self.sgDescription = lcTodo.sgDescription;
    self.deadline = lcTodo.deadline;
    self.identifier = lcTodo.identifier;
    self.completedAt = lcTodo.completedAt;
    self.deletedAt = lcTodo.deletedAt;
    if (lcTodo.coordinate) {
        self.longitude = @(lcTodo.coordinate.longitude);
        self.latitude = @(lcTodo.coordinate.latitude);
        self.generalAddress = lcTodo.generalAddress;
        self.explicitAddress = lcTodo.explicitAddress;
    }
    
    return self;
}

#pragma mark -

+ (instancetype)newEntityWithInitialData {
    CDTodo *todo = [CDTodo MR_createEntity];
    todo.title = @"new task";
    todo.sgDescription = @"";
    todo.deadline = [[NSDate date] dateByAddingTimeInterval:60 * 60 * 2];
    todo.user = [AppDelegate globalDelegate].cdUser;
    todo.status = @(TodoStatusNormal);
    todo.isCompleted = @(NO);
    todo.isHidden = @(NO);
    todo.createdAt = [NSDate date];
    todo.updatedAt = [todo.createdAt copy];
    todo.identifier = [[NSUUID UUID] UUIDString];
    
    return todo;
}

@end
