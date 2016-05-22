//
//  LoginView.m
//  TO-DO
//
//  Created by Siegrain on 16/5/8.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

// FIXME: 该视图内存无法释放，在进入 CreateViewController 后，Masonry 检测到该视图已经不在 window hierachy 中，就崩了..

#import "HeaderView.h"
#import "LCUser.h"
#import "LoginView.h"
#import "Macros.h"
#import "Masonry.h"
#import "NSNotificationCenter+Extension.h"
#import "SGCommitButton.h"
#import "SGTextField.h"
#import "TodoHelper.h"
#import "UIImage+Extension.h"
#import "UIView+Extentsion.h"

@implementation LoginView {
    HeaderView* headerView;
    SGTextField* nameTextField;
    SGTextField* usernameTextField;
    SGTextField* passwordTextField;
    SGCommitButton* commitButton;
    UIButton* leftOperationButton;
    UIButton* rightOperationButton;

    BOOL isSignUp;
    CGFloat textFieldHeight;
    UIImage* avatarImage;
}
#pragma mark - localization
- (void)localizeStrings
{
    headerView.titleLabel.text = NSLocalizedString(@"Sign Up", nil);
    nameTextField.label.text = NSLocalizedString(@"Name", nil);
    passwordTextField.label.text = NSLocalizedString(@"Password", nil);

    [self bindSwitchableDatas];
}
- (void)bindSwitchableDatas
{
    if (isSignUp) {
        usernameTextField.label.text = NSLocalizedString(@"Email", nil);
        [commitButton.button setTitle:NSLocalizedString(@"DONE", nil) forState:UIControlStateNormal];
        [rightOperationButton setTitle:NSLocalizedString(@"SIGN IN", nil) forState:UIControlStateNormal];
        [leftOperationButton setTitle:NSLocalizedString(@"TERMS & CONDITIONS", nil) forState:UIControlStateNormal];
        [headerView.avatarButton setBackgroundImage:avatarImage ? avatarImage : [UIImage imageAtResourcePath:@"mark-signup"] forState:UIControlStateNormal];
        headerView.userInteractionEnabled = YES;
    } else {
        usernameTextField.label.text = NSLocalizedString(@"Username", nil);
        [commitButton.button setTitle:NSLocalizedString(@"SIGN IN", nil) forState:UIControlStateNormal];
        [rightOperationButton setTitle:NSLocalizedString(@"Sign Up", nil) forState:UIControlStateNormal];
        [leftOperationButton setTitle:NSLocalizedString(@"FORGOT PASSWORD?", nil) forState:UIControlStateNormal];
        [headerView.avatarButton setBackgroundImage:[UIImage imageAtResourcePath:@"mark"] forState:UIControlStateNormal];
        headerView.userInteractionEnabled = NO;
    }
}
#pragma mark - initial
+ (instancetype)loginView
{
    LoginView* loginView = [[LoginView alloc] init];
    loginView->isSignUp = false;
    loginView->textFieldHeight = kScreenHeight * 0.08;

    [loginView setup];
    [loginView bindConstraints];
    [loginView localizeStrings];
    [loginView debug];

    [NSNotificationCenter attachKeyboardObservers:loginView keyboardWillShowSelector:@selector(keyboardWillShow:) keyboardWillHideSelector:@selector(keyboardWillHide:)];

    return loginView;
}
- (void)debug
{
    if ([InfoDictionary(@"IsDebugging") boolValue]) {
        usernameTextField.field.text = @"siegrain@qq.com";
        passwordTextField.field.text = @"Weck33";
    }
}
- (void)setup
{
    __weak typeof(self) weakSelf = self;
    headerView = [HeaderView headerViewWithAvatarPosition:HeaderAvatarPositionBottom titleAlignement:HeaderTitleAlignementCenter];
    headerView.rightOperationButton.hidden = YES;
    headerView.titleLabel.layer.opacity = 0;
    [headerView.backgroundImageView setImage:[UIImage imageAtResourcePath:@"login header bg"]];
    [headerView setHeaderViewDidPressAvatarButton:^{
        [weakSelf avatarButtonDidPress];
    }];
    [self addSubview:headerView];

    nameTextField = [SGTextField textField];
    nameTextField.field.returnKeyType = UIReturnKeyNext;
    nameTextField.layer.opacity = 0;
    // Mark: 这个地方必须要用 weakSelf strongSelf 大法，弱持有 block 没用...
    [nameTextField setTextFieldShouldReturn:^(SGTextField* textField) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf->usernameTextField becomeFirstResponder];
    }];
    [self addSubview:nameTextField];

    usernameTextField = [SGTextField textField];
    usernameTextField.field.returnKeyType = UIReturnKeyNext;
    [usernameTextField setTextFieldShouldReturn:^(SGTextField* textField) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf->passwordTextField becomeFirstResponder];
    }];
    [self addSubview:usernameTextField];

    passwordTextField = [SGTextField textField];
    passwordTextField.field.returnKeyType = UIReturnKeyJoin;
    passwordTextField.field.secureTextEntry = YES;
    [passwordTextField setTextFieldShouldReturn:^(SGTextField* textField) {
        [weakSelf commitButtonDidPress];
    }];
    [self addSubview:passwordTextField];

    commitButton = [SGCommitButton commitButton];
    [commitButton setCommitButtonDidPress:^{
        [weakSelf commitButtonDidPress];
    }];
    [self addSubview:commitButton];

    leftOperationButton = [[UIButton alloc] init];
    [leftOperationButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    leftOperationButton.titleLabel.font = [TodoHelper themeFontWithSize:12];
    leftOperationButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self addSubview:leftOperationButton];

    rightOperationButton = [[UIButton alloc] init];
    [rightOperationButton setTitleColor:ColorWithRGB(0xFF3366) forState:UIControlStateNormal];
    rightOperationButton.titleLabel.font = [TodoHelper themeFontWithSize:12];
    rightOperationButton.titleLabel.textAlignment = NSTextAlignmentRight;
    rightOperationButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [rightOperationButton addTarget:self action:@selector(switchModeAnimate) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:rightOperationButton];
}

- (void)bindConstraints
{
    __weak typeof(self) weakSelf = self;
    [headerView mas_makeConstraints:^(MASConstraintMaker* make) {
        make.left.top.right.offset(0);
        make.height.equalTo(weakSelf).multipliedBy(0.4);
    }];

    [nameTextField mas_makeConstraints:^(MASConstraintMaker* make) {
        make.left.offset(25);
        make.right.offset(-25);
        make.centerY.offset(-20);
        make.height.offset(0);
    }];

    [usernameTextField mas_makeConstraints:^(MASConstraintMaker* make) {
        make.left.right.equalTo(nameTextField);
        make.top.equalTo(nameTextField.mas_bottom).offset(0);
        make.height.offset(textFieldHeight);
    }];

    [passwordTextField mas_makeConstraints:^(MASConstraintMaker* make) {
        make.left.right.equalTo(nameTextField);
        make.top.equalTo(usernameTextField.mas_bottom).offset(20);
        make.height.equalTo(usernameTextField);
    }];

    [commitButton mas_makeConstraints:^(MASConstraintMaker* make) {
        make.left.right.equalTo(usernameTextField);
        make.bottom.offset(-55);
        make.height.equalTo(weakSelf).dividedBy(12);
    }];

    [leftOperationButton mas_makeConstraints:^(MASConstraintMaker* make) {
        make.left.equalTo(usernameTextField);
        make.top.equalTo(commitButton.mas_bottom).offset(15);
        make.width.equalTo(commitButton).multipliedBy(0.5);
        make.height.offset(25);
    }];

    [rightOperationButton mas_makeConstraints:^(MASConstraintMaker* make) {
        make.right.equalTo(usernameTextField);
        make.top.equalTo(leftOperationButton);
        make.width.height.equalTo(leftOperationButton);
    }];

    MASAttachKeys(nameTextField, usernameTextField, passwordTextField, commitButton,
                  leftOperationButton, rightOperationButton);
}

#pragma mark - commit & commit animation
- (void)commitButtonDidPress
{
    __weak typeof(self) weakSelf = self;
    // Mark: synchronized lock
    dispatch_queue_t serialQueue = dispatch_queue_create("LoginViewCommitSynchronizedLock", DISPATCH_QUEUE_SERIAL);
    dispatch_sync(serialQueue, ^{
        if (commitButton.indicator.isAnimating)
            return;

        if ([_delegate respondsToSelector:@selector(loginViewDidPressCommitButton:isSignUp:)]) {

            [weakSelf startCommitAnimation];
            [weakSelf endEditing:YES];

            LCUser* user = [LCUser object];
            user.username = usernameTextField.field.text;
            user.name = nameTextField.field.text;
            user.email = user.username;
            user.password = passwordTextField.field.text;
            user.avatarImage = avatarImage;

            [_delegate loginViewDidPressCommitButton:user isSignUp:isSignUp];
        }
    });
}
- (void)startCommitAnimation
{
    [self enableView:NO];
}
- (void)stopCommitAnimation
{
    [self enableView:YES];
}
- (void)enableView:(BOOL)isEnable
{
    headerView.userInteractionEnabled = isEnable;
    leftOperationButton.enabled = isEnable;
    rightOperationButton.enabled = isEnable;
    commitButton.enabled = isEnable;

    if (isEnable)
        [commitButton.indicator stopAnimating];
    else
        [commitButton.indicator startAnimating];
}
#pragma mark - avatar
- (void)avatarButtonDidPress
{
    if ([_delegate respondsToSelector:@selector(loginViewDidPressAvatarButton)])
        [_delegate loginViewDidPressAvatarButton];
}
- (void)setAvatar:(UIImage*)image
{
    avatarImage = image;
    [headerView.avatarButton setBackgroundImage:image forState:UIControlStateNormal];
}
#pragma mark - switch to sign in/ sign up mode with animation
- (void)switchModeAnimate
{
    isSignUp = !isSignUp;

    [self bindSwitchableDatas];

    __weak typeof(self) weakSelf = self;
    [nameTextField mas_updateConstraints:^(MASConstraintMaker* make) {
        __typeof__(self) __strong strongSelf = weakSelf;
        make.height.offset(isSignUp ? strongSelf->textFieldHeight : 0);
    }];
    [usernameTextField mas_updateConstraints:^(MASConstraintMaker* make) {
        make.top.equalTo(nameTextField.mas_bottom).offset(isSignUp ? 20 : 0);
    }];
    [UIView animateWithDuration:0.3
                     animations:^{
                         headerView.titleLabel.layer.opacity = isSignUp;
                         nameTextField.layer.opacity = isSignUp;
                         [weakSelf layoutIfNeeded];
                     }];
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
    __weak typeof(self) weakSelf = self;
    [self mas_updateConstraints:^(MASConstraintMaker* make) {
        make.top.bottom.offset(isShowAnimation ? -kPopHeightWhenKeyboardShow : 0);
    }];
    [commitButton mas_remakeConstraints:^(MASConstraintMaker* make) {
        make.left.right.equalTo(usernameTextField);
        make.height.equalTo(weakSelf).dividedBy(12);
        if (isShowAnimation)
            make.top.equalTo(passwordTextField.mas_bottom).offset(20);
        else
            make.bottom.offset(-55);
    }];

    [UIView animateWithDuration:1 animations:^{ [weakSelf.superview layoutIfNeeded]; }];
}

#pragma mark - dealloc
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"%s", __func__);
}

@end