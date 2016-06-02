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
/* 用来转换photoData */
@property (nonatomic, readwrite, strong) UIImage* photoImage;
/* 缓存表格单元高度 */
@property (nonatomic, readwrite, assign) CGFloat cellHeight;
/* 上次过期时间，该字段用于 snooze 后移除老位置的数据所用 */
@property (nonatomic, readwrite, strong) NSDate* lastDeadline;
/* 指示该待办事项是否在重新排序中 */
@property (nonatomic, readwrite, assign) BOOL isReordering;

@end

NS_ASSUME_NONNULL_END

#import "CDTodo+CoreDataProperties.h"
