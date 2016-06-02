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
#import "HSDatePickerViewController+Configure.h"
#import "LCTodo.h"
#import "MRTodoDataManager.h"
#import "Macros.h"
#import "NSDate+Extension.h"
#import "NSDateFormatter+Extension.h"
#import "NSNotificationCenter+Extension.h"
#import "SCLAlertHelper.h"
#import "SGCommitButton.h"
#import "SGTextField.h"
#import "UIImage+Extension.h"
#import "UIViewController+KNSemiModal.h"

// FIXME: iPhone4s 上 NavigationBar 会遮挡一部分标题文本框
// TODO: 人物选择功能

@interface
CreateViewController ()
@property (nonatomic, readwrite, strong) MRTodoDataManager* dataManager;
@property (nonatomic, readwrite, strong) UIView* containerView;
@property (nonatomic, readwrite, strong) SGTextField* titleTextField;
@property (nonatomic, readwrite, strong) AutoLinearLayoutView* linearView;
@property (nonatomic, readwrite, strong) SGTextField* descriptionTextField;
@property (nonatomic, readwrite, strong) SGTextField* datetimePickerField;
@property (nonatomic, readwrite, strong) SGTextField* locationTextField;
@property (nonatomic, readwrite, strong) SGCommitButton* commitButton;
@property (nonatomic, readwrite, strong) HSDatePickerViewController* datePickerViewController;

@property (nonatomic, readwrite, strong) NSDate* selectedDate;
@property (nonatomic, readwrite, assign) CGFloat fieldHeight;
@property (nonatomic, readwrite, assign) CGFloat fieldSpacing;
@property (nonatomic, readwrite, strong) UIImage* selectedImage;
@property (nonatomic, readwrite, assign) BOOL viewIsDisappearing;
@end

@implementation CreateViewController
#pragma mark - localization
- (void)localizeStrings
{
    [self setMenuTitle:NSLocalizedString(@"Create New", nil)];
    _descriptionTextField.label.text = NSLocalizedString(@"Description", nil);
    _datetimePickerField.label.text = NSLocalizedString(@"Time", nil);
    _locationTextField.label.text = NSLocalizedString(@"Location", nil);
    [_commitButton.button setTitle:NSLocalizedString(@"DONE", nil) forState:UIControlStateNormal];
    _titleTextField.field.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Title", nil) attributes:@{ NSForegroundColorAttributeName : ColorWithRGB(0xCCCCCC), NSFontAttributeName : _titleTextField.field.font }];
}
#pragma mark - initial
- (void)viewDidLoad
{
    [super viewDidLoad];

    [self localizeStrings];
    [_titleTextField becomeFirstResponder];
}
- (void)setupView
{
    [super setupView];

    _fieldHeight = kScreenHeight * 0.08;
    _fieldSpacing = kScreenHeight * 0.03;
    [NSNotificationCenter attachKeyboardObservers:self keyboardWillShowSelector:@selector(keyboardWillShow:) keyboardWillHideSelector:@selector(keyboardWillHide:)];

    _dataManager = [MRTodoDataManager new];

    _datePickerViewController = [[HSDatePickerViewController alloc] init];
    [_datePickerViewController configure];
    _datePickerViewController.delegate = self;

    __weak typeof(self) weakSelf = self;
    // Mark: 需要这个的原因是 self.view 在视图加载时还不在窗口层级中，无法为其绑定约束
    _containerView = [UIView new];
    _containerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_containerView];

    self.headerView = [HeaderView headerViewWithAvatarPosition:HeaderAvatarPositionCenter titleAlignement:HeaderTitleAlignementCenter];
    self.headerView.backgroundImageView.image = [UIImage imageAtResourcePath:@"create header bg"];
    [self.headerView.rightOperationButton setImage:[UIImage imageNamed:@"photo"] forState:UIControlStateNormal];
    [self.headerView setHeaderViewDidPressRightOperationButton:^{ [weakSelf headerViewDidPressRightOperationButton]; }];
    self.headerView.avatarButton.hidden = YES;
    [_containerView addSubview:self.headerView];

    _titleTextField = [SGTextField textField];
    _titleTextField.field.font = [TodoHelper themeFontWithSize:32];
    _titleTextField.field.textColor = [UIColor whiteColor];
    _titleTextField.field.returnKeyType = UIReturnKeyNext;
    _titleTextField.isUnderlineHidden = YES;
    [_titleTextField setTextFieldShouldReturn:^(SGTextField* textField) {
        [textField resignFirstResponder];
        [weakSelf showDatetimePicker];
    }];
    [self.headerView addSubview:_titleTextField];

    _linearView = [[AutoLinearLayoutView alloc] init];
    _linearView.axisVertical = YES;
    _linearView.spacing = _fieldSpacing;
    [_containerView addSubview:_linearView];

    _datetimePickerField = [SGTextField textField];
    _datetimePickerField.field.returnKeyType = UIReturnKeyNext;
    _datetimePickerField.enabled = NO;
    [_datetimePickerField addTarget:self action:@selector(showDatetimePicker) forControlEvents:UIControlEventTouchUpInside];
    [_linearView addSubview:_datetimePickerField];

    _descriptionTextField = [SGTextField textField];
    _descriptionTextField.field.returnKeyType = UIReturnKeyNext;
    [_descriptionTextField setTextFieldShouldReturn:^(SGTextField* textField) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf->_locationTextField becomeFirstResponder];
    }];
    [_linearView addSubview:_descriptionTextField];

    _locationTextField = [SGTextField textField];
    _locationTextField.field.returnKeyType = UIReturnKeyDone;
    [_locationTextField setTextFieldShouldReturn:^(SGTextField* textField) {
        [weakSelf commitButtonDidPress];
    }];
    [_linearView addSubview:_locationTextField];

    _commitButton = [SGCommitButton commitButton];
    [_commitButton setCommitButtonDidPress:^{
        [weakSelf commitButtonDidPress];
    }];
    [_containerView addSubview:_commitButton];
}
- (void)bindConstraints
{
    [super bindConstraints];

    [_containerView mas_makeConstraints:^(MASConstraintMaker* make) {
        make.left.top.right.bottom.offset(0);
    }];

    [self.headerView mas_makeConstraints:^(MASConstraintMaker* make) {
        make.top.left.offset(0);
        make.width.offset(kScreenWidth);
        make.height.offset(kScreenHeight * 0.3);
    }];

    [_titleTextField mas_makeConstraints:^(MASConstraintMaker* make) {
        make.left.right.offset(0);
        make.centerY.offset(-10);
        make.height.offset(40);
    }];

    [_linearView mas_makeConstraints:^(MASConstraintMaker* make) {
        make.left.offset(20);
        make.right.offset(-20);
        make.top.equalTo(self.headerView.mas_bottom).offset(20);
        make.height.offset((_fieldHeight + _fieldSpacing) * 3);
    }];

    [@[ _descriptionTextField, _datetimePickerField, _locationTextField ] mas_makeConstraints:^(MASConstraintMaker* make) {
        make.left.right.offset(0);
        make.height.offset(_fieldHeight);
    }];

    [_commitButton mas_makeConstraints:^(MASConstraintMaker* make) {
        make.left.right.equalTo(_linearView);
        make.height.offset(_fieldHeight);
        make.bottom.offset(-20);
    }];
}
#pragma mark - commit
- (void)commitButtonDidPress
{
    __weak typeof(self) weakSelf = self;
    dispatch_queue_t serialQueue = dispatch_queue_create("TO-DOCreateSerialQueue", DISPATCH_QUEUE_SERIAL);
    dispatch_sync(serialQueue, ^{
        if (_commitButton.indicator.isAnimating) return;

        [weakSelf.view endEditing:YES];
        [weakSelf enableView:NO];

        CDTodo* todo = [CDTodo MR_createEntity];
        todo.title = _titleTextField.field.text;
        todo.sgDescription = _descriptionTextField.field.text;
        todo.deadline = _selectedDate;
        todo.location = _locationTextField.field.text;
        todo.photoData = UIImageJPEGRepresentation(_selectedImage, 0.5);
        todo.photoImage = [UIImage imageWithData:todo.photoData];
        todo.user = self.cdUser;
        todo.status = @(TodoStatusNormal);
        todo.isCompleted = @(NO);
        todo.isHidden = @(NO);
        todo.createAt = [NSDate date];

        [_dataManager insertTodo:todo complete:^(bool succeed) {
            [weakSelf enableView:YES];
            if (!succeed) return;
            if (_createViewControllerDidFinishCreate) _createViewControllerDidFinishCreate(todo);
            [weakSelf.navigationController popToRootViewControllerAnimated:YES];
        }];

        // LeanCloud's
        //        [_dataManager insertTodo:todo complete:^(bool succeed) {
        //            [weakSelf enableView:YES];
        //            if (!succeed) return;
        //            if (_createViewControllerDidFinishCreate) _createViewControllerDidFinishCreate(todo);
        //            [weakSelf.navigationController popToRootViewControllerAnimated:YES];
        //        }];
    });
}
- (void)enableView:(BOOL)isEnable
{
    [_commitButton setAnimating:!isEnable];
    self.headerView.userInteractionEnabled = isEnable;
}
#pragma mark - pick picture
- (void)headerViewDidPressRightOperationButton
{
    __weak typeof(self) weakSelf = self;
    [TodoHelper pictureActionSheetFrom:self
      selectCameraHandler:^{ [weakSelf actionSheetItemDidSelect:UIImagePickerControllerSourceTypeCamera]; }
      selectAlbumHandler:^{ [weakSelf actionSheetItemDidSelect:UIImagePickerControllerSourceTypePhotoLibrary]; }];
}
- (void)actionSheetItemDidSelect:(UIImagePickerControllerSourceType)type
{
    BOOL error = false;
    [TodoHelper pickPictureFromSource:type target:self error:&error];
    super.releaseWhileDisappear = error;
}
#pragma mark - imagePicker delegate
- (void)imagePickerController:(UIImagePickerController*)picker
didFinishPickingMediaWithInfo:(NSDictionary<NSString*, id>*)info
{
    _selectedImage = info[UIImagePickerControllerEditedImage];
    [self.headerView.rightOperationButton setImage:_selectedImage forState:UIControlStateNormal];
    [picker dismissViewControllerAnimated:true completion:nil];
    super.releaseWhileDisappear = true;
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController*)picker
{
    [picker dismissViewControllerAnimated:true completion:nil];
    super.releaseWhileDisappear = true;
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
    // Mark: 视图在 Disappear 之后再 Appear 时，会恢复键盘状态，但是这时不会知道是哪个控件的焦点，所以必须再判断一下
    if (_titleTextField.field.isFirstResponder || _viewIsDisappearing) return;

    [_containerView mas_updateConstraints:^(MASConstraintMaker* make) {
        make.top.bottom.offset(isShowAnimation ? -115 : 0);
    }];
    [_commitButton mas_remakeConstraints:^(MASConstraintMaker* make) {
        make.left.right.equalTo(_linearView);
        make.height.offset(_fieldHeight);
        if (isShowAnimation)
            make.top.equalTo(_locationTextField.mas_bottom).offset(20);
        else
            make.bottom.offset(-20);
    }];

    [UIView animateWithDuration:1 animations:^{
        [_containerView.superview layoutIfNeeded];
        [self.navigationController.navigationBar setHidden:isShowAnimation];
    }];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    _viewIsDisappearing = YES;
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    _viewIsDisappearing = YES;
    [self.view endEditing:YES];
}
#pragma mark - datetime picker
- (void)showDatetimePicker
{
    if (_selectedDate) _datePickerViewController.date = _selectedDate;
    [self presentViewController:_datePickerViewController animated:YES completion:nil];
}
- (BOOL)hsDatePickerPickedDate:(NSDate*)date
{
    if ([date timeIntervalSince1970] < [_datePickerViewController.minDate timeIntervalSince1970])
        date = [NSDate date];

    _selectedDate = date;
    _datetimePickerField.field.text = [DateUtil dateString:date withFormat:@"yyyy.MM.dd HH:mm"];

    return true;
}
#pragma mark - release
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    if (!super.releaseWhileDisappear) return;

    if (_createViewControllerDidDisappear) _createViewControllerDidDisappear();

    [self.view removeFromSuperview];
    self.view = nil;

    [self removeFromParentViewController];
}
- (void)dealloc
{
    NSLog(@"%s", __func__);
}
@end
