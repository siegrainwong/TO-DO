//
//  CDUser.m
//  TO-DO
//
//  Created by Siegrain on 16/6/2.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "CDTodo.h"
#import "CDUser.h"
#import "LCUser.h"

@implementation CDUser
@synthesize avatarPhoto = _avatarPhoto;
- (UIImage*)avatarPhoto
{
    if (!_avatarPhoto) {
        _avatarPhoto = [UIImage imageWithData:self.avatarData];
    }
    return _avatarPhoto;
}
+ (instancetype)userWithLCUser:(LCUser*)lcUser
{
    return [CDUser MR_findFirstByAttribute:@"objectId" withValue:lcUser.objectId];
}
+ (instancetype)userWithLCUser:(LCUser*)lcUser inContext:(NSManagedObjectContext*)context
{
    return [CDUser MR_findFirstByAttribute:@"objectId" withValue:lcUser.objectId inContext:context];
}

// Mark: 如果你ManagedObject的类名和数据库实体名不一样，那么你要自己配置一下。
+ (NSString*)MR_entityName
{
    return @"User";
}
@end
