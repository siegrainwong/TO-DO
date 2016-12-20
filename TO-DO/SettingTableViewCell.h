//
// Created by Siegrain on 16/12/19.
// Copyright (c) 2016 com.siegrain. All rights reserved.
//


@class SettingModel;

static CGFloat const kSpacingRatioToWidth = 0.05f;
static CGFloat const kIconSize = 18;

@interface SettingTableViewCell : UITableViewCell
- (void)setModel:(SettingModel *)model;
@end