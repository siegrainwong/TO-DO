//
//  SyncDataManager.h
//  TO-DO
//
//  Created by Siegrain on 16/6/2.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SyncDataManager : NSObject
- (void)synchronize:(void (^)(bool succeed))complete;

+ (instancetype)dataManager;

+ (BOOL)isSyncing;
@end
