//
//  MRUserDataManager.m
//  TO-DO
//
//  Created by Siegrain on 16/6/2.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "CDUser.h"
#import "LCUser.h"
#import "MRUserDataManager.h"

@interface
MRUserDataManager ()
@end

@implementation MRUserDataManager
#pragma mark - handle sign up & sign in
- (BOOL)createUserByLCUser:(LCUser*)lcUser
{
    CDUser* user = [CDUser MR_createEntity];
    user.name = lcUser.name;
    user.avatar = lcUser.avatar;
    user.avatarData = UIImageJPEGRepresentation(lcUser.avatarImage, 0.5);
    user.createAt = lcUser.createdAt;
    user.email = lcUser.email;
    user.username = lcUser.username;
    user.objectId = lcUser.objectId;

    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];

    return YES;
}
@end
