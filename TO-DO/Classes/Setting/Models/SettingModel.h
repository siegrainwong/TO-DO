//
// Created by Siegrain on 16/12/18.
// Copyright (c) 2016 com.siegrain. All rights reserved.
//


#import "SGCellViewModel.h"

typedef NS_ENUM(NSInteger, SettingCellStyle) {
    SettingCellStyleNone,
    SettingCellStyleNavigator,
    SettingCellStyleSwitch
};

@interface SettingModel : SGCellViewModel
@property(nonatomic, copy) NSString *iconName;
@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *content;

@property(nonatomic, assign) BOOL isOn;

- (instancetype)initWithIconName:(NSString *)iconName title:(NSString *)title content:(NSString *)content style:(SettingCellStyle)style isOn:(BOOL)isOn;

+ (instancetype)modelWithIconName:(NSString *)iconName title:(NSString *)title content:(NSString *)content style:(SettingCellStyle)style isOn:(BOOL)isOn;


@end