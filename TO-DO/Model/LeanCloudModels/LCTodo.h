//
//  SGTodo.h
//  TO-DO
//
//  Created by Siegrain on 16/5/21.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "AVOSCloud.h"
#import "LCSync.h"
#import "LCUser.h"
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, LCTodoStatus) {
    /* 普通 */
    LCTodoStatusNormal,
    /* 延迟 */
    LCTodoStatusSnoozed,
    /* 过期 */
    LCTodoStatusOverdue
};

@class CDTodo;

@interface LCTodo : LCSync<AVSubclassing>
/* 本地唯一标识 */
@property (nonatomic, readwrite, strong) NSString* identifier;
/* 标题 */
@property (nonatomic, readwrite, strong) NSString* title;
/* 描述（被内置字段占用） */
@property (nonatomic, readwrite, strong) NSString* sgDescription;
/* 过期时间 */
@property (nonatomic, readwrite, strong) NSDate* deadline;
/* 位置 */
@property (nonatomic, readwrite, strong) NSString* location;
/* 用户 */
@property (nonatomic, readwrite, strong) LCUser* user;
/* 状态 */
@property (nonatomic, readwrite, assign) LCTodoStatus status;
/* 是否删除 */
@property (nonatomic, readwrite, assign) BOOL isHidden;
/* 是否完成 */
@property (nonatomic, readwrite, assign) BOOL isCompleted;
/* 照片 */
@property (nonatomic, readwrite, strong) NSString* photo;
/* 本地创建时间 */
@property (nonatomic, readwrite, strong) NSDate* localCreatedAt;
/* 本地更新时间 */
@property (nonatomic, readwrite, strong) NSDate* localUpdatedAt;

/**
 *  未实现
 */
/* 相关人员 */
@property (nonatomic, readwrite, copy) NSSet<LCUser*>* relatedPersonnel;
/* 坐标 */
@property (nonatomic, readwrite, strong) NSString* coordinate;

/**
 *  辅助属性
 */
/* 照片实例 */
@property (nonatomic, readwrite, strong) UIImage* photoImage;
/* 缓存表格单元高度 */
@property (nonatomic, readwrite, assign) CGFloat cellHeight;
/* 上次过期时间，该字段用于 snooze 后移除老位置的数据所用 */
@property (nonatomic, readwrite, strong) NSDate* lastDeadline;
/* 指示该待办事项是否在重新排序中 */
@property (nonatomic, readwrite, assign) BOOL isReordering;

/**
 *  辅助方法
 */
/* CDTodo 转换为 LCTodo */
+ (LCTodo*)lcTodoWithCDTodo:(CDTodo*)cdTodo;
+ (NSArray<LCTodo*>*)lcTodoArrayWithCDTodoArray:(NSArray<CDTodo*>*)cdArray;
/* 判断LCTodo和CDTodo的数据是否相同 */
- (BOOL)isSameDataAsCDTodo:(CDTodo*)cdTodo;
@end
