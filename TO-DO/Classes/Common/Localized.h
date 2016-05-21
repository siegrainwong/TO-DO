//
//  Localizable.h
//  TO-DO
//
//  Created by Siegrain on 16/5/11.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 *  本地化协议
 */
@protocol Localized<NSObject>
@optional
/**
 *  本地化字符串字典
 */
@property (nonatomic, readwrite, strong) NSMutableDictionary* localDictionary;
/**
 *  用于放置添加字符串到字典中的代码
 */
- (void)localizeStrings;
@end
