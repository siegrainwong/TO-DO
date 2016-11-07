//
// Created by Siegrain on 16/11/7.
// Copyright (c) 2016 com.siegrain. All rights reserved.
//

@interface CommonDataManager : NSObject
/* 修改头像 */
+ (void)modifyAvatarWithImage:(UIImage *)image block:(void (^)())block;
@end