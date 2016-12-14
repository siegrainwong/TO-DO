//
// Created by Siegrain on 16/11/21.
// Copyright (c) 2016 com.siegrain. All rights reserved.
//

#import "DetailViewController.h"
#import "BEMCheckBox.h"
#import "CDTodo.h"
#import "DetailTableViewController.h"
#import "SGTextView.h"
#import "MRTodoDataManager.h"
#import "NSNotificationCenter+Extension.h"

//Mark: 这个长度要根据字号来调整，如果不够的话可能会造成无法提行的Bug
static CGFloat const kTitleTextViewHeight = 40;
static CGFloat const kCheckBoxHeight = 38;
static CGFloat const kOffset = 10;
static NSUInteger const kMaxLength = 50;

@interface DetailViewController () <UITextViewDelegate, BEMCheckBoxDelegate>
@property(nonatomic, strong) CDTodo *model;

@property(nonatomic, strong) UIView *titleContainer;

@property(nonatomic, strong) BEMCheckBox *checkBox;
@property(nonatomic, strong) SGTextView *titleTextView;
@property(nonatomic, strong) DetailTableViewController *tableViewController;

@property(nonatomic, strong) MRTodoDataManager *dataManager;
@property(nonatomic, assign) CGFloat tableViewHeight;
@property(nonatomic, assign) CGFloat overHeight;
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
    }];
    [_titleTextView setTextViewDidUpdateHeight:^(CGFloat height) {
        CGFloat overHeight = weakSelf.maxHeight - weakSelf.titleContainerHeight - weakSelf.tableViewHeight;
        if (overHeight >= 0) return;
        
        weakSelf.overHeight = fabs(overHeight);
        [weakSelf.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.offset(weakSelf.tableViewHeight - weakSelf.overHeight);
        }];
    }];
}

- (CGFloat)height {
    CGFloat height = self.titleContainerHeight + self.tableViewHeight;
    return height > self.maxHeight ? self.maxHeight : height;
}

- (CGFloat)maxHeight {
    return kScreenHeight;
}

- (UITableView *)tableView {
    return _tableViewController.tableView;
}

- (CGFloat)titleContainerHeight {
    CGFloat titleTextViewHeight = _titleTextView.currentHeight < kTitleTextViewHeight ? kTitleTextViewHeight : _titleTextView.currentHeight;
    return kOffset * 2 + titleTextViewHeight;
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
    
    [NSNotificationCenter attachKeyboardObservers:self keyboardWillShowSelector:@selector(keyboardWillShow:) keyboardWillHideSelector:@selector(keyboardWillHide:)];
    _dataManager = [MRTodoDataManager new];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    _titleContainer = [UIView new];
    _titleContainer.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_titleContainer];
    
    _checkBox = [BEMCheckBox new];
    _checkBox.onTintColor = [SGHelper themeColorRed];
    _checkBox.onFillColor = [SGHelper themeColorRed];
    _checkBox.onCheckColor = [UIColor whiteColor];
    _checkBox.animationDuration = .2;
    _checkBox.onAnimationType = _checkBox.offAnimationType = BEMAnimationTypeFill;
    _checkBox.lineWidth = 1;
    _checkBox.delegate = self;
    [_titleContainer addSubview:_checkBox];
    
    _titleTextView = [SGTextView new];
    _titleTextView.delegate = self;
    _titleTextView.container = _titleContainer;
    _titleTextView.containerInitialHeight = self.titleContainerHeight;
    _titleTextView.maxLength = kMaxLength;
    _titleTextView.maxLineCount = 3;
    _titleTextView.font = [SGHelper themeFontWithSize:17];
    _titleTextView.tintColor = [SGHelper themeColorRed];
    [_titleContainer addSubview:_titleTextView];
    
    _tableViewController = [DetailTableViewController new];
    [self addChildViewController:_tableViewController];
    [self.view addSubview:_tableViewController.view];
}

- (void)bindConstraints {
    [super bindConstraints];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.offset(0);
        make.height.offset(CGFLOAT_MIN);
    }];
    
    [_titleContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.offset(0);
        make.height.offset(self.titleContainerHeight);
        make.bottom.equalTo(self.tableView.mas_top).offset(0);
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
}

#pragma mark - textview

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    return [_titleTextView textView:textView shouldChangeTextInRange:range replacementText:text];
}

- (void)textViewDidChange:(UITextView *)textView {
    [_titleTextView textViewDidChange:textView];
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    _model.title = textView.text;
    [self save];
    
    return YES;
}

#pragma mark - checkbox

- (void)didTapCheckBox:(BEMCheckBox *)checkBox {
    _model.isCompleted = @(checkBox.on);
    _model.completedAt = checkBox.on ? [NSDate date] : nil;
    [self save];
}

#pragma mark - keyboard

- (void)keyboardWillShow:(NSNotification *)notification {
    CGSize keyboardSize = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    [self animateByKeyboard:YES height:keyboardSize.height];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    CGSize keyboardSize = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    [self animateByKeyboard:NO height:keyboardSize.height];
}

- (void)animateByKeyboard:(BOOL)isShow height:(CGFloat)height {
    if (!_titleTextView.isFirstResponder) return;
    
    [_tableViewController.view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.offset(isShow ? -height + self.tableViewHeight - self.overHeight : CGFLOAT_MIN);
    }];
    
    [UIView animateWithDuration:.3 animations:^{[self.view layoutIfNeeded];}];
}

#pragma mark - private methods

- (void)save {
    if (![_dataManager modifyTask:_model]) return;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kTaskChangedNotification object:self];
}
@end
