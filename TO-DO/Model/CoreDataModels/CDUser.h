//
//  CDUser.h
//  TO-DO
//
//  Created by Siegrain on 16/6/2.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "CDSyncRecord.h"
#import <Foundation/Foundation.h>

@class CDTodo;
@class LCUser;

NS_ASSUME_NONNULL_BEGIN

@interface CDUser : NSManagedObject

@property (nonatomic, readwrite, strong) UIImage* avatarPhoto;

/**
 *  根据LCUser获取CDUser实体
 */
+ (instancetype)userWithLCUser:(LCUser*)lcUser;
+ (instancetype)userWithLCUser:(LCUser*)lcUser inContext:(NSManagedObjectContext*)context;
@end

NS_ASSUME_NONNULL_END

#import "CDUser+CoreDataProperties.h"
