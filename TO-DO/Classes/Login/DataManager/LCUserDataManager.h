//
//  LoginDataManager.h
//  TO-DO
//
//  Created by Siegrain on 16/5/9.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "Localized.h"

@class LCUser;

typedef void (^SGUserResponse)(bool succeed, NSString *errorMessage);

@interface LCUserDataManager : NSObject <Localized>
@property(nonatomic, assign) BOOL isSignUp;

/**
 *  处理登录、注册请求
 *
 *  @param user       <#user description#>
 *  @param isSignUp   <#isSignUp description#>
 *  @param completion <#completion description#>
 *
 *  @return <#return value description#>
 */
- (void)commitWithUser:(LCUser *)user isSignUp:(BOOL)signUp complete:(SGUserResponse)complete;

/**
 * 编辑用户资料
 * @param user
 * @param complete
 */
- (void)modifyWithUser:(LCUser *)user complete:(void (^)(bool succeed))complete;

/**
 * 验证用户是否合法，用于单元测试
 * @param user
 * @param isModify
 * @return
 */
- (BOOL)validateWithUser:(LCUser *)user isModify:(BOOL)isModify;
@end
