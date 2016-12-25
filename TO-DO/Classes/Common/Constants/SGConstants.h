//
//  Constants.h
//  TO-DO
//
//  Created by Siegrain on 16/6/20.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#ifndef SGConstants_h
#define SGConstants_h

/**************************************** 通知名 */
/**
 *  当同步完成一批时发送通知
 */
static NSString *const kFinishedSyncInOneBatchNotification = @"kFinishedSyncInOneBatch";
/**
 *  当待办事项数据发生变更时发送通知
 */
static NSString *const kTaskChangedNotification = @"kTaskChangedNotification";

/**************************************** 约束 */
static NSUInteger const kMaxLengthOfTitle = 50;
static NSUInteger const kMaxLengthOfDescription = 1000;
static NSUInteger const kMaxLengthOfUserName = 20;
static NSUInteger const kMaxLengthOfPassword = 30;

/**************************************** 其他 */
static CGSize const kPhotoThumbSize = {45, 45};

/**************************************** 全局枚举*/
/**
 *  AVObject的ObjectId字段的筛选规则
 */
typedef NS_ENUM(NSInteger, AVObjectFilterType) {
    /**
	 *  不筛选
	 */
            AVObjectFilterTypeNone,
    /**
	 *  筛选有objectId的
	 */
            AVObjectFilterTypeHasObjectId,
    /**
	 *  筛选没有objectId的
	 */
            AVObjectFilterTypeNoObjectId
};
/* 待办事项状态 */
typedef NS_ENUM(NSInteger, TodoStatus) {
    /* 普通 */
            TodoStatusNormal,
    /* 延迟 */
            TodoStatusSnoozed,
    /* 过期 */
            TodoStatusOverdue
};
/**
 *  同步类型
 */
typedef NS_ENUM(NSInteger, SyncType) {
    /**
	 *  增量同步（只同步客户端和服务器不同的部分）
	 */
            SyncTypeIncrementalSync,
    /**
	 *  提交变更（上传客户端中被修改过的数据）
	 */
            SyncTypeSendChanges,
    /**
	 *  全量同步（同步所有数据并对差异数据进行对比）
	 */
            SyncTypeFullSync
};
/* 同步状态 */
typedef NS_ENUM(NSInteger, SyncStatus) {
    /* 等待同步 */
            SyncStatusWaiting,
    /* 同步中 */
            SyncStatusSynchronizing,
    /* 同步完成 */
            SyncStatusSynchronized
};

#endif /* SGConstants_h */
