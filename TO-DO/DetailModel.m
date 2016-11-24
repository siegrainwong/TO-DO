//
// Created by Siegrain on 16/11/24.
// Copyright (c) 2016 com.siegrain. All rights reserved.
//

#import "DetailModel.h"
#import "SGCoordinate.h"


@implementation DetailModel
- (instancetype)initWithIconName:(NSString *)iconName content:(NSString *)content location:(SGCoordinate *)location photoUrl:(NSString *)photoUrl photoPath:(NSString *)photoPath placeholder:(NSString *)placeholder {
    self = [super init];
    if (self) {
        self.iconName = iconName;
        self.content = content;
        self.location = location;
        self.photoUrl = photoUrl;
        self.photoPath = photoPath;
        self.placeholder = placeholder;
    }
    
    return self;
}

+ (instancetype)modelWithIconName:(NSString *)iconName content:(NSString *)content location:(SGCoordinate *)location photoUrl:(NSString *)photoUrl photoPath:(NSString *)photoPath placeholder:(NSString *)placeholder {
    return [[self alloc] initWithIconName:iconName content:content location:location photoUrl:photoUrl photoPath:photoPath placeholder:placeholder];
}


@end