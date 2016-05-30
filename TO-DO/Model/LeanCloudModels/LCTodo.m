//
//  SGTodo.m
//  TO-DO
//
//  Created by Siegrain on 16/5/21.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "LCTodo.h"

@implementation LCTodo
@dynamic title;
@dynamic sgDescription;
@dynamic deadline;
@dynamic location;
@dynamic user;
@dynamic status;
@dynamic isDeleted;
@dynamic isCompleted;
@dynamic photo;

+ (NSString*)parseClassName
{
    return @"Todo";
}
@end
