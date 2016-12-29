//
//  LCSyncRecord.h
//  TO-DO
//
//  Created by Siegrain on 16/6/4.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "LCUser.h"
#import <AVOSCloud.h>

@interface LCSyncRecord : AVObject<AVSubclassing>
/**
 *  本次同步是否完成（同一批次内只有最后一条同步记录未完成时，说明该批次同步成功）
 */
@property (nonatomic, readwrite, assign) BOOL isFinished;
/**
 *  开始同步时间
 */
@property (nonatomic, readwrite, strong) NSDate* syncBeginTime;
/**
 *  结束同步时间（该值不是完成同步的依据）
 */
@property (nonatomic, readwrite, strong) NSDate* syncEndTime;
/**
 *  同步用户
 */
@property (nonatomic, readwrite, strong) LCUser* user;
/**
 *  手机唯一标识（该标识在手机上对该应用的本地用户唯一）
 */
@property (nonatomic, readwrite, strong) NSString* phoneIdentifier;
/**
 *  同步类型
 */
@property (nonatomic, readwrite, assign) SyncType syncType;
/**
 *  标记（相同标记代表这几条同步记录为同一批次）
 */
@property (nonatomic, readwrite, strong) NSString* recordMark;
/* 本次同步提交数 */
@property (nonatomic, readwrite, assign) NSInteger commitCount;
/* 本次同步下载数 */
@property (nonatomic, readwrite, assign) NSInteger downloadCount;
@end
