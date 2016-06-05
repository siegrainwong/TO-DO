//
//  LCSyncRecord.m
//  TO-DO
//
//  Created by Siegrain on 16/6/4.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "LCSyncRecord.h"

@implementation LCSyncRecord
@dynamic isFinished;
@dynamic phoneIdentifier;
@dynamic syncBeginTime;
@dynamic syncEndTime;
@dynamic user;

+ (NSString*)parseClassName
{
    return @"SyncRecord";
}
@end
