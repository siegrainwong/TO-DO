//
//  CDTodo.h
//  TO-DO
//
//  Created by Siegrain on 16/6/2.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "CDSync.h"
#import <Foundation/Foundation.h>

@class CDUser;

NS_ASSUME_NONNULL_BEGIN

@interface CDTodo : CDSync

@property (nonatomic, readwrite, strong) UIImage* photoImage;

@end

NS_ASSUME_NONNULL_END

#import "CDTodo+CoreDataProperties.h"
