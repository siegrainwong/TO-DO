//
// Created by Siegrain on 16/11/21.
// Copyright (c) 2016 com.siegrain. All rights reserved.
//

#import "DetailViewController.h"
#import "BEMCheckBox.h"
#import "CDTodo.h"
#import "DetailTableViewController.h"
#import "SGTextView.h"

static CGFloat const kCheckBoxHeight = 35;
static CGFloat const kTitleHeight = 35;
//static CGFloat const kTableHeight = 350;
static CGFloat const kOffset = 10;
static NSUInteger const kMaxLength = 50;

@interface DetailViewController () <UITextViewDelegate>
@property(nonatomic, strong) CDTodo *model;

@property(nonatomic, strong) UIView *container;
@property(nonatomic, strong) UIView *titleContainer;

@property(nonatomic, strong) BEMCheckBox *checkBox;
@property(nonatomic, strong) SGTextView *titleTextView;
@property(nonatomic, strong) DetailTableViewController *tableViewController;

@property(nonatomic, assign) CGFloat tableViewHeight;
@end

@implementation DetailViewController

#pragma mark - release

- (void)dealloc {
    DDLogWarn(@"%s", __func__);
}

#pragma mark - accessors

- (void)setModel:(CDTodo *)model {
    _model = model;
    
    _titleTextView.text = model.title;
    _checkBox.on = model.isCompleted.boolValue;
    _tableViewController.model = model;
    
    __weak __typeof(self) weakSelf = self;
    [_tableViewController setTableViewDidCalculateHeight:^(CGFloat height) {
        weakSelf.tableViewHeight = height;
        [weakSelf.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.offset(weakSelf.tableViewHeight);
        }];
        
        [weakSelf.container mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.offset(weakSelf.height);
        }];
    }];
}

- (CGFloat)height {
    CGFloat height = self.titleContainerHeight + self.tableViewHeight;
    return height > kScreenHeight ? kScreenHeight : height;
}

- (UITableView *)tableView {
    return _tableViewController.tableView;
}

- (CGFloat)titleContainerHeight {
    return kOffset * 2 + kTitleHeight;
}

#pragma mark - initial

- (instancetype)init {
    if (self = [super init]) {
        [self setupViews];
        [self bindConstraints];
    }
    return self;
}

- (void)setupViews {
    [super setupViews];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    _container = [UIView new];
    _container.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_container];
    
    _titleContainer = [UIView new];
    [_container addSubview:_titleContainer];
    
    _checkBox = [BEMCheckBox new];
    _checkBox.onTintColor = [SGHelper themeColorRed];
    _checkBox.onFillColor = [SGHelper themeColorRed];
    _checkBox.onCheckColor = [UIColor whiteColor];
    _checkBox.animationDuration = .2;
    _checkBox.onAnimationType = _checkBox.offAnimationType = BEMAnimationTypeFill;
    _checkBox.lineWidth = 1;
    [_titleContainer addSubview:_checkBox];
    
    _titleTextView = [SGTextView new];
    _titleTextView.delegate = self;
    _titleTextView.container = _titleContainer;
    _titleTextView.containerInitialHeight = self.titleContainerHeight;
    _titleTextView.maxLength = kMaxLength;
    _titleTextView.maxLineCount = 3;
    _titleTextView.font = [SGHelper themeFontWithSize:17];
    _titleTextView.tintColor = [SGHelper themeColorRed];
    _titleTextView.scrollEnabled = NO;
    [_titleContainer addSubview:_titleTextView];
    
    _tableViewController = [DetailTableViewController new];
    [self addChildViewController:_tableViewController];
    [_container addSubview:_tableViewController.view];
}

- (void)bindConstraints {
    [super bindConstraints];
    
    [_container mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.offset(0);
        make.height.offset(self.height);
    }];
    
    [_titleContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.offset(0);
        make.height.offset(self.titleContainerHeight);
    }];
    
    [_checkBox mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.offset(kOffset);
        make.height.width.offset(kCheckBoxHeight);
    }];
    
    [_titleTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_checkBox.mas_right).offset(kOffset - 4);
        make.top.equalTo(_checkBox).offset(-2);
        make.right.bottom.offset(-kOffset);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_titleContainer.mas_bottom).offset(0);
        make.left.right.offset(0);
        make.height.offset(CGFLOAT_MIN);
    }];
}


#pragma mark - textview

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    //return时关掉键盘，不提行
    if ([text isEqualToString:@"\n"]) {
        [self.view endEditing:YES];
        return NO;
    }
    
    return [_titleTextView textView:textView shouldChangeTextInRange:range replacementText:text];
}

- (void)textViewDidChange:(UITextView *)textView {
    return [_titleTextView textViewDidChange:textView];
}

@end