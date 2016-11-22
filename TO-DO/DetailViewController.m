//
// Created by Siegrain on 16/11/21.
// Copyright (c) 2016 com.siegrain. All rights reserved.
//

#import "DetailViewController.h"
#import "AutoLinearLayoutView.h"
#import "SGTextField.h"
#import "SSDynamicTextView.h"
#import "BEMCheckBox.h"
#import "CDTodo.h"

static CGFloat const kCheckBoxHeight = 40;
static CGFloat const kTitleHeight = 40;
static CGFloat const kOffset = 10;

@interface DetailViewController () <UITextViewDelegate>
@property(nonatomic, strong) CDTodo *model;

@property(nonatomic, strong) UIView *container;
@property(nonatomic, strong) UIView *titleContainer;

@property(nonatomic, strong) BEMCheckBox *checkBox;
@property(nonatomic, strong) UITextView *titleTextView;
@property(nonatomic, strong) UIImageView *photoImageView;
@end

@implementation DetailViewController

#pragma mark - release

- (void)dealloc {
    DDLogWarn(@"%s", __func__);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - accessors

- (void)setModel:(CDTodo *)model {
    _model = model;
    
    _titleTextView.text = model.title;
    _checkBox.on = model.isCompleted.boolValue;
}

- (CGFloat)height {
    return self.titleContainerHeight;
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
    
    _titleTextView = [UITextView new];
    _titleTextView.font = [SGHelper themeFontWithSize:17];
    _titleTextView.delegate = self;
    _titleTextView.contentInset = UIEdgeInsetsZero;
    _titleTextView.tintColor = [SGHelper themeColorRed];
    _titleTextView.scrollEnabled = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
    [_titleContainer addSubview:_titleTextView];
}

- (void)bindConstraints {
    [super bindConstraints];
    
    [_container mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.offset(0);
        make.height.equalTo(_titleContainer);
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
        make.left.equalTo(_checkBox.mas_right).offset(kOffset);
        make.top.equalTo(_checkBox);
        make.right.bottom.offset(-kOffset);
    }];
}

#pragma mark - textview

/*根据textView的行数调整视图高度*/
- (void)textViewDidChange:(UITextView *)textView {
    CGSize textSize = [textView sizeThatFits:CGSizeMake(textView.width, CGFLOAT_MAX)];
    CGFloat lineHeight = textView.font.lineHeight;
    NSInteger lineCount = (NSInteger) (textSize.height / lineHeight);
    if (lineCount > 3) return;
    
    CGFloat increase = (lineCount - 1) * lineHeight;
    [self.titleContainer mas_updateConstraints:^(MASConstraintMaker *make) {make.height.offset(self.titleContainerHeight + increase);}];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [self.view endEditing:YES];
        return NO;
    }
    return YES;
}

/*在复制文字进文本框时触发该通知*/
- (void)textChanged:(NSNotification *)notification {
    [self textViewDidChange:_titleTextView];
}
@end