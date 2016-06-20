//
//  SyncDataManager.h
//  TO-DO
//
//  Created by Siegrain on 16/6/2.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "Localized.h"
#import "SyncErrorHandler.h"
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

@protocol SyncDataManagerDelegate<NSObject>
/**
 *  该方法在完成一批同步时调用
 */
- (void)syncDataManagerDidFinishedSyncInOneBatch;

@end

@interface SyncDataManager : NSObject<Localized>
@property (nonatomic, readwrite, weak) id<SyncDataManagerDelegate> delegate;
/**
 *  开始同步
 *
 *  @param syncMode 同步模式
 *  @param complete 回调
 */
- (void)synchronize:(SyncMode)syncMode complete:(CompleteBlock)complete;

+ (instancetype)dataManager;

+ (BOOL)isSyncing;
@end
