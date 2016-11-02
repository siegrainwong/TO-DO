//
//  TodoHeaderCell.m
//  TO-DO
//
//  Created by Siegrain on 16/5/25.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "DateUtil.h"
#import "TodoHeaderCell.h"
#import "SGHelper.h"
#import "UIView+SDAutoLayout.h"

@interface
TodoHeaderCell ()
@property (nonatomic, readwrite, strong) UILabel* label;
@end

@implementation TodoHeaderCell
+ (instancetype)headerCell
{
    TodoHeaderCell* cell = [TodoHeaderCell new];
    [cell setup];
    return cell;
}
- (void)setup
{
    _label = [UILabel new];
    _label.font = [SGHelper themeFontWithSize:13];
    _label.textColor = [SGHelper subTextColor];
    _label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_label];

    _label.sd_layout
      .centerXEqualToView(self)
      .centerYEqualToView(self)
      .leftEqualToView(self)
      .rightEqualToView(self)
      .autoHeightRatio(0);
}

- (void)setText:(NSString*)text
{
    _text = text;
    _text = [DateUtil dateString:_text fromFormat:@"yyyy-MM-dd" toFormat:@"MMM d"];
    _label.text = _text;
}
@end
