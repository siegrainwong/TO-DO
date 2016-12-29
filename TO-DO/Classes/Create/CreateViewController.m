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
#import "MRTodoDataManager.h"
#import "NSNotificationCenter+Extension.h"
#import "SGCommitButton.h"
#import "SGTextField.h"
#import "SGBaseMapViewController.h"
#import "SGCoordinate.h"
#import "SGImageUpload.h"
#import "RTRootNavigationController.h"
#import "TZImagePickerController.h"

// TODO: 多人协作（这个坑我都不信我有心情填掉...）

@interface CreateViewController () <UITextFieldDelegate, TZImagePickerControllerDelegate>
@property(nonatomic, strong) MRTodoDataManager *dataManager;
@property(nonatomic, strong) UIView *containerView;
@property(nonatomic, strong) SGTextField *titleTextField;
@property(nonatomic, strong) AutoLinearLayoutView *linearView;
@property(nonatomic, strong) SGTextField *descriptionTextField;
@property(nonatomic, strong) SGTextField *datetimePickerField;
@property(nonatomic, strong) SGTextField *locationTextField;
@property(nonatomic, strong) SGCommitButton *commitButton;
@property(nonatomic, strong) HSDatePickerViewController *datePickerViewController;
@property(nonatomic, assign) BOOL viewIsDisappearing;

@property(nonatomic, strong) NSDate *selectedDate;
@property(nonatomic, assign) CGFloat fieldHeight;
@property(nonatomic, assign) CGFloat fieldSpacing;
@property(nonatomic, strong) UIImage *selectedImage;
@property(nonatomic, strong) SGCoordinate *selectedCoordinate;
@end

@implementation CreateViewController
#pragma mark - localization

- (void)localizeStrings {
    self.titleLabel.text = Localized(@"Create New");
    _descriptionTextField.label.text = Localized(@"Description");
    _datetimePickerField.label.text = Localized(@"Time");
    _locationTextField.label.text = Localized(@"Location");
    [_commitButton.button setTitle:Localized(@"DONE") forState:UIControlStateNormal];
    _titleTextField.field.attributedPlaceholder = [[NSAttributedString alloc] initWithString:Localized(@"Title") attributes:@{NSForegroundColorAttributeName: ColorWithRGB(0xCCCCCC), NSFontAttributeName: _titleTextField.field.font}];
}

#pragma mark - accessors

- (void)setSelectedDate:(NSDate *)selectedDate {
    _selectedDate = selectedDate;
    _datetimePickerField.field.text = [DateUtil dateString:_selectedDate withFormat:@"yyyy.MM.dd HH:mm"];
}

#pragma mark - initial

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self localizeStrings];
    [_titleTextField becomeFirstResponder];
}

- (void)setupViews {
    [super setupViews];
    
    [self.rightNavigationButton setImage:[UIImage new] forState:UIControlStateNormal];
    
    _fieldHeight = kScreenHeight * 0.08f;
    _fieldSpacing = kScreenHeight * 0.03f;
    [NSNotificationCenter attachKeyboardObservers:self keyboardWillShowSelector:@selector(keyboardWillShow:) keyboardWillHideSelector:@selector(keyboardWillHide:)];
    
    _dataManager = [MRTodoDataManager new];
    
    _datePickerViewController = [[HSDatePickerViewController alloc] init];
    [_datePickerViewController configure];
    _datePickerViewController.delegate = self;
    
    __weak typeof(self) weakSelf = self;
    _containerView = [UIView new];
    _containerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_containerView];
    
    self.headerView = [SGHeaderView headerViewWithAvatarPosition:HeaderAvatarPositionCenter titleAlignement:NSTextAlignmentCenter];
    [self.headerView.rightOperationButton setImage:[UIImage imageNamed:@"header_photo"] forState:UIControlStateNormal];
    [self.headerView setImage:[UIImage imageAtResourcePath:@"create header bg"] style:HeaderMaskStyleDark];
    [self.headerView setHeaderViewDidPressRightOperationButton:^{[weakSelf headerViewDidPressRightOperationButton];}];
    self.headerView.avatarButton.hidden = YES;
    [_containerView addSubview:self.headerView];
    
    _titleTextField = [SGTextField textField];
    _titleTextField.field.font = [SGHelper themeFontWithSize:32];
    _titleTextField.field.textColor = _titleTextField.field.tintColor = [UIColor whiteColor];
    _titleTextField.field.returnKeyType = UIReturnKeyNext;
    _titleTextField.isUnderlineHidden = YES;
    [_titleTextField setTextFieldShouldReturn:^(SGTextField *textField) {
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
    if (_selectedDate) _datetimePickerField.field.text = [DateUtil dateString:_selectedDate withFormat:@"yyyy.MM.dd HH:mm"];
    _datetimePickerField.enabled = NO;
    [_datetimePickerField addTarget:self action:@selector(showDatetimePicker) forControlEvents:UIControlEventTouchUpInside];
    [_linearView addSubview:_datetimePickerField];
    
    _descriptionTextField = [SGTextField textField];
    _descriptionTextField.field.returnKeyType = UIReturnKeyNext;
    [_descriptionTextField setTextFieldShouldReturn:^(SGTextField *textField) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf->_locationTextField becomeFirstResponder];
    }];
    [_linearView addSubview:_descriptionTextField];
    
    _locationTextField = [SGTextField textField];
    _locationTextField.field.returnKeyType = UIReturnKeyDone;
    _locationTextField.field.delegate = self;
    [_locationTextField setTextFieldShouldReturn:^(SGTextField *textField) {[weakSelf commitButtonDidPress];}];
    [_linearView addSubview:_locationTextField];
    
    _commitButton = [SGCommitButton commitButton];
    [_commitButton setCommitButtonDidPress:^{[weakSelf commitButtonDidPress];}];
    [_containerView addSubview:_commitButton];
}

- (void)bindConstraints {
    [super bindConstraints];
    
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.offset(0);
    }];
    
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.offset(0);
        make.width.offset(kScreenWidth);
        make.height.offset(kScreenHeight * 0.3);
    }];
    
    [_titleTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.centerY.offset(0);
        make.height.offset(40);
    }];
    
    [_linearView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(20);
        make.right.offset(-20);
        make.top.equalTo(self.headerView.mas_bottom).offset(20);
        make.height.offset((_fieldHeight + _fieldSpacing) * 3);
    }];
    
    [@[_descriptionTextField, _datetimePickerField, _locationTextField] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.offset(0);
        make.height.offset(_fieldHeight);
    }];
    
    [_commitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(_linearView);
        make.height.offset(_fieldHeight);
        make.bottom.offset(-20);
    }];
}

#pragma mark - commit

- (void)commitButtonDidPress {
    __weak typeof(self) weakSelf = self;
    
    [[GCDQueue globalQueueWithLevel:DISPATCH_QUEUE_PRIORITY_DEFAULT] sync:^{
        if (weakSelf.commitButton.indicator.isAnimating) return;
        
        [weakSelf.view endEditing:YES];
        [weakSelf enableView:NO];
        
        CDTodo *todo = [CDTodo newEntityWithInitialData];
        todo.title = weakSelf.titleTextField.field.text;
        todo.sgDescription = weakSelf.descriptionTextField.field.text;
        todo.deadline = self.selectedDate;
        todo.user = weakSelf.cdUser;
        todo.status = [self.selectedDate compare:[NSDate date]] == NSOrderedAscending ? @(TodoStatusOverdue) : @(TodoStatusNormal);
        if (_selectedCoordinate) {
            todo.longitude = @(_selectedCoordinate.longitude);
            todo.latitude = @(_selectedCoordinate.latitude);
            todo.generalAddress = _selectedCoordinate.generalAddress;
            todo.explicitAddress = _selectedCoordinate.explicitAddress;
        }
        if (_selectedImage) {
            NSData *imageData = [SGImageUpload dataWithImage:_selectedImage type:SGImageTypePhoto quality:kSGDefaultImageQuality];
            todo.photoData = imageData;
            todo.photoImage = [UIImage imageWithData:imageData];
        }
        
        [weakSelf enableView:YES];
        if (![weakSelf.dataManager InsertTask:todo]) return;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kTaskChangedNotification object:weakSelf];
        if (weakSelf.createViewControllerDidFinishCreate) weakSelf.createViewControllerDidFinishCreate(todo);
        [weakSelf.navigationController popToRootViewControllerAnimated:YES];
    }];
}

- (void)enableView:(BOOL)isEnable {
    [_commitButton setAnimating:!isEnable];
    self.headerView.userInteractionEnabled = isEnable;
}

#pragma mark - pick picture

- (void)headerViewDidPressRightOperationButton {
    __weak __typeof(self) weakSelf = self;
    [SGHelper photoPickerFrom:self allowCrop:NO currentPhoto:_selectedImage pickerDidPicked:^(UIImage *image) {
        weakSelf.selectedImage = image;
        [weakSelf.headerView.rightOperationButton setImage:weakSelf.selectedImage forState:UIControlStateNormal];
    }];
}

#pragma mark - keyboard events & animation

- (void)keyboardWillShow:(NSNotification *)notification {
    [self animateByKeyboard:YES];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [self animateByKeyboard:NO];
}

- (void)animateByKeyboard:(BOOL)isShowAnimation {
    // Mark: 视图在 Disappear 之后再 Appear 时，会恢复键盘状态，但是这时不会知道是哪个控件的焦点，所以必须再判断一下
    if (_titleTextField.field.isFirstResponder || _viewIsDisappearing) return;
    
    [_containerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.offset(isShowAnimation ? -115 : 0);
    }];
    [_commitButton mas_remakeConstraints:^(MASConstraintMaker *make) {
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _viewIsDisappearing = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    _viewIsDisappearing = YES;
    [self.view endEditing:YES];
}

#pragma mark - datetime picker

- (void)showDatetimePicker {
    if (_selectedDate) _datePickerViewController.date = _selectedDate;
    [self presentViewController:_datePickerViewController animated:YES completion:nil];
}

- (BOOL)hsDatePickerPickedDate:(NSDate *)date {
    self.selectedDate = date;
    return true;
}

#pragma mark - text field

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == _locationTextField.field) {
        SGBaseMapViewController *viewController = [SGBaseMapViewController new];
        viewController.isEditing = YES;
        viewController.coordinate = self.selectedCoordinate;
        __weak __typeof(self) weakSelf = self;
        [viewController setBlock:^(SGCoordinate *coordinate) {
            weakSelf.selectedCoordinate = coordinate;
            weakSelf.locationTextField.field.text = coordinate.explicitAddress;
        }];
        
        RTRootNavigationController *rootNavigationController = [[RTRootNavigationController alloc] initWithRootViewController:viewController];
        rootNavigationController.modalPresentationStyle = UIModalPresentationPopover;
        [self presentViewController:rootNavigationController animated:YES completion:nil];
        
        return NO;
    }
    return YES;
}

- (void)dealloc {
    NSLog(@"%s", __func__);
}
@end
