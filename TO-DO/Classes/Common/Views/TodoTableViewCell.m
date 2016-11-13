//
//  TodoTableViewCell.m
//  TO-DO
//
//  Created by Siegrain on 16/5/23.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "CDTodo.h"
#import "DateUtil.h"
#import "Macros.h"
#import "NSDateFormatter+Extension.h"
#import "SDWebImageManager.h"
#import "SGHelper.h"
#import "TodoTableViewCell.h"
#import "UIImage+Extension.h"
#import "UIImage+Qiniu.h"
#import "UIView+SDAutoLayout.h"

static NSInteger const kButtonSize = 45;
static CGFloat const kSlideItemWidth = 60;

@interface
TodoTableViewCell ()
@property(nonatomic, readwrite, assign) UIEdgeInsets cellInsets;
@property(nonatomic, readwrite, assign) TodoIdentifier identifier;
@property(nonatomic, readwrite, strong) UILabel *timeLabel;
@property(nonatomic, readwrite, strong) UILabel *meridiemLabel;
@property(nonatomic, readwrite, strong) UIButton *photoButton;
@property(nonatomic, readwrite, strong) UILabel *todoTitleLabel;
@property(nonatomic, readwrite, strong) UILabel *todoContentLabel;
@property(nonatomic, readwrite, strong) UIButton *statusButton;
@end

@implementation TodoTableViewCell
#pragma mark - initial

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _cellInsets = UIEdgeInsetsMake(kScreenHeight * kCellVerticalInsetsMuiltipledByHeight, kScreenHeight * kCellHorizontalInsetsMuiltipledByHeight, kScreenHeight * kCellVerticalInsetsMuiltipledByHeight, kScreenHeight * kCellHorizontalInsetsMuiltipledByHeight);
        _identifier = [kTodoIdentifierArray indexOfObject:reuseIdentifier];
        
        [self setup];
        [self bindConstraints];
        [self configureSwipeBehavior];
    }
    return self;
}

- (void)setup {
    self.selectionStyle = UITableViewCellSelectionStyleDefault;
    self.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageWithColor:ColorWithRGBA(0xFF3366, .4)]];
    
    _timeLabel = [UILabel new];
    _timeLabel.font = [SGHelper themeFontWithSize:22];
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_timeLabel];
    
    _meridiemLabel = [UILabel new];
    _meridiemLabel.font = [SGHelper themeFontWithSize:13];
    _meridiemLabel.textColor = [SGHelper subTextColor];
    _meridiemLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_meridiemLabel];
    
    // TODO: 这个地方圆角需要用其他方法来绘制
    _photoButton = [UIButton new];
    [self.contentView addSubview:_photoButton];
    
    _todoTitleLabel = [UILabel new];
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
    
    _photoButton.sd_layout
            .topSpaceToView(self.contentView, _cellInsets.top - 3)
            .leftSpaceToView(_timeLabel, _cellInsets.left)
            .widthIs(kButtonSize)
            .heightIs(kButtonSize);
    
    _statusButton.sd_layout
            .centerYEqualToView(_photoButton)
            .rightSpaceToView(self.contentView, _cellInsets.right)
            .widthIs(15)
            .heightEqualToWidth();
    
    // Mark: SDAutoLayout 在设置约束时要注意设置的顺序，不能在约束中使用未被约束的控件。
    _todoTitleLabel.sd_layout
            .leftSpaceToView(_photoButton, 20)
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
    MGSwipeButton *completeButton = [MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:@"check"] backgroundColor:ColorWithRGB(0x33AF67) callback:^BOOL(MGSwipeTableCell *sender) {
        if (_todoDidComplete) return _todoDidComplete(weakSelf);
        return NO;
    }];
    MGSwipeButton *snoozeButton = [MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:@"clock"] backgroundColor:[UIColor brownColor] callback:^BOOL(MGSwipeTableCell *sender) {
        if (_todoDidSnooze) return _todoDidSnooze(weakSelf);
        return NO;
    }];
    MGSwipeButton *deleteButton = [MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:@"cross"] backgroundColor:[UIColor redColor] callback:^BOOL(MGSwipeTableCell *sender) {
        if (_todoDidRemove) return _todoDidRemove(weakSelf);
        return NO;
    }];
    
    completeButton.width = snoozeButton.width = deleteButton.width = kSlideItemWidth;
    
    self.rightButtons = @[completeButton];
    self.leftButtons = @[snoozeButton, deleteButton];
}

#pragma mark - set model

- (void)setModel:(CDTodo *)todo {
    _model = todo;
    
    __weak __typeof(self) weakSelf = self;
    if (todo.photoPath) {
        todo.photoImage = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@.jpg", [SGHelper photoPath], todo.identifier]];
        [_photoButton setImage:[todo.photoImage jm_imageWithRoundedCornersAndSize:CGSizeMake(kButtonSize, kButtonSize) andCornerRadius:kButtonSize / 2] forState:UIControlStateNormal];
    } else if (todo.photoUrl) {
        SDImageDownload(todo.photoUrl, ^(UIImage *image) {
            todo.photoImage = image;
            [weakSelf.photoButton setImage:[todo.photoImage jm_imageWithRoundedCornersAndSize:CGSizeMake(kButtonSize, kButtonSize) andCornerRadius:kButtonSize / 2] forState:UIControlStateNormal];
        });
    }
    
    // Mark: 苹果的智障框架，系统是24小时制就打印不出12小时，非要设置地区，且该地区只能转换为12小时制
    NSDateFormatter *formatter = [NSDateFormatter dateFormatterWithFormatString:@"h"];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    _timeLabel.text = [formatter stringFromDate:_model.deadline];
    formatter.dateFormat = @"a";
    _meridiemLabel.text = [[formatter stringFromDate:_model.deadline] lowercaseString];
    
    [_statusButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"status-%d", [_model.status integerValue]]] forState:UIControlStateNormal];
    
    _todoTitleLabel.text = _model.title;
    _todoContentLabel.text = _model.sgDescription;
    
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
}

#pragma mark - update constraints

- (void)updateConstraints {
    if (!_model.photoImage) {
        _photoButton.sd_layout.widthIs(0);
        _todoTitleLabel.sd_layout.leftSpaceToView(_photoButton, 0);
    } else {
        _photoButton.sd_layout.widthIs(kButtonSize);
        _todoTitleLabel.sd_layout.leftSpaceToView(_photoButton, 20);
    }
    
    if (!_model.sgDescription.length) {
        _todoTitleLabel.sd_layout.topSpaceToView(self.contentView, _cellInsets.top + 10);
        [self setupAutoHeightWithBottomView:_photoButton bottomMargin:_cellInsets.bottom];
    } else {
        _todoTitleLabel.sd_layout.topSpaceToView(self.contentView, _cellInsets.top);
        [self setupAutoHeightWithBottomView:_todoContentLabel bottomMargin:_cellInsets.bottom + 2];
    }
    
    [super updateConstraints];
}
@end
