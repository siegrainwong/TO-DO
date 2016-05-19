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
#import "SGTextField.h"
#import "UIImage+Extension.h"

@implementation CreateViewController {
    UITextField* titleTextField;
    AutoLinearLayoutView* linearView;
    SGTextField* descriptionTextField;
    SGTextField* datetimePicker;
    SGTextField* locationTextField;

    NSDate* selectedDate;
    // TODO: 人物选择框
}
#pragma mark - localization
- (void)localizeStrings
{
    [self setMenuTitle:NSLocalizedString(@"LABEL_CREATENEW", nil)];
    titleTextField.text = NSLocalizedString(@"LABEL_TITLE", nil);
    descriptionTextField.title = NSLocalizedString(@"LABEL_DESCRIPTION", nil);
    datetimePicker.title = NSLocalizedString(@"LABEL_DATETIME", nil);
    locationTextField.title = NSLocalizedString(@"LABEL_LOCATION", nil);
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

    headerView = [HeaderView headerViewWithAvatarPosition:HeaderAvatarPositionCenter titleAlignement:HeaderTitleAlignementCenter];
    headerView.backgroundImageView.image = [UIImage imageAtResourcePath:@"create header bg"];
    headerView.avatarButton.hidden = YES;
    headerView.rightOperationButton.hidden = YES;
    [self.view addSubview:headerView];

    titleTextField = [[UITextField alloc] init];
    titleTextField.font = [TodoHelper themeFontWithSize:32];
    titleTextField.textColor = [UIColor whiteColor];
    titleTextField.textAlignment = NSTextAlignmentCenter;
    [headerView addSubview:titleTextField];

    linearView = [[AutoLinearLayoutView alloc] init];
    linearView.axisVertical = YES;
    linearView.spacing = kScreenHeight * 0.03;
    [self.view addSubview:linearView];

    __weak typeof(self) weakSelf = self;
    descriptionTextField = [SGTextField textField];
    descriptionTextField.returnKeyType = UIReturnKeyNext;
    [descriptionTextField setTextFieldShouldReturn:^(SGTextField* textField) {
        [textField resignFirstResponder];
        [weakSelf datetimePickerDidPress];
    }];
    [linearView addSubview:descriptionTextField];

    datetimePicker = [SGTextField textField];
    datetimePicker.returnKeyType = UIReturnKeyNext;
    datetimePicker.enabled = NO;
    datetimePicker.text = nil;
    [datetimePicker addTarget:self action:@selector(datetimePickerDidPress) forControlEvents:UIControlEventTouchUpInside];
    [linearView addSubview:datetimePicker];

    locationTextField = [SGTextField textField];
    locationTextField.returnKeyType = UIReturnKeyDone;
    [locationTextField setTextFieldShouldReturn:^(SGTextField* textField) {
        [weakSelf commitButtonDidPress];
    }];
    [linearView addSubview:locationTextField];
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
        make.bottom.offset(-70);
    }];

    [@[ descriptionTextField, datetimePicker, locationTextField ] mas_makeConstraints:^(MASConstraintMaker* make) {
        make.left.right.offset(0);
        make.height.offset(kScreenHeight * 0.08);
    }];
}
#pragma mark - commit
- (void)commitButtonDidPress
{
}
#pragma mark - show date picker
- (void)datetimePickerDidPress
{
    HSDatePickerViewController* datePickerViewController = [[HSDatePickerViewController alloc] init];
    datePickerViewController.delegate = self;
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
    datetimePicker.text = [DateUtil dateString:date withFormat:@"yyyy.MM.dd HH:mm:ss"];
    [locationTextField becomeFirstResponder];
}
@end
