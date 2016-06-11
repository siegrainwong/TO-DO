//
//  SyncErrorHandler.h
//  TO-DO
//
//  Created by Siegrain on 16/6/7.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^_Nullable CompleteBlock)(BOOL succeed);

@interface SyncErrorHandler : NSObject
/**
 *  是否在错误时弹出对应的提醒框
 */
@property (nonatomic, readwrite, assign) BOOL isAlert;
/**
 *  在错误处理Return之前要执行的block
 */
@property (nonatomic, readwrite, copy) void (^_Nullable errorHandlerWillReturn)();

/**
 *  错误处理后 return nil
 *  用于返回对象的方法
 */
- (id _Nullable)returnWithError:(NSError* _Nullable)error description:(NSString* _Nonnull)description;
/**
 *  错误处理后 return，block 中的 succeed 值为 NO 
 *  用于返回void的方法
 */
- (void)returnWithError:(NSError* _Nullable)error description:(NSString* _Nonnull)description returnWithBlock:(CompleteBlock)block;
@end
