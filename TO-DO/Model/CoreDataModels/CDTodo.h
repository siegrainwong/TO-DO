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
@property(nonatomic, assign) CGFloat cellHeight;
/* 指示该待办事项是否在重新排序中 */
@property(nonatomic, assign) BOOL isReordering;
/* 位置 */
@property(nonatomic, strong) SGCoordinate *coordinate;

/**
 *  已新建实体的方式用lcTodo创建cdTodo
 */
+ (instancetype)cdTodoWithLCTodo:(LCTodo *)lcTodo inContext:(NSManagedObjectContext *)context;

/**
 *  将cdTodo的部分数据覆盖为指定lcTodo的数据
 */
- (instancetype)cdTodoReplaceByLCTodo:(LCTodo *)lcTodo;
@end

NS_ASSUME_NONNULL_END

#import "CDTodo+CoreDataProperties.h"
