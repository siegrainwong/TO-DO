//
// Created by Siegrain on 16/11/22.
// Copyright (c) 2016 com.siegrain. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * 该类可将代理消息转发给两个对象，一个是原代理，一个是目标代理
 */
@interface SGDelegateProxy : NSProxy
- (instancetype)initWithTarget:(id)target;
+ (instancetype)proxyWithTarget:(id)target;

@property (nonatomic, weak) id originalDelegate;
@end
