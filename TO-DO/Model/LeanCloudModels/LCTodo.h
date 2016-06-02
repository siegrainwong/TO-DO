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

@interface LCTodo : LCSync<AVSubclassing>
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
@end
