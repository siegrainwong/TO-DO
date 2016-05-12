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

//获取颜色，格式0xFFFFFF
#define ColorWithRGB(rgbValue)                                           \
    [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 \
                    green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0    \
                     blue:((float)(rgbValue & 0xFF)) / 255.0             \
                    alpha:1.0]

//屏幕尺寸
#define kScreenWidth ([[UIScreen mainScreen] bounds].size.width)
#define kScreenHeight ([[UIScreen mainScreen] bounds].size.height)

//获取属性名
#define PropertyName(object, property) ([object stringWithProperty:property])
#endif