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
- (CDUser *)createUserByLCUser:(LCUser*)lcUser
{
    CDUser* user = [CDUser MR_createEntity];
    user.name = lcUser.name;
    user.avatar = lcUser.avatar;
    user.avatarData = UIImageJPEGRepresentation(lcUser.avatarImage, 0.5);
    user.createdAt = lcUser.createdAt;
    user.updatedAt = lcUser.updatedAt;
    user.email = lcUser.email;
    user.username = lcUser.username;
    user.objectId = lcUser.objectId;
    // 该值在本地每次创建用户时生成
    user.phoneIdentifier = [[NSUUID UUID] UUIDString];

    [[NSUserDefaults standardUserDefaults] setObject:user.phoneIdentifier forKey:user.objectId];
    MR_saveAndWait();

    return user;
}
@end
