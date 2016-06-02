//
//  CDTodo.m
//  TO-DO
//
//  Created by Siegrain on 16/6/2.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "CDTodo.h"
#import "CDUser.h"

@implementation CDTodo
@synthesize photoImage = _photoImage;
- (UIImage*)avatarPhoto
{
    if (!_photoImage) {
        _photoImage = [UIImage imageWithData:self.photoData];
    }
    return _photoImage;
}

+ (NSString*)MR_entityName
{
    return @"Todo";
}
@end
