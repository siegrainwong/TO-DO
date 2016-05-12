//
//  WTransactionResult.h
//  Wilddog
//
//  Created by Garin on 15/7/10.
//  Copyright (c) 2015年 Wilddog. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WMutableData.h"

/**
 *  用于 runTransactionBlock: 方法中，WTransactionResult 实例是事务处理结果的载体
 */
@interface WTransactionResult : NSObject

/**
 * 用于 runTransactionBlock: 方法中。 表明传入参数 value 应保存在这个节点处
 *
 * @param value 一个包含新 value 的 WMutableData 实例
 * @return 返回一个 WTransactionResult 实例，它可以作为给 runTransactionBlock: 方法中 block 的一个返回值
 */
+ (WTransactionResult *) successWithValue:(WMutableData *)value;


/**
 * 用于 runTransactionBlock: 方法中。 使用该方法可以主动终止当前事务
 *
 * @return 返回一个 WTransactionResult 实例，它可以作为给 runTransactionBlock: 方法中 block 的一个返回值
 */
+ (WTransactionResult *) abort;
@end
