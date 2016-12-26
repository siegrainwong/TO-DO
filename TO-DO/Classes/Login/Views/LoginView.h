//
//  LoginView.h
//  TO-DO
//
//  Created by Siegrain on 16/5/8.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "Localized.h"
#import <UIKit/UIKit.h>

@class LCUser;

@protocol LoginViewDelegate<NSObject>
- (void)loginViewDidPressCommitButton:(LCUser*)user isSignUp:(BOOL)isSignUp;
- (void)loginViewDidPressAvatarButton;
@end

/**
 *  登录、注册界面
 */
@interface LoginView : UIView<Localized>
@property (nonatomic, readwrite, weak) id<LoginViewDelegate> delegate;
@property(nonatomic, strong) UIImage *avatar;

+ (instancetype)loginView;

/**
 *  提交操作结束后，停止提交动画
 */
- (void)stopCommitAnimation;
@end
