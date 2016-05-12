//
//  WMutableData.h
//  Wilddog
//
//  Created by Garin on 15/7/10.
//  Copyright (c) 2015年 Wilddog. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
  WMutableData 实例是 Wilddog 节点处的另一种数据载体，当使用 runTransactionBlock：方法时，
  你会接受到一个包含当前节点数据的 WMutableData 实例。如果你想要保存此节点的数据，将此节点的
  WMutableData 传参到 [FTransactionResult successWithValue:] 方法中。
 
  修改 WMutableData 实例中的数据，value 可将其设置为 Wilddog 支持的任一原生数据类型：
 
    NSNumber (includes BOOL)
    NSDictionary
    NSArray
    NSString
    nil / NSNull (设置 nil / NSNull 删除该数据)
  
 */
@interface WMutableData : NSObject


/** @name 数据访问 */

/**
 * 判断在当前 WMutableData 中，是否存在子节点
 *
 * @return YES 为存在子节点，NO 为不存在
 */
- (BOOL) hasChildren;


/**
 * 检查指定路径下是否存在子节点
 *
 * @param path 可以是类似'child'的单层级路径，也可以是类似'a/deeper/child'多层级路径
 * @return 如果在指定的相对路径下，该 WMutableData 包含子节点，则返回YES
 */
- (BOOL) hasChildAtPath:(NSString *)path;


/**
 * 用于获得一个在给定的相对路径下的 WMutableData 数据实例
 *
 * @param path 可以是类似'child'的单层级路径，也可以是类似'a/deeper/child'多层级路径
 * @return 指定路径下的 WMutableData 实例
 */
- (WMutableData *) childDataByAppendingPath:(NSString *)path;


/** @name 属性 */


/**
 * 修改 WMutableData 实例中的数据，value 可将其设置为 Wilddog 支持的任一原生数据类型：
 *
 * * NSNumber (includes BOOL)
 * * NSDictionary
 * * NSArray
 * * NSString
 * * nil / NSNull (设置 nil / NSNull 删除该数据)
 *
 * 注意修改这个 value，会覆盖这个节点的优先级
 *
 * @return 获得当前节点的数据
 */
@property (strong, nonatomic) id value;


/**
 * 设置这个属性可以更新该节点下面的数据优先级，可以设置的值类型有：
 *
 * * NSNumber
 * * NSString
 * * nil / NSNull (设置 nil / NSNull 删除该数据)
 *
 * @return 获得当前节点的优先级
 */
@property (strong, nonatomic) id priority;


/**
 * @return 获得子节点的总数
 */
@property (readonly, nonatomic) NSUInteger childrenCount;


/**
 * 用于迭代该节点的子节点，可以用下面的这个方法：
 
       for (WMutableData* child in data.children) {
           ...
       }
 
 * @return 获取当前节点下所有子节点的 Mutabledata 实例的迭代器
 */
@property (readonly, nonatomic, strong) NSEnumerator* children;


/**
 * @return 获取当前节点的 key，最上层的节点的 key 是 nil
 */
@property (readonly, nonatomic, strong) NSString* key;
@end



