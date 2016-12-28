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
#ifndef SGAPIKeys_h
#define SGAPIKeys_h

/**
 * ================================ 各种服务的Key or Secrets
 */

/* 高德地图 */
static NSString * const kAmapKey = @"f387111b6ebe49a4a9c4477706a6c7e8";

/* 七牛空间地址 */
static NSString* const kQiniuDomain = @"http://o6yj5t1zc.bkt.clouddn.com/";

/* LeanCloud */
static NSString* const kLeanCloudAppID = @"vDDTixlKPFwrGS60fnprdslF-gzGzoHsz";
static NSString* const kLeanCloudAppKey = @"dM0JeJT5w3a74pE1yQ9UcMJk";

/* Privacy Policy URL */
static NSString * const kPrivacyPolicyUrl = @"http://siegrain.wang/post/to-do-privacy-policy";

/**
 * ================================ 其他
 */

/* LeanCloud获取服务器时间的API地址 */
static NSString* const kLeanCloudServerDateApiUrl = @"https://api.leancloud.cn/1.1/date";

/* 七牛图片样式 */
static NSString* const kQiniuImageStyleMedium = @"medium";
static NSString* const kQiniuImageStyleSmall = @"small";
static NSString* const kQiniuImageStyleThumbnail = @"thumb";

#endif