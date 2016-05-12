//
//  LoginDataManager.h
//  TO-DO
//
//  Created by Siegrain on 16/5/9.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "Localizable.h"
#import <Foundation/Foundation.h>

@class SGUser;

@interface LoginDataManager : NSObject<Localizable>
/**
 *  处理登录、注册请求
 *
 *  @param user       <#user description#>
 *  @param isSignUp   <#isSignUp description#>
 *  @param completion <#completion description#>
 *
 *  @return <#return value description#>
 */
- (void)handleCommit:(SGUser*)user isSignUp:(BOOL)signUp completion:(void (^)(bool error))completion;
@end
