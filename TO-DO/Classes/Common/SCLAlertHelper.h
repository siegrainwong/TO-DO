//
//  SCLAlertHelper.h
//  TO-DO
//
//  Created by Siegrain on 16/5/9.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "Localized.h"
#import <Foundation/Foundation.h>

@class SCLAlertView;

@interface SCLAlertHelper : NSObject<Localized>
/**
 *  弹出错误信息窗口
 *
 *  @param content <#content description#>
 */
+ (void)errorAlertWithContent:(NSString*)content;
/**
 *  验证字符串长度是否符合要求，不符合则弹出错误信息窗口
 *
 *  @param string <#string description#>
 *  @param min    <#min description#>
 *  @param max    <#max description#>
 *  @param name   <#name description#>
 */
+ (BOOL)errorAlertValidateLengthWithString:(NSString*)string minLength:(NSUInteger)min maxLength:(NSUInteger)max alertName:(NSString*)name;
@end
