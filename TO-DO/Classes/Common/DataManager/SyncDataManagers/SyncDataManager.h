//
//  SyncDataManager.h
//  TO-DO
//
//  Created by Siegrain on 16/6/2.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "Localized.h"
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SyncType) {
    /**
	 *  手动同步
	 */
    SyncTypeManually,
    /**
	 *  自动同步
	 */
    SyncTypeAutomatically
};

@interface SyncDataManager : NSObject<Localized>
- (void)synchronize:(SyncType)syncType complete:(void (^)(bool succeed))complete;

+ (instancetype)dataManager;

+ (BOOL)isSyncing;
@end
