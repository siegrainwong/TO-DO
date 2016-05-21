//
//  SGTodo.m
//  TO-DO
//
//  Created by Siegrain on 16/5/21.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "SGTodo.h"

@implementation SGTodo
@dynamic title;
@dynamic sgDescription;
@dynamic deadline;
@dynamic location;
@dynamic user;

+ (NSString*)parseClassName
{
    return @"SGTodo";
}
@end
