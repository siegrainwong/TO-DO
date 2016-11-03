//
//  DataKeys.h
//  TO-DO
//
//  Created by Siegrain on 16/5/9.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

/**
 *  各类常量关键字等
 */
#ifndef DataKeys_h
#define DataKeys_h

/* 野狗空间地址 */
static NSString* const kWilddogConnectionString = @"https://sgtodo.wilddogio.com/";

/* 七牛空间地址 */
static NSString* const kQiniuDomain = @"http://o6yj5t1zc.bkt.clouddn.com/";
//static NSString* const kQiniuDomain = @"http://o8uecvzxf.bkt.clouddn.com/";

/* 七牛图片样式 */
static NSString* const kQiniuImageStyleMidium = @"midium";
static NSString* const kQiniuImageStyleSmall = @"small";
static NSString* const kQiniuImageStyleThumbnail = @"thumb";

/* LeanCloud */
static NSString* const kLeanCloudAppID = @"vDDTixlKPFwrGS60fnprdslF-gzGzoHsz";
static NSString* const kLeanCloudAppKey = @"dM0JeJT5w3a74pE1yQ9UcMJk";
/* LeanCloud获取服务器时间的API地址 */
static NSString* const kLeanCloudServerDateApiUrl = @"https://api.leancloud.cn/1.1/date";

#endif