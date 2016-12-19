//
// Created by Siegrain on 16/11/24.
// Copyright (c) 2016 com.siegrain. All rights reserved.
//

#import "DetailModel.h"
#import "SGCoordinate.h"


@implementation DetailModel
#pragma mark - accessors

- (BOOL)hasPhoto {
    return self.photoPath || self.photoUrl;
}

#pragma mark - initializers

- (instancetype)initWithIconName:(NSString *)iconName content:(NSString *)content location:(SGCoordinate *)location photoUrl:(NSString *)photoUrl photoPath:(NSString *)photoPath placeholder:(NSString *)placeholder identifier:(NSString *)identifier cellStyle:(NSInteger)cellStyle {
    self = [super init];
    if (self) {
        self.iconName = iconName;
        self.content = content;
        self.location = location;
        self.photoUrl = photoUrl;
        self.photoPath = photoPath;
        self.placeholder = placeholder;
        self.identifier = identifier;
        self.style = cellStyle;
    }
    
    return self;
}

+ (instancetype)modelWithIconName:(NSString *)iconName content:(NSString *)content location:(SGCoordinate *)location photoUrl:(NSString *)photoUrl photoPath:(NSString *)photoPath placeholder:(NSString *)placeholder identifier:(NSString *)identifier cellStyle:(NSInteger)cellStyle {
    return [[self alloc] initWithIconName:iconName content:content location:location photoUrl:photoUrl photoPath:photoPath placeholder:placeholder identifier:identifier cellStyle:cellStyle];
}


@end