//
//  LCSyncRecord.m
//  TO-DO
//
//  Created by Siegrain on 16/6/4.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "CDSyncRecord.h"
#import "LCSyncRecord.h"

@implementation LCSyncRecord
@dynamic isFinished;
@dynamic phoneIdentifier;
@dynamic syncBeginTime;
@dynamic syncEndTime;
@dynamic user;
@dynamic syncType;
@dynamic commitCount;
@dynamic downloadCount;
@dynamic recordMark;

+ (NSString*)parseClassName
{
    return @"SyncRecord";
}
@end
