//
//  LoginDataManager.h
//  TO-DO
//
//  Created by Siegrain on 16/5/9.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "Localized.h"

@class LCUser;

@interface LCUserDataManager : NSObject<Localized>
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

/**
 * 编辑用户资料
 * @param user
 * @param complete
 */
- (void)modifyWithUser:(LCUser *)user complete:(void (^)(bool succeed))complete;
@end
