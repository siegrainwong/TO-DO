//
//  MRDataManager.h
//  TO-DO
//
//  Created by Siegrain on 16/6/2.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "SCLAlertHelper.h"
#import <Foundation/Foundation.h>

@interface MRDataManager : NSObject
/**
 *  MagicRecord的通用持久化存储方法
 *
 *  @param complete 回调
 */
- (void)saveWithBlock:(void (^)(bool succeed))complete;
@end
