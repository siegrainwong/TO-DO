//
//  LCSync.h
//  TO-DO
//
//  Created by Siegrain on 16/6/2.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "AVOSCloud.h"

@interface LCSync : AVObject<AVSubclassing>
/* 同步状态 */
@property (nonatomic, readwrite, assign) SyncStatus syncStatus;
/* 版本 */
@property (nonatomic, readwrite, assign) NSInteger syncVersion;
@end
