//
//  SyncDataManager.h
//  TO-DO
//
//  Created by Siegrain on 16/6/2.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "Localized.h"
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SyncMode) {
    /**
	 *  手动同步
	 */
    SyncModeManually,
    /**
	 *  自动同步
	 */
    SyncModeAutomatically
};

@interface SyncDataManager : NSObject<Localized>
- (void)synchronize:(SyncMode)syncType complete:(void (^)(bool succeed))complete;

+ (instancetype)dataManager;

+ (BOOL)isSyncing;
@end
