//
//  WQuery.h
//  Wilddog
//
//  Created by Garin on 15/7/7.
//  Copyright (c) 2015年 Wilddog. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WEventType.h"
#import "WDataSnapshot.h"

typedef int64_t WilddogHandle;
@class WDataSnapshot;

/**
 * 一个WQuery对象，用于查询指定路径的数据。
 *
 */
@interface WQuery : NSObject

/** @name 属性 */

/**
 *  获取这个查询的 Wilddog 引用。
 */
@property (nonatomic, readonly, strong) Wilddog *ref;

/** @name 绑定观察者，读取数据 */

/**
 *
 *  observeEventType:withBlock: 用于监听一个指定节点的数据变化
 *  这是从Wilddog服务器读取数据的主要方式，block当监听到初始数据和初始数据有改变时触发。
 *
 *  typedef NS_ENUM(NSInteger, WEventType) {
 *      WEventTypeChildAdded,     // 0, 当有新增子节点时触发
 *      WEventTypeChildRemoved,   // 1, 当有子节点被删除时触发
 *      WEventTypeChildChanged,   // 2, 当某个子节点发生变化时触发
 *      WEventTypeChildMoved,     // 3, 当有子节排序发生变化时触发
 *      WEventTypeValue           // 4, 当有数据请求或有任何数据发生变化时触发
 *  };
 *
 *  @param eventType 监听的事件类型
 *  @param block     当监听到某事件时，回调block
 *
 *  @return 一个WilddogHandle，用于调用函数 removeObserverWithHandle: 去注销这个block
 */
- (WilddogHandle) observeEventType:(WEventType)eventType withBlock:(void (^)(WDataSnapshot* snapshot))block;


/**
 * observeEventType:andPreviousSiblingKeyWithBlock: 用于监听在特定节点处的数据的变化。
 * 这是从Wilddog数据库读取数据的主要方法。block当监听到初始数据和初始数据有改变时触发。 此外， 对于 WEventTypeChildAdded, WEventTypeChildMoved, 和 WEventTypeChildChanged 事件, block通过priority排序将传输前一节点的key值。
 *
 * 用 removeObserverWithHandle: 方法去停止接受数据更新的监听。
 *
 * @param eventType 监听的事件类型
 * @param block 当监听到初始数据和初始数据发生变化时，这个block将被回调。block将传输一个WDataSnapshot类型的数据和前一个子节点的key
 * @return 一个WilddogHandle，用于调用函数 removeObserverWithHandle: 去注销这个block
 */
- (WilddogHandle) observeEventType:(WEventType)eventType andPreviousSiblingKeyWithBlock:(void (^)(WDataSnapshot* snapshot, NSString* prevKey))block;


/**
 *  observeEventType:withBlock: 用于监听一个指定节点的数据变化
 *  这是从Wilddog服务器读取数据的主要方式，block当监听到初始数据和初始数据有改变时触发。
 *  由于你没有读取权限，就接受不到新的事件，这时cancelBlock就会被调用
 *
 *  @param eventType   监听的事件类型
 *  @param block       当监听到某事件时，回调block
 *  @param cancelBlock 如果客户端没有权限去接受这些事件，这个block将会被调用
 *
 *  @return 一个WilddogHandle，用于调用函数 removeObserverWithHandle: 去注销这个block
 */
- (WilddogHandle) observeEventType:(WEventType)eventType withBlock:(void (^)(WDataSnapshot* snapshot))block withCancelBlock:(void (^)(NSError* error))cancelBlock;


/**
 * observeEventType:andPreviousSiblingKeyWithBlock: 用于监听在特定节点处的数据的变化。
 * 这是从Wilddog数据库读取数据的主要方法。block当监听到初始数据和初始数据有改变时触发。 此外， 对于 WEventTypeChildAdded, WEventTypeChildMoved, 和 WEventTypeChildChanged 事件, block通过priority排序将传输前一节点的key值。
 *
 * 由于你没有读取权限，就接受不到新的事件，这时cancelBlock就会被调用
 *
 * 用 removeObserverWithHandle: 方法去停止接受数据更新的监听。
 *
 * @param eventType 监听的事件类型
 * @param block 当监听到初始数据和初始数据发生变化时，这个block将被回调。block将传输一个WDataSnapshot类型的数据和前一个子节点的key
 * @param cancelBlock 如果客户端没有权限去接受这些事件，这个block将会被调用
 *
 * @return  一个WilddogHandle，用于调用函数 removeObserverWithHandle: 去注销这个block
 */
- (WilddogHandle) observeEventType:(WEventType)eventType andPreviousSiblingKeyWithBlock:(void (^)(WDataSnapshot* snapshot, NSString* prevKey))block withCancelBlock:(void (^)(NSError* error))cancelBlock;


/**
 *  同observeEventType:withBlock: 类似，不同之处在于 observeSingleEventOfType:withBlock: 中的回调函数只被执行一次。
 *
 *  @param eventType 监听的事件类型
 *  @param block     当监听到某事件时，回调block
 */
- (void) observeSingleEventOfType:(WEventType)eventType withBlock:(void (^)(WDataSnapshot* snapshot))block;


/**
 * 这个方法和 observeEventType:withBlock: 方法类似。不同之处是：在初始数据返回后，这个block回调一次就被取消监听。 此外， 对于 WEventTypeChildAdded, WEventTypeChildMoved, 和 WEventTypeChildChanged 事件, block通过priority排序将传输前一节点的key值。
 *
 * @param eventType 监听的事件类型
 * @param block block 当监听到初始数据和初始数据发生变化时，这个block将被回调。block将传输一个WDataSnapshot类型的数据和前一个子节点的key
 */
- (void) observeSingleEventOfType:(WEventType)eventType andPreviousSiblingKeyWithBlock:(void (^)(WDataSnapshot* snapshot, NSString* prevKey))block;


/**
 *  同observeSingleEventOfType:withBlock:类似，如果你没有在这个节点读取数据的权限，cancelBlock将会被回调
 *
 *  @param eventType   监听的事件类型
 *  @param block       当监听到某事件时，回调block
 *  @param cancelBlock 如果您没有权限访问此数据，将调用该cancelBlock
 */
- (void) observeSingleEventOfType:(WEventType)eventType withBlock:(void (^)(WDataSnapshot* snapshot))block withCancelBlock:(void (^)(NSError* error))cancelBlock;


/**
 * 这个方法和 observeEventType:withBlock: 方法类似。不同之处是：在初始数据返回后，这个block回调一次就被取消监听。 此外， 对于 WEventTypeChildAdded, WEventTypeChildMoved, 和 WEventTypeChildChanged 事件, block通过priority排序将传输前一节点的key值。
 *
 * 如果你没有在这个节点读取数据的权限，cancelBlock将会被回调
 *
 * @param eventType 监听的事件类型
 * @param block 将传输一个WDataSnapshot类型的数据和前一个子节点的key
 * @param cancelBlock 如果您没有权限访问此数据，将调用该cancelBlock
 */
- (void) observeSingleEventOfType:(WEventType)eventType andPreviousSiblingKeyWithBlock:(void (^)(WDataSnapshot* snapshot, NSString* prevKey))block withCancelBlock:(void (^)(NSError* error))cancelBlock;


/** @name 移除观察者 */

/**
 *  取消监听事件。取消之前用observeEventType:withBlock:注册的 回调函数。
 *
 *  @param handle 由observeEventType:withBlock:返回的 WilddogHandle
 */
- (void) removeObserverWithHandle:(WilddogHandle)handle;


/**
 *  取消之前由 observeEventType:withBlock:注册的所有的监听事件。
 */
- (void) removeAllObservers;


/**
   在某一节点处通过调用`keepSynced:YES`方法，即使该节点处没有设置监听者，此节点处的数据也将自动下
   载存储并保持同步。
 
   @param keepSynced 参数设置为 YES，则在此节点处同步数据，设置为 NO，停止同步。
 */
- (void) keepSynced:(BOOL)keepSynced;


/** @name 查询和限制 */

/**
 * queryLimitedToFirst: 用于创建一个新WQuery引用，获取从第一条开始的指定数量的数据。
 * 返回的WQuery查询器类将响应从第一个开始，到最多指定(limit)节点个数的数据。
 *
 * @param limit 这次查询能够获取的子节点的最大数量
 * @return 返回一个WQuery查询器类，最多指定(limit)个数的数据
 */
- (WQuery *) queryLimitedToFirst:(NSUInteger)limit;


/**
 * queryLimitedToLast: 用于创建一个新WQuery引用，获取从最后一条开始向前指定数量的数据。
 * 将返回从最后一个开始，最多指定(limit)个数的数据。
 *
 * @param limit 这次查询能够获取的子节点的最大数量
 * @return 返回一个WQuery查询器类，最多指定(limit)个数的数据
 */
- (WQuery *) queryLimitedToLast:(NSUInteger)limit;


/**
 * queryOrderedByChild: 用于产生一个新WQuery引用，是按照特定子节点的值进行排序的。
 * 此方法要与 queryStartingAtValue:, queryEndingAtValue: 或 queryEqualToValue: 方法联合使用。
 *
 * @param key 指定用来排序的子节点的key
 * @return 返回一个按指定的子节点key排序生成的WQuery查询器类
 */
- (WQuery *) queryOrderedByChild:(NSString *)key;


/**
 * queryOrderedByKey 用于产生一个新WQuery引用，是按照特定子节点的key进行排序的。
 * 此方法要与 queryStartingAtValue:, queryEndingAtValue: 或 queryEqualToValue: 方法联合使用。
 *
 * @return 返回一个按指定的子节点key排序生成的WQuery查询器类
 */
- (WQuery *) queryOrderedByKey;


/**
 * queryOrderedByValue 用于产生一个新WQuery引用，是按照当前节点的值进行排序的。
 * 此方法要与 queryStartingAtValue:, queryEndingAtValue: 或 queryEqualToValue: 方法联合使用。
 *
 * @return 返回一个按指定的子节点值排序生成的WQuery查询器类
 */
- (WQuery *) queryOrderedByValue;


/**
 * queryOrderedByPriority 用于产生一个新WQuery引用，是按照当前节点的优先级排序的。 
 * 此方法要与 queryStartingAtValue:, queryEndingAtValue: 或 queryEqualToValue: 方法联合使用。
 *
 * @return 返回一个按指定的子节点优先级排序生成的WQuery查询器类
 */
- (WQuery *) queryOrderedByPriority;


/**
 * queryStartingAtValue: 用于返回一个WQuery引用，这个引用用来监测数据的变化，这些被监测的数据的值均大于或等于startValue。
 *
 * @param startValue query查询到的值均大于等于startValue
 * @return 返回一个WQuery查询器类，用于响应在数据值大于或等于startValue的节点事件
 */
- (WQuery *) queryStartingAtValue:(id)startValue;


/**
 * queryStartingAtValue:childKey: 用于返回一个WQuery引用，这个引用用来监测数据的变化，这些被监测的数据的值大于startValue，或者等于startValue并且key大于等于childKey。
 *
 * @param startValue query查询到的值均大于等于startValue
 * @param childKey query查询到的key均大于等于childKey
 * @return 返回一个WQuery查询器类，用于响应在数据值大于startValue，或等于startValue的值并且key大于或等于childKey的节点事件
 */
- (WQuery *) queryStartingAtValue:(id)startValue childKey:(NSString *)childKey;


/**
 * queryEndingAtValue: 用于返回一个WQuery引用，这个引用用来监测数据的变化，这些被监测的数据的值均小于或者等于endValue。
 *
 * @param endValue query查询到的值均小于等于endValue
 * @return 返回一个WQuery查询器类，用于响应在数据值均小于或等于endValue的节点事件
 */
- (WQuery *) queryEndingAtValue:(id)endValue;


/**
 * queryEndingAtValue:childKey: 用于返回一个WQuery引用，这个引用用来监测数据的变化，这些被监测的数据的值小于endValue，或者等于endValue并且key小于等于childKey。
 *
 * @param endValue query查询到的值均小于等于endValue
 * @param childKey query查询到的key均小于等于childKey
 * @return 返回一个WQuery查询器类，用于响应在查询到的数据值小于endValue，或者数据值等于endValue并且key小于等于childKey的节点事件
 */
- (WQuery *) queryEndingAtValue:(id)endValue childKey:(NSString *)childKey;


/**
 * queryEqualToValue: 用于返回一个WQuery引用，这个引用用来监测数据的变化，这些被监测的数据的值都等于value。
 *
 * @param value query查询到的值都等于value
 * @return 返回一个WQuery查询器类，用于响应这个与之相等数值节点事件
 */
- (WQuery *) queryEqualToValue:(id)value;


/**
 * queryEqualToValue:childKey: 用于返回一个WQuery引用，这个引用用来监测数据的变化，这些被监测的数据的值等于value并且key等于childKey。返回的值肯定是唯一的，因为key是唯一的。
 *
 * @param value query查询到的值都等于value
 * @param childKey query查询到的key都等于childKey
 * @return 返回一个WQuery查询器类，用于响应这个与之相等数值和key节点事件
 */
- (WQuery *) queryEqualToValue:(id)value childKey:(NSString *)childKey;

@end
