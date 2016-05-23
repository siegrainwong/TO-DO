//
//  TodoTableViewCell.m
//  TO-DO
//
//  Created by Siegrain on 16/5/23.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "LCTodo.h"
#import "Macros.h"
#import "TodoHelper.h"
#import "TodoTableViewCell.h"
#import "UIView+SDAutoLayout.h"

static NSInteger const kButtonSize = 45;

@implementation TodoTableViewCell {
    UIEdgeInsets cellInsets;
    TodoIdentifier identifier;
    UILabel* timeLabel;
    UILabel* meridiemLabel;
    UIButton* photoButton;
    UILabel* titleLabel;
    UILabel* contentLabel;
    UIButton* statusButton;
}
#pragma mark - initial
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        cellInsets = UIEdgeInsetsMake(kScreenHeight * kCellVerticalInsetsMuiltipledByHeight, kScreenHeight * kCellHorizontalInsetsMuiltipledByHeight, kScreenHeight * kCellVerticalInsetsMuiltipledByHeight, kScreenHeight * kCellHorizontalInsetsMuiltipledByHeight);
        identifier = [kTodoIdentifierArray indexOfObject:reuseIdentifier];
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        [self setup];
        [self bindConstraints];
    }
    return self;
}
- (void)setup
{
    timeLabel = [UILabel new];
    timeLabel.font = [TodoHelper themeFontWithSize:22];
    timeLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:timeLabel];

    meridiemLabel = [UILabel new];
    meridiemLabel.font = [TodoHelper themeFontWithSize:13];
    meridiemLabel.textColor = [TodoHelper subTextColor];
    meridiemLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:meridiemLabel];

    photoButton = [UIButton new];
    photoButton.layer.masksToBounds = YES;
    photoButton.layer.cornerRadius = kButtonSize / 2;
    [photoButton setImage:[UIImage imageNamed:@"avatar1"]
                 forState:UIControlStateNormal];
    [self.contentView addSubview:photoButton];

    titleLabel = [UILabel new];
    titleLabel.font = [TodoHelper themeFontWithSize:18];
    [self.contentView addSubview:titleLabel];

    contentLabel = [UILabel new];
    contentLabel.font = [TodoHelper themeFontWithSize:13];
    contentLabel.textColor = [TodoHelper subTextColor];
    contentLabel.numberOfLines = 0;
    [self.contentView addSubview:contentLabel];

    statusButton = [UIButton new];
    [statusButton setImage:[UIImage imageNamed:@"status-1"] forState:UIControlStateNormal];
    [self.contentView addSubview:statusButton];
}
- (void)bindConstraints
{
    timeLabel.sd_layout
      .topSpaceToView(self.contentView, cellInsets.top + 2)
      .leftSpaceToView(self.contentView, cellInsets.left)
      .heightIs(22)
      .widthIs(26);

    meridiemLabel.sd_layout
      .topSpaceToView(timeLabel, 2)
      .leftEqualToView(timeLabel)
      .heightIs(10)
      .widthRatioToView(timeLabel, 1);

    photoButton.sd_layout
      .topSpaceToView(self.contentView, cellInsets.top - 3)
      .leftSpaceToView(timeLabel, cellInsets.left)
      .heightIs(kButtonSize)
      .widthEqualToHeight();

    titleLabel.sd_layout
      .leftSpaceToView(photoButton, 20)
      .topSpaceToView(self.contentView, cellInsets.top)
      .rightSpaceToView(statusButton, 10)
      .heightIs(20);

    contentLabel.sd_layout
      .topSpaceToView(titleLabel, 2)
      .leftEqualToView(titleLabel)
      .rightEqualToView(titleLabel)
      .autoHeightRatio(0);

    statusButton.sd_layout
      .centerYEqualToView(photoButton)
      .rightSpaceToView(self.contentView, cellInsets.right)
      .widthIs(15)
      .heightEqualToWidth();

    [self setupAutoHeightWithBottomView:contentLabel bottomMargin:cellInsets.bottom + 2];
}
#pragma mark - set model
- (void)setModel:(LCTodo*)todo
{
    _model = todo;
    timeLabel.text = @"10";
    meridiemLabel.text = @"am";
    titleLabel.text = @"This is a Title!";
    contentLabel.text = @"Starfucks";
}
@end
