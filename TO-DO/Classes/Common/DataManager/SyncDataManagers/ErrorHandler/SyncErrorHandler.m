//
//  SyncErrorHandler.m
//  TO-DO
//
//  Created by Siegrain on 16/6/7.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "SCLAlertHelper.h"
#import "SyncErrorHandler.h"

NS_ASSUME_NONNULL_BEGIN

@implementation SyncErrorHandler

- (nullable id)returnWithError:(nullable NSError *)error description:(NSString *)description {
    [self errorHandler:error description:description];
    return nil;
}

- (void)returnWithError:(nullable NSError *)error description:(NSString *)description failBlock:(CompleteBlock)block {
    [self errorHandler:error description:description];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        if (block) return block(NO);
    }];
}

- (void)errorHandler:(nullable NSError *)error description:(NSString *)description {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        if (_isAlert) [SCLAlertHelper errorAlertWithContent:description];
    }];
    DDLogError(@"%@ ::: %@", description, error ? error.localizedDescription : @"");
    if (_errorHandlerWillReturn) _errorHandlerWillReturn();
}

@end

NS_ASSUME_NONNULL_END
