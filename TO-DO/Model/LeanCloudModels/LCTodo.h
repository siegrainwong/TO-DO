//
//  SGTodo.h
//  TO-DO
//
//  Created by Siegrain on 16/5/21.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "AVOSCloud.h"
#import "LCUser.h"
#import <Foundation/Foundation.h>

typedef NS_ENUM(int8_t, LCTodoState) {
    LCTodoStateDeleted = -1,
    LCTodoStateNotComplete,
    LCTodoStateCompleted,
    LCTodoStateSnoozed,
    LCTodoStateOverdue
};

@interface LCTodo : AVObject<AVSubclassing>
//标题
@property (nonatomic, readwrite, strong) NSString* title;
//描述（被内置字段占用）
@property (nonatomic, readwrite, strong) NSString* sgDescription;
//截止事件
@property (nonatomic, readwrite, strong) NSDate* deadline;
//位置
@property (nonatomic, readwrite, strong) NSString* location;
//用户
@property (nonatomic, readwrite, strong) LCUser* user;
//状态
@property (nonatomic, readwrite, assign) LCTodoState state;
//照片
@property (nonatomic, readwrite, strong) NSString* photo;

/**
 *  未实现
 */
//相关人员
@property (nonatomic, readwrite, copy) NSSet<LCUser*>* relatedPersonnel;

/**
 *  辅助属性
 */
//照片实例
@property (nonatomic, readwrite, strong) UIImage* photoImage;
@end
