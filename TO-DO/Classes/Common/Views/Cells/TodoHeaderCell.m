//
//  TodoHeaderCell.m
//  TO-DO
//
//  Created by Siegrain on 16/5/25.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "DateUtil.h"
#import "TodoHeaderCell.h"
#import "TodoHelper.h"
#import "UIView+SDAutoLayout.h"

@implementation TodoHeaderCell {
    UILabel* label;
}
+ (instancetype)headerCell
{
    TodoHeaderCell* cell = [TodoHeaderCell new];
    [cell setup];
    return cell;
}
- (void)setup
{
    label = [UILabel new];
    label.font = [TodoHelper themeFontWithSize:13];
    label.textColor = [TodoHelper subTextColor];
    label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label];

    label.sd_layout
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
    label.text = _text;
}
@end
