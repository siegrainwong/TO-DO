//
//  CreateViewController.m
//  TO-DO
//
//  Created by Siegrain on 16/5/19.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "AutoLinearLayoutView.h"
#import "CreateViewController.h"
#import "DateUtil.h"
#import "LCTodo.h"
#import "Macros.h"
#import "NSDateFormatter+Extension.h"
#import "NSNotificationCenter+Extension.h"
#import "SGCommitButton.h"
#import "SGTextField.h"
#import "UIImage+Extension.h"

@implementation CreateViewController {
    UIView* containerView;
    SGTextField* titleTextField;
    AutoLinearLayoutView* linearView;
    SGTextField* descriptionTextField;
    SGTextField* datetimePicker;
    SGTextField* locationTextField;
    SGCommitButton* commitButton;

    NSDate* selectedDate;
    CGFloat fieldHeight;
    CGFloat fieldSpacing;
    __block MASConstraintMaker* commitButtonCommonConstraints;
    // TODO: 人物选择功能
}
#pragma mark - localization
- (void)localizeStrings
{
    [self setMenuTitle:NSLocalizedString(@"Create New", nil)];
    titleTextField.field.text = NSLocalizedString(@"Title", nil);
    descriptionTextField.label.text = NSLocalizedString(@"Description", nil);
    datetimePicker.label.text = NSLocalizedString(@"Time", nil);
    locationTextField.label.text = NSLocalizedString(@"Location", nil);
    [commitButton.button setTitle:NSLocalizedString(@"DONE", nil) forState:UIControlStateNormal];
}
#pragma mark - initial
- (void)viewDidLoad
{
    [super viewDidLoad];

    [self localizeStrings];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [titleTextField becomeFirstResponder];
}
- (void)setupView
{
    [super setupView];

    [NSNotificationCenter attachKeyboardObservers:self keyboardWillShowSelector:@selector(keyboardWillShow:) keyboardWillHideSelector:@selector(keyboardWillHide:)];
    fieldHeight = kScreenHeight * 0.08;
    fieldSpacing = kScreenHeight * 0.03;

    __weak typeof(self) weakSelf = self;
    // Mark: 需要这个的原因是 self.view 在视图加载时还不在窗口层级中，无法为其绑定约束
    containerView = [UIView new];
    containerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:containerView];

    headerView = [HeaderView headerViewWithAvatarPosition:HeaderAvatarPositionCenter titleAlignement:HeaderTitleAlignementCenter];
    headerView.backgroundImageView.image = [UIImage imageAtResourcePath:@"create header bg"];
    [headerView.rightOperationButton setImage:[UIImage imageNamed:@"photo"] forState:UIControlStateNormal];
    headerView.avatarButton.hidden = YES;
    [containerView addSubview:headerView];

    titleTextField = [SGTextField textField];
    titleTextField.field.font = [TodoHelper themeFontWithSize:32];
    titleTextField.field.textColor = [UIColor whiteColor];
    titleTextField.field.returnKeyType = UIReturnKeyNext;
    titleTextField.isUnderlineHidden = YES;
    [titleTextField setTextFieldShouldReturn:^(SGTextField* textField) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf->descriptionTextField becomeFirstResponder];
    }];
    [headerView addSubview:titleTextField];

    linearView = [[AutoLinearLayoutView alloc] init];
    linearView.axisVertical = YES;
    linearView.spacing = fieldSpacing;
    [containerView addSubview:linearView];

    descriptionTextField = [SGTextField textField];
    descriptionTextField.field.returnKeyType = UIReturnKeyNext;
    [descriptionTextField setTextFieldShouldReturn:^(SGTextField* textField) {
        [textField resignFirstResponder];
        [weakSelf datetimePickerDidPress];
    }];
    [linearView addSubview:descriptionTextField];

    datetimePicker = [SGTextField textField];
    datetimePicker.field.returnKeyType = UIReturnKeyNext;
    datetimePicker.enabled = NO;
    datetimePicker.field.text = nil;
    [datetimePicker addTarget:self action:@selector(datetimePickerDidPress) forControlEvents:UIControlEventTouchUpInside];
    [linearView addSubview:datetimePicker];

    locationTextField = [SGTextField textField];
    locationTextField.field.returnKeyType = UIReturnKeyDone;
    [locationTextField setTextFieldShouldReturn:^(SGTextField* textField) {
        [weakSelf commitButtonDidPress];
    }];
    [linearView addSubview:locationTextField];

    commitButton = [SGCommitButton commitButton];
    [containerView addSubview:commitButton];
}
- (void)bindConstraints
{
    [super bindConstraints];

    [containerView mas_makeConstraints:^(MASConstraintMaker* make) {
        make.left.top.right.bottom.offset(0);
    }];

    [headerView mas_makeConstraints:^(MASConstraintMaker* make) {
        make.top.left.offset(0);
        make.width.offset(kScreenWidth);
        make.height.offset(kScreenHeight * 0.3);
    }];

    [titleTextField mas_makeConstraints:^(MASConstraintMaker* make) {
        make.left.right.offset(0);
        make.centerY.offset(-10);
        make.height.offset(40);
    }];

    [linearView mas_makeConstraints:^(MASConstraintMaker* make) {
        make.left.offset(20);
        make.right.offset(-20);
        make.top.equalTo(headerView.mas_bottom).offset(20);
        make.height.offset((fieldHeight + fieldSpacing) * 3);
    }];
    [@[ descriptionTextField, datetimePicker, locationTextField ] mas_makeConstraints:^(MASConstraintMaker* make) {
        make.left.right.offset(0);
        make.height.offset(fieldHeight);
    }];

    [commitButton mas_makeConstraints:^(MASConstraintMaker* make) {
        make.left.right.equalTo(linearView);
        make.height.offset(fieldHeight);
        make.bottom.offset(-20);
    }];
}
#pragma mark - commit
- (void)commitButtonDidPress
{
    dispatch_queue_t serialQueue = dispatch_queue_create("TO-DOCreateSerialQueue", DISPATCH_QUEUE_SERIAL);
    dispatch_sync(
      serialQueue, ^{
          [self.view endEditing:YES];

          LCTodo* todo = [LCTodo new];
          todo.title = titleTextField.field.text;
          todo.sgDescription = descriptionTextField.field.text;
          todo.deadline = [DateUtil stringToDate:datetimePicker.field.text format:@"yyyy.MM.dd HH:mm:ss"];
          todo.location = locationTextField.field.text;
          todo.user = user;
          // TODO: 数据同步...
      });
}
#pragma mark - keyboard events & animation
- (void)keyboardWillShow:(NSNotification*)notification
{
    [self animateByKeyboard:YES];
}
- (void)keyboardWillHide:(NSNotification*)notification
{
    [self animateByKeyboard:NO];
}
- (void)animateByKeyboard:(BOOL)isShowAnimation
{
    if (titleTextField.field.isFirstResponder) return;

    [containerView mas_updateConstraints:^(MASConstraintMaker* make) {
        make.top.bottom.offset(isShowAnimation ? -115 : 0);
    }];
    [commitButton mas_remakeConstraints:^(MASConstraintMaker* make) {
        make.left.right.equalTo(linearView);
        make.height.offset(fieldHeight);
        if (isShowAnimation)
            make.top.equalTo(locationTextField.mas_bottom).offset(20);
        else
            make.bottom.offset(-20);
    }];

    [UIView animateWithDuration:1
                     animations:^{
                         [containerView.superview layoutIfNeeded];
                         [self.navigationController.navigationBar setHidden:isShowAnimation];
                     }];
}
#pragma mark - show date picker
- (void)datetimePickerDidPress
{
    HSDatePickerViewController* datePickerViewController = [[HSDatePickerViewController alloc] init];
    datePickerViewController.delegate = self;

    NSString* chinese = [SystemLanguege substringWithRange:NSMakeRange(0, 6)];
    // zh-Hans or zh-Hant
    if ([chinese isEqualToString:@"zh-Han"]) {
        datePickerViewController.dateFormatter = [NSDateFormatter dateFormatterWithFormatString:@"MMM d ccc"];
        datePickerViewController.monthAndYearLabelDateFormater = [NSDateFormatter dateFormatterWithFormatString:@"yyyy MMMM"];
    }

    if (selectedDate) {
        datePickerViewController.date = selectedDate;
    }
    datePickerViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:datePickerViewController animated:YES completion:nil];
}
#pragma mark - date picker delegate
- (void)hsDatePickerPickedDate:(NSDate*)date
{
    selectedDate = date;
    datetimePicker.field.text = [DateUtil dateString:date withFormat:@"yyyy.MM.dd HH:mm:ss"];
    [locationTextField becomeFirstResponder];
}
@end
