//
// Created by Siegrain on 16/10/19.
// Copyright (c) 2016 com.lurenwang.gameplatform. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"

@interface MBProgressHUD (SGExtension)
/* 显示菊花式的HUD */
+ (instancetype)show;
/**
 * 显示文字HUD
 * @param text 内容
 * @param seconds 在几秒后消失，0为不消失
 * @return
 */
+ (instancetype)showWithText:(NSString *)text dismissAfter:(NSInteger)seconds;
/**
 * 隐藏当前HUD
 */
+ (void)dismiss;
@end