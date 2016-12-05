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

@implementation CDTodo
@synthesize photoImage = _photoImage;
@synthesize cellHeight = _cellHeight;
@synthesize isReordering = _isReordering;
@synthesize photoData = _photoData;
@synthesize coordinate = _coordinate;

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

- (UIImage *)avatarPhoto {
    if (!_photoImage) {
        _photoImage = [UIImage imageWithData:self.photoData];
    }
    return _photoImage;
}

- (void)setPhotoImage:(UIImage *)photoImage {
    _photoImage = photoImage;
    
    if (!_photoData) _photoData = UIImageJPEGRepresentation(photoImage, 1);
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

- (BOOL)saveImage {
    if (!self.photoData) return false;
    
    NSString *folderPath = [SGHelper photoPath];
    NSFileManager *manager = [NSFileManager defaultManager];
    
    NSError *error = nil;
    if (![manager fileExistsAtPath:folderPath]) {
        [manager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:&error];
    }
    NSString *imagePath = [NSString stringWithFormat:@"%@/%@.jpg", [SGHelper photoPath], self.identifier];
    if (![self.photoData writeToFile:imagePath atomically:YES]) {
        return NO;
    }
    self.photoPath = imagePath;
    
    [self markAsModified];
    
    return YES;
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
@end
