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
#import "Macros.h"
#import "NSDateFormatter+Extension.h"
#import "SGCommitButton.h"
#import "SGTextField.h"
#import "UIImage+Extension.h"

@implementation CreateViewController {
    SGTextField* titleTextField;
    AutoLinearLayoutView* linearView;
    SGTextField* descriptionTextField;
    SGTextField* datetimePicker;
    SGTextField* locationTextField;
    SGCommitButton* commitButton;

    NSDate* selectedDate;
    // TODO: 人物选择框
}
#pragma mark - localization
- (void)localizeStrings
{
    [self setMenuTitle:NSLocalizedString(@"LABEL_CREATENEW", nil)];
    titleTextField.field.text = NSLocalizedString(@"LABEL_TITLE", nil);
    descriptionTextField.label.text = NSLocalizedString(@"LABEL_DESCRIPTION", nil);
    datetimePicker.label.text = NSLocalizedString(@"LABEL_DATETIME", nil);
    locationTextField.label.text = NSLocalizedString(@"LABEL_LOCATION", nil);
    [commitButton.button setTitle:NSLocalizedString(@"BUTTON_DONE", nil) forState:UIControlStateNormal];
}
#pragma mark - initial
- (void)viewDidLoad
{
    [super viewDidLoad];

    [self localizeStrings];
}
- (void)setupView
{
    [super setupView];

    [self.view setBackgroundColor:[UIColor whiteColor]];

    __weak typeof(self) weakSelf = self;
    headerView = [HeaderView headerViewWithAvatarPosition:HeaderAvatarPositionCenter titleAlignement:HeaderTitleAlignementCenter];
    headerView.backgroundImageView.image = [UIImage imageAtResourcePath:@"create header bg"];
    headerView.avatarButton.hidden = YES;
    headerView.rightOperationButton.hidden = YES;
    [self.view addSubview:headerView];

    titleTextField = [SGTextField textField];
    titleTextField.field.font = [TodoHelper themeFontWithSize:32];
    titleTextField.field.textColor = [UIColor whiteColor];
    titleTextField.isUnderlineHidden = YES;
    [titleTextField setTextFieldShouldReturn:^(SGTextField* textField) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf->descriptionTextField becomeFirstResponder];
    }];
    [headerView addSubview:titleTextField];

    linearView = [[AutoLinearLayoutView alloc] init];
    linearView.axisVertical = YES;
    linearView.spacing = kScreenHeight * 0.03;
    [self.view addSubview:linearView];

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
    [self.view addSubview:commitButton];
}
- (void)bindConstraints
{
    [super bindConstraints];

    [headerView mas_makeConstraints:^(MASConstraintMaker* make) {
        make.top.left.offset(0);
        make.width.offset(kScreenWidth);
        make.height.offset(kScreenHeight * 0.35);
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
    }];

    [@[ descriptionTextField, datetimePicker, locationTextField ] mas_makeConstraints:^(MASConstraintMaker* make) {
        make.left.right.offset(0);
        make.height.offset(kScreenHeight * 0.08);
    }];

    [commitButton mas_makeConstraints:^(MASConstraintMaker* make) {
        make.left.right.equalTo(linearView);
        make.bottom.offset(-15);
        make.height.offset(kScreenHeight * 0.08);
    }];
}
#pragma mark - commit
- (void)commitButtonDidPress
{
    // TODO: 上传数据
}
#pragma mark - show date picker
- (void)datetimePickerDidPress
{
    HSDatePickerViewController* datePickerViewController = [[HSDatePickerViewController alloc] init];
    datePickerViewController.delegate = self;
    // TODO: 判断地区，是中国才设置为这样的格式
    datePickerViewController.dateFormatter = [NSDateFormatter dateFormatterWithFormatString:@"MMM d ccc"];
    datePickerViewController.monthAndYearLabelDateFormater = [NSDateFormatter dateFormatterWithFormatString:@"yyyy MMMM"];

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
