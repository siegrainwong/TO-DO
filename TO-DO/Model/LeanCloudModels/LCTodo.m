//
//  SGTodo.m
//  TO-DO
//
//  Created by Siegrain on 16/5/21.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "CDTodo.h"
#import "LCTodo.h"

@implementation LCTodo
@dynamic title;
@dynamic sgDescription;
@dynamic deadline;
@dynamic coordinate;
@dynamic generalAddress;
@dynamic explicitAddress;
@dynamic user;
@dynamic status;
@dynamic isHidden;
@dynamic isCompleted;
@dynamic photo;
@dynamic photoData;
@dynamic syncVersion;
@dynamic localCreatedAt;
@dynamic localUpdatedAt;
@dynamic identifier;
@dynamic deletedAt;
@dynamic completedAt;

+ (LCTodo *)lcTodoWithCDTodo:(CDTodo *)cdTodo {
    LCTodo *lcTodo = [LCTodo object];
    lcTodo.objectId = cdTodo.objectId;
    lcTodo.identifier = cdTodo.identifier;
    lcTodo.title = cdTodo.title;
    lcTodo.sgDescription = cdTodo.sgDescription;
    lcTodo.deadline = cdTodo.deadline;
    lcTodo.photo = cdTodo.photoUrl;
    
    lcTodo.user = [LCUser currentUser];
    lcTodo.status = [cdTodo.status integerValue];
    lcTodo.isHidden = [cdTodo.isHidden boolValue];
    lcTodo.isCompleted = [cdTodo.isCompleted boolValue];
    lcTodo.syncVersion = [cdTodo.syncVersion integerValue];
    lcTodo.localUpdatedAt = cdTodo.updatedAt;
    lcTodo.localCreatedAt = cdTodo.createdAt;
    lcTodo.completedAt = cdTodo.completedAt;
    lcTodo.deletedAt = cdTodo.deletedAt;
    if (cdTodo.generalAddress) {
        lcTodo.coordinate = [AVGeoPoint geoPointWithLatitude:cdTodo.latitude.doubleValue longitude:cdTodo.longitude.doubleValue];
        lcTodo.generalAddress = cdTodo.generalAddress;
        lcTodo.explicitAddress = cdTodo.explicitAddress;
    }
    //没有提交过的数据才加载photoData
    if (!cdTodo.objectId && cdTodo.photoPath) {
        cdTodo.photoData = [NSData dataWithContentsOfFile:cdTodo.photoPath];
    }
    
    return lcTodo;
}

+ (NSArray<LCTodo *> *)lcTodoArrayWithCDTodoArray:(NSArray<CDTodo *> *)cdArray {
    __weak typeof(self) weakSelf = self;
    __block NSMutableArray<LCTodo *> *lcArray = [NSMutableArray new];
    [cdArray enumerateObjectsUsingBlock:^(CDTodo *cdTodo, NSUInteger idx, BOOL *stop) {
        [lcArray addObject:[weakSelf lcTodoWithCDTodo:cdTodo]];
    }];
    
    return lcArray;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[CDTodo class]]) {
        CDTodo *cdTodo = (CDTodo *) object;
        if ([self.deadline compare:cdTodo.deadline] != NSOrderedSame) return NO;
        if (self.status != cdTodo.status.integerValue) return NO;
        if (self.isHidden != cdTodo.isHidden.boolValue) return NO;
        if (self.isCompleted != cdTodo.isCompleted.boolValue) return NO;
        if (![self.title isEqualToString:cdTodo.title]) return NO;
        if (![self.sgDescription isEqualToString:cdTodo.sgDescription]) return NO;
        if ([self.localCreatedAt compare:cdTodo.createdAt] != NSOrderedSame) return NO;
        if ([self.localUpdatedAt compare:cdTodo.updatedAt] != NSOrderedSame) return NO;
        if (self.syncVersion != cdTodo.syncVersion.integerValue) return NO;
        if (self.generalAddress) {
            if (self.coordinate.latitude != cdTodo.latitude.doubleValue) return NO;
            if (self.coordinate.longitude != cdTodo.longitude.doubleValue) return NO;
            if (![self.generalAddress isEqualToString:cdTodo.generalAddress]) return NO;
            if (![self.explicitAddress isEqualToString:cdTodo.explicitAddress]) return NO;
        }
        
        return YES;
    } else if ([object isKindOfClass:[LCTodo class]]) {
        return [super isEqual:object];
    }
    return NO;
}

#pragma mark - leancloud subclass methods

+ (NSString *)parseClassName {
    return @"Todo";
}
@end
