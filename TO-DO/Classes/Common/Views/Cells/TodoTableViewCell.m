//
//  TodoTableViewCell.m
//  TO-DO
//
//  Created by Siegrain on 16/5/23.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import <SDAutoLayout/UITableView+SDAutoTableViewCellHeight.h>
#import "CDTodo.h"
#import "NSDateFormatter+Extension.h"
#import "SDWebImageManager.h"
#import "TodoTableViewCell.h"
#import "UIImage+Extension.h"
#import "UIView+SDAutoLayout.h"
#import "ZLIconLabel.h"
#import "UIImage+Compression.h"
#import "UIKit+AFNetworking.h"

static CGFloat const kButtonSize = 45;
static CGFloat const kSlideItemWidth = 60;

@interface
TodoTableViewCell ()
@property(nonatomic, assign) UIEdgeInsets cellInsets;
@property(nonatomic, assign) TodoIdentifier identifier;
@property(nonatomic, strong) UILabel *timeLabel;
@property(nonatomic, strong) UILabel *meridiemLabel;
@property(nonatomic, strong) UIImageView *photoView;
@property(nonatomic, strong) UILabel *todoTitleLabel;
@property(nonatomic, strong) UILabel *todoContentLabel;
@property(nonatomic, strong) UIButton *statusButton;
@end

@implementation TodoTableViewCell
#pragma mark - initial

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _cellInsets = UIEdgeInsetsMake(kScreenHeight * kCellVerticalInsetsRatioByScreenHeight, kScreenHeight * kCellHorizontalInsetsRatioByScreenHeight, kScreenHeight * kCellVerticalInsetsRatioByScreenHeight, kScreenHeight * kCellHorizontalInsetsRatioByScreenHeight);
        _identifier = (TodoIdentifier) [kTodoIdentifierArray indexOfObject:reuseIdentifier];
        
        [self setup];
        [self bindConstraints];
    }
    return self;
}

- (void)setModel:(CDTodo *)model {
    _model = model;
    
    if (model.photoImage) {
        NSString * identifier = model.identifier;   //如果这个东西在下面的block中读取，可能会造成_cd_rawData but the object is not being turned into a fault的错误
        [[GCDQueue globalQueueWithLevel:DISPATCH_QUEUE_PRIORITY_DEFAULT] async:^{
            UIImage * image = [[UIImage imageWithContentsOfFile:SGThumbPath(identifier)] jm_imageWithRoundedCornersAndSize:kPhotoThumbSize andCornerRadius:kPhotoThumbSize.width / 2];
            [[GCDQueue mainQueue] async:^{
                _photoView.image = image;
            }];
        }];
    }
    else _photoView.image = [UIImage new];
    
    // Mark: 苹果的智障框架，系统是24小时制就打印不出12小时，非要设置地区，且该地区只能转换为12小时制
    NSDateFormatter *formatter = [NSDateFormatter dateFormatterWithFormatString:@"h"];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    _timeLabel.text = [formatter stringFromDate:_model.deadline];
    formatter.dateFormat = @"a";
    _meridiemLabel.text = [[formatter stringFromDate:_model.deadline] lowercaseString];
    
    _todoTitleLabel.text = _model.title;
    _todoContentLabel.text = _model.sgDescription;
    
    NSString *statusImageName = _model.isCompleted.boolValue ? @"status-complete" : [NSString stringWithFormat:@"status-%d", _model.status.intValue];
    [_statusButton setImage:[UIImage imageNamed:statusImageName] forState:UIControlStateNormal];
    [self configureSwipeBehavior];
    
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
}

- (void)setup {
    self.selectionStyle = UITableViewCellSelectionStyleDefault;
    self.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageWithColor:ColorWithRGBA(0xFF3366, .2)]];
    
    _timeLabel = [UILabel new];
    _timeLabel.font = [SGHelper themeFontWithSize:22];
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_timeLabel];
    
    _meridiemLabel = [UILabel new];
    _meridiemLabel.font = [SGHelper themeFontWithSize:13];
    _meridiemLabel.textColor = [SGHelper subTextColor];
    _meridiemLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_meridiemLabel];
    
    _photoView = [UIImageView new];
    _photoView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:_photoView];
    
    _todoTitleLabel = [UILabel new];
    _todoTitleLabel.textAlignment = NSTextAlignmentLeft;
    _todoTitleLabel.font = [SGHelper themeFontWithSize:18];
    [self.contentView addSubview:_todoTitleLabel];
    
    _todoContentLabel = [UILabel new];
    _todoContentLabel.font = [SGHelper themeFontWithSize:13];
    _todoContentLabel.textColor = [SGHelper subTextColor];
    [self.contentView addSubview:_todoContentLabel];
    
    _statusButton = [UIButton new];
    [self.contentView addSubview:_statusButton];
}

- (void)bindConstraints {
    _timeLabel.sd_layout
            .topSpaceToView(self.contentView, _cellInsets.top + 2.5)
            .leftSpaceToView(self.contentView, _cellInsets.left)
            .heightIs(22)
            .widthIs(30);
    
    _meridiemLabel.sd_layout
            .topSpaceToView(_timeLabel, 2)
            .leftEqualToView(_timeLabel)
            .heightIs(10)
            .widthRatioToView(_timeLabel, 1);
    
    _photoView.sd_layout
            .topSpaceToView(self.contentView, _cellInsets.top - 3)
            .leftSpaceToView(_timeLabel, _cellInsets.left)
            .widthIs(kButtonSize)
            .heightIs(kButtonSize);
    
    _statusButton.sd_layout
            .centerYEqualToView(_photoView)
            .rightSpaceToView(self.contentView, _cellInsets.right)
            .widthIs(15)
            .heightEqualToWidth();
    
    // Mark: SDAutoLayout 在设置约束时要注意设置的顺序，不能在约束中使用未被约束的控件。
    _todoTitleLabel.sd_layout
            .leftSpaceToView(_photoView, 20)
            .topSpaceToView(self.contentView, _cellInsets.top)
            .rightSpaceToView(_statusButton, 10)
            .heightIs(20);
    
    _todoContentLabel.sd_layout
            .topSpaceToView(_todoTitleLabel, 2)
            .leftEqualToView(_todoTitleLabel)
            .rightEqualToView(_todoTitleLabel)
            .heightIs(20);
}

- (void)configureSwipeBehavior {
    if (_model.disableSwipeBehavior) {
        self.leftButtons = @[];
        self.rightButtons = @[];
        return;
    }
    
    [[GCDQueue globalQueueWithLevel:DISPATCH_QUEUE_PRIORITY_DEFAULT] async:^{
        self.rightExpansion.triggerAnimation.easingFunction = self.leftExpansion.triggerAnimation.easingFunction = MGSwipeEasingFunctionQuadIn;
        self.rightExpansion.expansionLayout = self.leftExpansion.expansionLayout = MGSwipeExpansionLayoutBorder;
        self.rightSwipeSettings.transition = self.leftSwipeSettings.transition = MGSwipeTransitionBorder;
        self.rightExpansion.fillOnTrigger = self.leftExpansion.fillOnTrigger = YES;
        self.rightExpansion.buttonIndex = self.leftExpansion.buttonIndex = 0;
        self.rightSwipeSettings.keepButtonsSwiped = NO;
        self.leftSwipeSettings.keepButtonsSwiped = YES;
        self.rightExpansion.threshold = 2;
        self.leftExpansion.threshold = 1;
        
        __weak typeof(self) weakSelf = self;
        MGSwipeButton *completeButton = [MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:@"task_complete"] backgroundColor:[SGHelper themeColorCyan] callback:^BOOL(MGSwipeTableCell *sender) {
            if (weakSelf.todoDidSwipe) return _todoDidSwipe(weakSelf, TodoSwipeOperationComplete);
            return NO;
        }];
        MGSwipeButton *snoozeButton = [MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:@"task_snooze"] backgroundColor:[SGHelper themeColorYellow] callback:^BOOL(MGSwipeTableCell *sender) {
            if (weakSelf.todoDidSwipe) return _todoDidSwipe(weakSelf, TodoSwipeOperationSnooze);
            return NO;
        }];
        MGSwipeButton *removeButton = [MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:@"task_remove"] backgroundColor:[UIColor redColor] callback:^BOOL(MGSwipeTableCell *sender) {
            if (weakSelf.todoDidSwipe) return _todoDidSwipe(weakSelf, TodoSwipeOperationRemove);
            return NO;
        }];
        
        completeButton.width = snoozeButton.width = removeButton.width = kSlideItemWidth;
        [[GCDQueue mainQueue] async:^{
            self.rightButtons = @[completeButton];
            self.leftButtons = @[snoozeButton, removeButton];
        }];
    }];
}

- (void)updateConstraints {
    if (_model.photoUrl || _model.photoPath) {
        _photoView.sd_layout.widthIs(kButtonSize);
        _todoTitleLabel.sd_layout.leftSpaceToView(_photoView, 20);
    } else {
        _photoView.sd_layout.widthIs(0);
        _todoTitleLabel.sd_layout.leftSpaceToView(_photoView, 0);
    }
    
    if (!_model.sgDescription.length) {
        _todoTitleLabel.sd_layout.topSpaceToView(self.contentView, _cellInsets.top + 10);
        [self setupAutoHeightWithBottomView:_photoView bottomMargin:_cellInsets.bottom];
    } else {
        _todoTitleLabel.sd_layout.topSpaceToView(self.contentView, _cellInsets.top);
        [self setupAutoHeightWithBottomView:_todoContentLabel bottomMargin:_cellInsets.bottom + 2];
    }
    
    [super updateConstraints];
}
@end
