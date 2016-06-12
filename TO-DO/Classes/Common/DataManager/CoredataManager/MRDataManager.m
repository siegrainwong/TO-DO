//
//  MRDataManager.m
//  TO-DO
//
//  Created by Siegrain on 16/6/2.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "MRDataManager.h"

@implementation MRDataManager
#pragma mark - save
- (void)saveWithBlock:(void (^)(bool succeed))complete
{
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError* error) {
        if (!contextDidSave) {
            [SCLAlertHelper errorAlertWithContent:error.localizedDescription];
            if (complete) return complete(NO);
        }
        if (complete) return complete(YES);
    }];
}
@end
