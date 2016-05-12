//
//  WAuthData.h
//  Wilddog
//
//  Created by Garin on 15/7/7.
//  Copyright (c) 2015年 Wilddog. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Auth 模型
 */
@interface WAuthData : NSObject

/**
 *  由服务器返回的登录用户的原始认证数据
 */
@property (nonatomic, strong, readonly) NSDictionary *auth;


/**
 *  由服务器返回的token过期时间
 */
@property (nonatomic, strong, readonly) NSNumber *expires;


/**
 *  返回登录用户的uid，uid在所有auth登录用户中是唯一的
 */
@property (nonatomic, strong, readonly) NSString *uid;


/**
 *  返回登录用户的登录方式
 */
@property (nonatomic, readonly) NSString *provider;


/**
 *  token用于在Wilddog数据库中认证该用户
 */
@property (nonatomic, strong, readonly) NSString *token;


/**
 *  第三方登录成功后，返回的用户信息
 */
@property (nonatomic, strong, readonly) NSDictionary *providerData;

@end
