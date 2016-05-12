//
//  WAuthType.h
//  Wilddog
//
//  Created by Garin on 15/7/7.
//  Copyright (c) 2015年 Wilddog. All rights reserved.
//

#ifndef Wilddog_WAuthType_h
#define Wilddog_WAuthType_h


typedef NS_ENUM(NSInteger, WAuthenticationError) {
    // 开发者 / 配置错误
    WAuthenticationErrorProviderDisabled = -1,
    WAuthenticationErrorInvalidConfiguration = -2,
    WAuthenticationErrorInvalidOrigin = -3,
    WAuthenticationErrorInvalidProvider = -4,
    
    // 用户错误（电子邮件/密码）
    WAuthenticationErrorInvalidEmail = -5,
    WAuthenticationErrorInvalidPassword = -6,
    WAuthenticationErrorInvalidToken = -7,
    WAuthenticationErrorUserDoesNotExist = -8,
    WAuthenticationErrorEmailTaken = -9,
    
    WAuthenticationErrorDeniedByUser = -10,
    WAuthenticationErrorInvalidCredentials = -11,
    WAuthenticationErrorInvalidArguments = -12,
    WAuthenticationErrorProviderError = -13,
    WAuthenticationErrorLimitsExceeded = -14,
    
    // 客户端错误
    WAuthenticationErrorNetworkError = -15,
    WAuthenticationErrorPreempted = -16,
    
    WAuthenticationErrorUnknown = -9999
};

#endif
