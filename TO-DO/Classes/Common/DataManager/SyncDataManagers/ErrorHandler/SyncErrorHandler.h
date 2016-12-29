//
//  SyncErrorHandler.h
//  TO-DO
//
//  Created by Siegrain on 16/6/7.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^_Nullable CompleteBlock)(BOOL succeed);

NS_ASSUME_NONNULL_BEGIN

@interface SyncErrorHandler : NSObject
/**
 *  是否在错误时弹出对应的提醒框
 */
@property(nonatomic, assign) BOOL isAlert;
/**
 *  在错误处理Return之前要执行的block
 */
@property(nonatomic, copy) void (^_Nullable errorHandlerWillReturn)();

/**
 *  错误处理后 return nil
 *  用于返回对象的方法
 */
- (nullable id)returnWithError:(nullable NSError *)error description:(NSString *)description;

/**
 *  错误处理后 return，block 中的 succeed 值为 NO 
 *  用于返回void的方法
 */
- (void)returnWithError:(nullable NSError *)error description:(nullable NSString *)description failBlock:(CompleteBlock)block;
@end

NS_ASSUME_NONNULL_END