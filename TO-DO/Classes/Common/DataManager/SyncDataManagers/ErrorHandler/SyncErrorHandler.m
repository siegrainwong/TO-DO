//
//  SyncErrorHandler.m
//  TO-DO
//
//  Created by Siegrain on 16/6/7.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "GCDQueue.h"
#import "SCLAlertHelper.h"
#import "SyncErrorHandler.h"

@implementation SyncErrorHandler
- (id)returnWithError:(NSError* _Nullable)error description:(NSString* _Nonnull)description
{
    [self errorHandler:error description:description];
    return nil;
}
- (void)returnWithError:(NSError* _Nullable)error description:(NSString* _Nonnull)description returnWithBlock:(void (^_Nullable)(bool succeed))block
{
    [self errorHandler:error description:description];
    [[GCDQueue mainQueue] sync:^{
        return block(NO);
    }];
}

- (void)errorHandler:(NSError* _Nullable)error description:(NSString* _Nonnull)description
{
    [[GCDQueue mainQueue] sync:^{
        if (_isAlert) [SCLAlertHelper errorAlertWithContent:description];
    }];
    DDLogError(@"%@ ::: %@", description, error ? error.localizedDescription : @"");
    if (_errorHandlerWillReturn) _errorHandlerWillReturn();
}

@end
