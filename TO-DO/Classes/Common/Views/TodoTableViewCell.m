//
//  TodoTableViewCell.m
//  TO-DO
//
//  Created by Siegrain on 16/5/23.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "DateUtil.h"
#import "LCTodo.h"
#import "Macros.h"
#import "NSDateFormatter+Extension.h"
#import "SDWebImageManager.h"
#import "TodoHelper.h"
#import "TodoTableViewCell.h"
#import "UIImage+Extension.h"
#import "UIImage+Qiniu.h"
#import "UIView+SDAutoLayout.h"

static NSInteger const kButtonSize = 45;
static NSInteger const kStatusButtonSize = 15;

@implementation TodoTableViewCell {
    UIEdgeInsets cellInsets;
    TodoIdentifier identifier;
    UILabel* timeLabel;
    UILabel* meridiemLabel;
    UIButton* photoButton;
    UILabel* todoTitleLabel;
    UILabel* todoContentLabel;
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
        [self configureSwipeBehavior];
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

    // TODO: 这个地方圆角需要用其他方法来绘制
    photoButton = [UIButton new];
    [self.contentView addSubview:photoButton];

    todoTitleLabel = [UILabel new];
    todoTitleLabel.font = [TodoHelper themeFontWithSize:18];
    [self.contentView addSubview:todoTitleLabel];

    todoContentLabel = [UILabel new];
    todoContentLabel.font = [TodoHelper themeFontWithSize:13];
    todoContentLabel.textColor = [TodoHelper subTextColor];
    todoContentLabel.numberOfLines = 0;
    [self.contentView addSubview:todoContentLabel];

    statusButton = [UIButton new];
    [self.contentView addSubview:statusButton];
}
- (void)bindConstraints
{
    timeLabel.sd_layout
      .topSpaceToView(self.contentView, cellInsets.top + 2.5)
      .leftSpaceToView(self.contentView, cellInsets.left)
      .heightIs(22)
      .widthIs(30);

    meridiemLabel.sd_layout
      .topSpaceToView(timeLabel, 2)
      .leftEqualToView(timeLabel)
      .heightIs(10)
      .widthRatioToView(timeLabel, 1);

    photoButton.sd_layout
      .topSpaceToView(self.contentView, cellInsets.top - 3)
      .leftSpaceToView(timeLabel, cellInsets.left)
      .widthIs(kButtonSize)
      .heightIs(kButtonSize);

    statusButton.sd_layout
      .centerYEqualToView(photoButton)
      .rightSpaceToView(self.contentView, cellInsets.right)
      .widthIs(kStatusButtonSize)
      .heightEqualToWidth();

    // Mark: SDAutoLayout 在设置约束时要注意设置的顺序，不能在约束中使用未被约束的控件。
    todoTitleLabel.sd_layout
      .leftSpaceToView(photoButton, 20)
      .topSpaceToView(self.contentView, cellInsets.top)
      .rightSpaceToView(statusButton, 10)
      .heightIs(20);

    todoContentLabel.sd_layout
      .topSpaceToView(todoTitleLabel, 2)
      .leftEqualToView(todoTitleLabel)
      .rightEqualToView(todoTitleLabel)
      .autoHeightRatio(0)
      .maxHeightIs(MAXFLOAT);
}
- (void)configureSwipeBehavior
{
    self.rightSwipeSettings.transition = MGSwipeTransitionBorder;
    self.rightSwipeSettings.keepButtonsSwiped = YES;
    self.rightExpansion.fillOnTrigger = YES;
    self.rightExpansion.buttonIndex = 0;
    self.rightExpansion.threshold = 1;
    self.rightExpansion.expansionLayout = MGSwipeExpansionLayoutBorder;
    self.rightExpansion.triggerAnimation.easingFunction = MGSwipeEasingFunctionQuadIn;

    __weak typeof(self) weakSelf = self;
    MGSwipeButton* completeButton = [MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:@"check"] backgroundColor:ColorWithRGB(0x33AF67) callback:^BOOL(MGSwipeTableCell* sender) {
        if (_todoDidComplete) return _todoDidComplete(weakSelf);
        return NO;
    }];
    MGSwipeButton* snoozeButton = [MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:@"clock"] backgroundColor:[UIColor brownColor] callback:^BOOL(MGSwipeTableCell* sender) {
        if (_todoDidSnooze) return _todoDidSnooze(weakSelf);
        return NO;
    }];
    MGSwipeButton* deleteButton = [MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:@"cross"] backgroundColor:[UIColor redColor] callback:^BOOL(MGSwipeTableCell* sender) {
        if (_todoDidRemove) return _todoDidRemove(weakSelf);
        return NO;
    }];

    completeButton.width = 60;
    snoozeButton.width = completeButton.width;
    deleteButton.width = completeButton.width;

    self.rightButtons = @[ completeButton, snoozeButton, deleteButton ];
}
#pragma mark - set model
- (void)setModel:(LCTodo*)todo
{
    if (todo.photo.length) {
        if (!_model.photoImage) {
            [[SDWebImageManager sharedManager] downloadImageWithURL:GetPictureUrl(todo.photo, kQiniuImageStyleThumbnail) options:SDWebImageRefreshCached progress:nil completed:^(UIImage* image, NSError* error, SDImageCacheType cacheType, BOOL finished, NSURL* imageURL) {
                todo.photoImage = [image imageAddCornerWithRadius:image.size.width / 2 andSize:image.size];
                [photoButton setImage:todo.photoImage forState:UIControlStateNormal];
            }];
        } else {
            [photoButton setImage:todo.photoImage forState:UIControlStateNormal];
        }
    }

    _model = todo;
    // Mark: 苹果的智障框架，系统是24小时制就打印不出12小时，非要设置地区，且该地区只能转换为12小时制
    NSDateFormatter* formatter = [NSDateFormatter dateFormatterWithFormatString:@"h"];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    timeLabel.text = [formatter stringFromDate:_model.deadline];
    formatter.dateFormat = @"a";
    meridiemLabel.text = [[formatter stringFromDate:_model.deadline] lowercaseString];

    [statusButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"status-%ld", _model.status]] forState:UIControlStateNormal];

    todoTitleLabel.text = _model.title;
    todoContentLabel.text = _model.sgDescription;

    [self setupAutoHeightWithBottomView:photoButton bottomMargin:cellInsets.bottom];

    [self updateConstraints];
}
#pragma mark - update constraints
- (void)updateConstraints
{
    if (!_model.photo.length) {
        photoButton.sd_layout.widthIs(0);
        todoTitleLabel.sd_layout.leftSpaceToView(photoButton, 0);
    } else {
        photoButton.sd_layout.widthIs(kButtonSize);
        todoTitleLabel.sd_layout.leftSpaceToView(photoButton, 20);
    }

    if (!_model.sgDescription.length) {
        todoTitleLabel.sd_layout.topSpaceToView(self.contentView, cellInsets.top + 10);
        [self setupAutoHeightWithBottomView:photoButton bottomMargin:cellInsets.bottom];
    } else {
        todoTitleLabel.sd_layout.topSpaceToView(self.contentView, cellInsets.top);
        [self setupAutoHeightWithBottomView:todoContentLabel bottomMargin:cellInsets.bottom + 2];
    }

    [super updateConstraints];
}
@end
