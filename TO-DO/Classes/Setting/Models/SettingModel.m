//
// Created by Siegrain on 16/12/18.
// Copyright (c) 2016 com.siegrain. All rights reserved.
//

#import "SettingModel.h"


@implementation SettingModel
- (instancetype)initWithIconName:(NSString *)iconName title:(NSString *)title content:(NSString *)content style:(SettingCellStyle)style isOn:(BOOL)isOn {
    self = [super init];
    if (self) {
        self.iconName = iconName;
        self.title = title;
        self.content = content;
        self.style = style;
        self.isOn = isOn;
    }
    
    return self;
}

+ (instancetype)modelWithIconName:(NSString *)iconName title:(NSString *)title content:(NSString *)content style:(SettingCellStyle)style isOn:(BOOL)isOn {
    return [[self alloc] initWithIconName:iconName title:title content:content style:style isOn:isOn];
}

@end