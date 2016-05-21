//
//  SGUser.h
//  TO-DO
//
//  Created by Siegrain on 16/5/9.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "AVOSCloud.h"
#import <UIKit/UIKit.h>

/*
 用户模型类
 
 用JSONModel时尽量不要设置只读属性
 */
@interface LCUser : AVUser<AVSubclassing>
//名称
@property (nonatomic, copy) NSString* name;
//头像地址
@property (nonatomic, copy) NSString* avatar;

/*
 以下是非托管属性（会被LeanCloud忽略）
 */
//头像图片
@property (nonatomic, strong) UIImage* avatarImage;
@end