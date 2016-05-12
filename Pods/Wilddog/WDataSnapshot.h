//
//  WDataSnapshot.h
//  Wilddog
//
//  Created by Garin on 15/7/7.
//  Copyright (c) 2015年 Wilddog. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Wilddog;

/**
 *
 */
@interface WDataSnapshot : NSObject


/** @name 检索快照 */

/**
 *  根据指定的相对路径，来获取当前节点下的WDataSnapshot。
 *
 *  childPathString为相对路径
 *  相对路径可以是一个简单的节点名字（例如，‘fred’）
 *  也可以是一个更深的路径，（例如，'fred/name/first'）多层级间需要使用"/"分隔
 *  如果节点的位置没有数据，则返回一个空的WDataSnapshot
 *
 *  @param childPathString 节点数据的相对路径
 *
 *  @return 指定节点位置的WDataSnapshot
 */
- (WDataSnapshot *) childSnapshotForPath:(NSString *)childPathString;


/**
 *  如果指定路径下存在子节点，返回 YES
 *
 *  @param childPathString 相对路径
 *
 *  @return 如果指定路径下存在子节点，返回YES，否则返回NO
 */
- (BOOL) hasChild:(NSString *)childPathString;


/**
 *  如果这个 WDatasnapshot 有任何子节点返回YES，否则NO。
 *
 *  @return 如果这个 WDatasnapshot 有任何子节点返回YES
 */
- (BOOL) hasChildren;


/**
 *  返回节点的原始数据
 */
- (id) valueInExportFormat;


/**
 *  如果DataSnapshot中包含非空数据，返回YES。
 *  @return 如果DataSnapshot 包含一个非空数据，就返回YES
 */
- (BOOL)exists;


/** @name 属性 */

/**
 * 从snapshot中获得当前节点的数据。
 *
 * 返回的数据类型有:
 *  NSDictionary
 *  NSArray
 *  NSNumber (包含Bool类型)
 *  NSString
 */
@property (strong, readonly, nonatomic) id value;


/**
 * 获得DataSnapshot的子节点的总数。
 */
@property (readonly, nonatomic) NSUInteger childrenCount;


/**
 * 从DataSnapshot中，获得当前节点的引用。
 */
@property (nonatomic, readonly, strong) Wilddog* ref;


/**
 * 从DataSnapshot中，获取当前节点的名称。
 */
@property (strong, readonly, nonatomic) NSString* key;


/**
 * 获取当前DataSnapshot中，所有子节点的迭代器。
 *
 * for (WDataSnapshot* child in snapshot.children) {
 *     ...
 * }
 */
@property (strong, readonly, nonatomic) NSEnumerator* children;


/**
 * 获取该WDataSnapshot对象的优先级 
 *
 * @return 优先级是一个字符串，若没有设置priority，则返回nil
 */
@property (strong, readonly, nonatomic) id priority;

@end
