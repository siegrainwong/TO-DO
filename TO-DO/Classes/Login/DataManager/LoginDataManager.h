//
//  LoginDataManager.h
//  TO-DO
//
//  Created by Siegrain on 16/5/9.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "Localized.h"
#import <Foundation/Foundation.h>

@class LCUser;

@interface LoginDataManager : NSObject<Localized>
/**
 *  处理登录、注册请求
 *
 *  @param user       <#user description#>
 *  @param isSignUp   <#isSignUp description#>
 *  @param completion <#completion description#>
 *
 *  @return <#return value description#>
 */
- (void)handleCommit:(LCUser*)user isSignUp:(BOOL)signUp complete:(void (^)(bool succeed))complete;
@end
