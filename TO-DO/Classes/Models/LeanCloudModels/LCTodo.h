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

@interface LCTodo : LCSync <AVSubclassing>
/* 本地唯一标识 */
@property(nonatomic, strong) NSString *identifier;
/* 标题 */
@property(nonatomic, strong) NSString *title;
/* 描述（被内置字段占用） */
@property(nonatomic, strong) NSString *sgDescription;
/* 过期时间 */
@property(nonatomic, strong) NSDate *deadline;
/* 用户 */
@property(nonatomic, strong) LCUser *user;
/* 状态 */
@property(nonatomic, assign) LCTodoStatus status;
/* 是否删除 */
@property(nonatomic, assign) BOOL isHidden;
/* 是否完成 */
@property(nonatomic, assign) BOOL isCompleted;
/* 照片地址 */
@property(nonatomic, strong) NSString *photo;
/* 照片数据 */
@property(nonatomic, strong) NSData *photoData;
/* 本地创建时间 */
@property(nonatomic, strong) NSDate *localCreatedAt;
/* 本地更新时间 */
@property(nonatomic, strong) NSDate *localUpdatedAt;
/* 完成时间 */
@property(nonatomic, assign) NSDate *completedAt;
/* 删除时间 */
@property(nonatomic, assign) NSDate *deletedAt;

/* 地址相关
 * 坐标*/
@property(nonatomic, assign) AVGeoPoint *coordinate;
/* 基础地址 */
@property(nonatomic, strong) NSString *generalAddress;
/* 具体地址 */
@property(nonatomic, strong) NSString *explicitAddress;
/**
 *  未实现
 */
/* 相关人员 */
@property(nonatomic, copy) NSSet<LCUser *> *relatedPersonnel;

/**
 *  辅助属性
 */
/* 照片实例 */
@property(nonatomic, strong) UIImage *photoImage;
/* 缓存表格单元高度 */
@property(nonatomic, assign) CGFloat cellHeight;
/* 上次过期时间，该字段用于 snooze 后移除老位置的数据所用 */
@property(nonatomic, strong) NSDate *lastDeadline;
/* 指示该待办事项是否在重新排序中 */
@property(nonatomic, assign) BOOL isReordering;

/**
 *  辅助方法
 */
/* CDTodo 转换为 LCTodo */
+ (LCTodo *)lcTodoWithCDTodo:(CDTodo *)cdTodo;

+ (NSArray<LCTodo *> *)lcTodoArrayWithCDTodoArray:(NSArray<CDTodo *> *)cdArray;
@end
