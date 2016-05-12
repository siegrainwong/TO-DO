//
//  SGUser.h
//  TO-DO
//
//  Created by Siegrain on 16/5/9.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "JSONModel.h"
#import <UIKit/UIKit.h>

/*
 用户模型类
 
 用JSONModel时尽量不要设置只读属性
 */
@interface SGUser : JSONModel
//名称
@property (nonatomic, copy) NSString* name;
//邮箱
@property (nonatomic, copy) NSString* email;
//头像地址
@property (nonatomic, copy) NSString* avatar;
//注册时间
@property (nonatomic, strong) NSDate* registerTime;
//最后登录时间
@property (nonatomic, strong) NSDate* lastLoginTime;

/*
 以下属性在解析、序列化等操作时被忽略
 */
//密码
@property (nonatomic, copy) NSString<Ignore>* password;
//头像图片
@property (nonatomic, strong) UIImage<Ignore>* avatarImage;
@end