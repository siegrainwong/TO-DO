//
//  Constraints.h
//  TO-DO
//
//  Created by Siegrain on 16/5/7.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

/**
 *  帮助宏
 */
#ifndef Macros_h
#define Macros_h

#import "SGAPIKeys.h"
#import "NSObject+PropertyName.h"
#import "UIImage+RoundedCorner.h"
#import "UIView+RoundedCorner.h"
#import "GCDQueue.h"

//启用自动同步
#define ENABLE_AUTOMATIC_SYNC

//获取颜色，格式0xFFFFFF
#define ColorWithRGB(rgbValue)                                           \
    ([UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 \
                    green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0    \
                     blue:((float)(rgbValue & 0xFF)) / 255.0             \
                    alpha:1.0])

#define ColorWithRGBA(rgbValue, alp)                                      \
    ([UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 \
                     green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0    \
                      blue:((float)(rgbValue & 0xFF)) / 255.0             \
                     alpha:alp])

//屏幕尺寸
#define kScreenWidth ([[UIScreen mainScreen] bounds].size.width)
#define kScreenHeight ([[UIScreen mainScreen] bounds].size.height)

//判断网络状态，Realreachability ping百度及其不稳定，放弃使用，监听本地网络状态就行了
//#define isNetworkUnreachable ([AppDelegate globalDelegate].reachability.currentReachabilityStatus == RealStatusNotReachable)
#define isNetworkUnreachable ([LocalConnection sharedInstance].currentLocalConnectionStatus == LC_UnReachable)

//获取属性名
#define PropertyName(object, property) ([object stringWithProperty:property])

//获取系统语言
#define SystemLanguege ([NSLocale preferredLanguages][0])

//iOS版本
#define iOSVersion ([[UIDevice currentDevice].systemVersion floatValue])

//判断是否是中国地区
#define isChina ([SystemLanguege rangeOfString:@"zh-Han"].location != NSNotFound)

//简化本地化字符串宏
#define Localized(string) (NSLocalizedString(string, nil))

//获取info.plist的值
#define InfoDictionary(key) ([[NSBundle mainBundle] infoDictionary][key])

//拼接本地化字符串
#define ConcatLocalizedString1(str1, str2) ([NSString stringWithFormat:@"%@%@", NSLocalizedString(str1, nil), NSLocalizedString(str2, nil)])
#define ConcatLocalizedString2(str1, str2, str3) ([NSString stringWithFormat:@"%@%@%@", NSLocalizedString(str1, nil), NSLocalizedString(str2, nil), NSLocalizedString(str3, nil)])

//根据ID和类型获取图片前缀
#define GetPicturePrefix(type, id) ([NSString stringWithFormat:@"%@%@/", type, id])

//根据图片相对路径获取完整的NSURL
#define GetPictureUrl(urlStr, style) ([NSURL URLWithString:[NSString stringWithFormat:@"%@%@-%@", kQiniuDomain, urlStr, style]])
#define GetQiniuPictureUrl(urlStr) ([NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kQiniuDomain, urlStr]])

//控制状态栏网络菊花
#define ApplicationNetworkIndicatorVisible(isVisible) ([[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:isVisible])

//MagicRecord Save
#define MR_saveAndWait() [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
#define MR_saveAsynchronous() [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:nil];

/*======图片区  */
//下载图片
#define SDImageDownload(url, success) ([[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:url] options:SDWebImageRetryFailed | SDWebImageLowPriority progress:nil completed:^(UIImage * image, NSError * error, SDImageCacheType cacheType, BOOL finished, NSURL * imageURL) { [[GCDQueue mainQueue] async:^{ if(finished) success(image); }]; }])

//下载图片并返回圆角图
#define SDImageDownloadWithRoundedCorner(url, size, cornerSize, success) (SDImageDownload(url, ^(UIImage * image) { image = [image jm_imageWithRoundedCornersAndSize:CGSizeMake(size, size) andCornerRadius:cornerSize]; success(image); }))

#define SGPhotoPath(identifier) [NSString stringWithFormat:@"%@/%@.jpg", [SGHelper photoPath], identifier]
#define SGThumbPath(identifier) [NSString stringWithFormat:@"%@/thumb_%@.jpg", [SGHelper photoPath], identifier]
#endif