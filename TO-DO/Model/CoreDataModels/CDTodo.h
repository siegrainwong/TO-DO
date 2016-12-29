//
//  CDTodo.h
//  TO-DO
//
//  Created by Siegrain on 16/6/2.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "CDUser.h"
#import <Foundation/Foundation.h>

@class LCTodo;
@class SGCoordinate;

NS_ASSUME_NONNULL_BEGIN

@interface CDTodo : NSManagedObject
/* 用来存储photo的UIImage */
@property(nonatomic, strong) UIImage *photoImage;
/* 存储NSData */
@property(nonatomic, strong) NSData *photoData;
/* 缓存表格单元高度 */
@property(nonatomic, assign) CGFloat rowHeight;
/* 位置 */
@property(nonatomic, strong) SGCoordinate *coordinate;
/* 禁用滑动行为 */
@property(nonatomic, assign) BOOL disableSwipeBehavior;

- (void)markAsModified;

- (void)saveImageWithBlock:(void (^ __nullable)(BOOL succeed))complete;

/**
 *  已新建实体的方式用lcTodo创建cdTodo
 */
+ (instancetype)cdTodoWithLCTodo:(LCTodo *)lcTodo inContext:(NSManagedObjectContext *)context;

/**
 *  将cdTodo的部分数据覆盖为指定lcTodo的数据
 */
- (instancetype)cdTodoReplaceByLCTodo:(LCTodo *)lcTodo;

/**
 *  创建实体并填入初始数据
 * @return
 */
+ (instancetype)newEntityWithInitialData;
@end

NS_ASSUME_NONNULL_END

#import "CDTodo+CoreDataProperties.h"
