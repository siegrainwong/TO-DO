//
//  GCDUtil.m
//  zhihuDaily
//
//  Created by Siegrain on 16/3/16.
//  Copyright © 2016年 siegrain.zhihuDaily. All rights reserved.
//

#import "GCDQueue.h"

@implementation GCDQueue
#pragma mark - 执行同步异步
- (void)async:(dispatch_block_t)block
{
    dispatch_async(self.queue, block);
}
- (void)asyncWithGroup:(dispatch_group_t)group block:(dispatch_block_t)block
{
    dispatch_group_async(group, self.queue, block);
}
- (void)asyncGroupNotify:(dispatch_group_t)group block:(dispatch_block_t)block
{
    dispatch_group_notify(group, self.queue, block);
}

- (void)sync:(dispatch_block_t)block
{
    dispatch_sync(self.queue, block);
}

#pragma mark -
+ (instancetype)mainQueue
{
    static GCDQueue* util = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        util = [[GCDQueue alloc] init];
        util.queue = dispatch_get_main_queue();
    });
    return util;
}

+ (instancetype)globalQueueWithLevel:(dispatch_queue_priority_t)priority;
{
    static GCDQueue* util = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        util = [[GCDQueue alloc] init];
        util.queue = dispatch_get_global_queue(priority, 0);
    });
    return util;
}

@end
