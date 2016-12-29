//
//  LoginView.m
//  TO-DO
//
//  Created by Siegrain on 16/5/8.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "SGHeaderView.h"
#import "LCUser.h"
#import "LoginView.h"
#import "Macros.h"
#import "Masonry.h"
#import "NSNotificationCenter+Extension.h"
#import "SGCommitButton.h"
#import "SGTextField.h"
#import "SGHelper.h"
#import "UIImage+Extension.h"
#import "UIView+Extentsion.h"
#import "SGWebViewController.h"
#import "RTRootNavigationController.h"
#import "SCLAlertView.h"

// Mark: 当时经验不足，把controller的很多东西放在view里面去了。

@interface
LoginView ()
@property(nonatomic, strong) SGHeaderView *headerView;
@property(nonatomic, strong) SGTextField *nameTextField;
@property(nonatomic, strong) SGTextField *usernameTextField;
@property(nonatomic, strong) SGTextField *passwordTextField;
@property(nonatomic, strong) SGCommitButton *commitButton;
@property(nonatomic, strong) UIButton *leftOperationButton;
@property(nonatomic, strong) UIButton *rightOperationButton;

@property(nonatomic, assign) BOOL isSignUp;
@property(nonatomic, assign) CGFloat textFieldHeight;
@end

@implementation LoginView
#pragma mark - localization

- (void)localizeStrings {
    _headerView.titleLabel.text = NSLocalizedString(@"Sign Up", nil);
    _nameTextField.label.text = NSLocalizedString(@"Name", nil);
    _passwordTextField.label.text = NSLocalizedString(@"Password", nil);
    
    [self bindSwitchableData];
}

- (void)bindSwitchableData {
    if (_isSignUp) {
        _usernameTextField.label.text = NSLocalizedString(@"Email", nil);
        [_commitButton.button setTitle:NSLocalizedString(@"DONE", nil) forState:UIControlStateNormal];
        [_rightOperationButton setTitle:NSLocalizedString(@"SIGN IN", nil) forState:UIControlStateNormal];
        [_leftOperationButton setTitle:NSLocalizedString(@"TERMS & CONDITIONS", nil) forState:UIControlStateNormal];
        [_headerView.avatarButton setBackgroundImage:_avatar ? _avatar : [UIImage imageAtResourcePath:@"mark-signup"] forState:UIControlStateNormal];
        _headerView.userInteractionEnabled = YES;
    } else {
        _usernameTextField.label.text = NSLocalizedString(@"Username", nil);
        [_commitButton.button setTitle:NSLocalizedString(@"SIGN IN", nil) forState:UIControlStateNormal];
        [_rightOperationButton setTitle:NSLocalizedString(@"Sign Up", nil) forState:UIControlStateNormal];
        [_leftOperationButton setTitle:NSLocalizedString(@"FORGOT PASSWORD?", nil) forState:UIControlStateNormal];
        [_headerView.avatarButton setBackgroundImage:[UIImage imageAtResourcePath:@"mark"] forState:UIControlStateNormal];
        _headerView.userInteractionEnabled = NO;
    }
}

#pragma mark - initial

+ (instancetype)loginView {
    LoginView *loginView = [[LoginView alloc] init];
    loginView.isSignUp = false;
    loginView.textFieldHeight = kScreenHeight * 0.08;
    loginView.backgroundColor = [UIColor whiteColor];
    
    [loginView setup];
    [loginView bindConstraints];
    [loginView localizeStrings];
    [loginView debug];
    
    [NSNotificationCenter attachKeyboardObservers:loginView keyboardWillShowSelector:@selector(keyboardWillShow:) keyboardWillHideSelector:@selector(keyboardWillHide:)];
    
    return loginView;
}

- (void)debug {
    _usernameTextField.field.text = @"siegrain@gmail.com";
}

- (void)setup {
    __weak typeof(self) weakSelf = self;
    _headerView = [SGHeaderView headerViewWithAvatarPosition:HeaderAvatarPositionBottom titleAlignement:NSTextAlignmentCenter];
    _headerView.rightOperationButton.hidden = YES;
    _headerView.titleLabel.layer.opacity = 0;
    [_headerView setImage:[UIImage imageAtResourcePath:@"login header bg"] style:HeaderMaskStyleDark];
    [_headerView setHeaderViewDidPressAvatarButton:^{
        [weakSelf avatarButtonDidPress];
    }];
    [self addSubview:_headerView];
    
    _nameTextField = [SGTextField textField];
    _nameTextField.field.returnKeyType = UIReturnKeyNext;
    _nameTextField.layer.opacity = 0;
    [_nameTextField setTextFieldShouldReturn:^(SGTextField *textField) {
        [weakSelf.usernameTextField becomeFirstResponder];
    }];
    [self addSubview:_nameTextField];
    
    _usernameTextField = [SGTextField textField];
    _usernameTextField.field.returnKeyType = UIReturnKeyNext;
    [_usernameTextField setTextFieldShouldReturn:^(SGTextField *textField) {
        [weakSelf.passwordTextField becomeFirstResponder];
    }];
    [self addSubview:_usernameTextField];
    
    _passwordTextField = [SGTextField textField];
    _passwordTextField.field.returnKeyType = UIReturnKeyJoin;
    _passwordTextField.field.secureTextEntry = YES;
    [_passwordTextField setTextFieldShouldReturn:^(SGTextField *textField) {
        [weakSelf commitButtonDidPress];
    }];
    [self addSubview:_passwordTextField];
    
    _commitButton = [SGCommitButton commitButton];
    [_commitButton setCommitButtonDidPress:^{
        [weakSelf commitButtonDidPress];
    }];
    [self addSubview:_commitButton];
    
    _leftOperationButton = [[UIButton alloc] init];
    [_leftOperationButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    _leftOperationButton.titleLabel.font = [SGHelper themeFontWithSize:12];
    _leftOperationButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_leftOperationButton addTarget:self action:@selector(leftButtonDidPress) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_leftOperationButton];
    
    _rightOperationButton = [[UIButton alloc] init];
    [_rightOperationButton setTitleColor:ColorWithRGB(0xFF3366) forState:UIControlStateNormal];
    _rightOperationButton.titleLabel.font = [SGHelper themeFontWithSize:12];
    _rightOperationButton.titleLabel.textAlignment = NSTextAlignmentRight;
    _rightOperationButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [_rightOperationButton addTarget:self action:@selector(switchModeAnimate) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_rightOperationButton];
}

- (void)bindConstraints {
    __weak typeof(self) weakSelf = self;
    [_headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.offset(0);
        make.height.equalTo(weakSelf).multipliedBy(0.4);
    }];
    
    [_nameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(25);
        make.right.offset(-25);
        make.centerY.offset(-20);
        make.height.offset(0);
    }];
    
    [_usernameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(_nameTextField);
        make.top.equalTo(_nameTextField.mas_bottom).offset(0);
        make.height.offset(_textFieldHeight);
    }];
    
    [_passwordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(_nameTextField);
        make.top.equalTo(_usernameTextField.mas_bottom).offset(20);
        make.height.equalTo(_usernameTextField);
    }];
    
    [_commitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(_usernameTextField);
        make.bottom.offset(-55);
        make.height.equalTo(weakSelf).dividedBy(12);
    }];
    
    [_leftOperationButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_usernameTextField);
        make.top.equalTo(_commitButton.mas_bottom).offset(15);
        make.width.equalTo(_commitButton).multipliedBy(0.5);
        make.height.offset(25);
    }];
    
    [_rightOperationButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_usernameTextField);
        make.top.equalTo(_leftOperationButton);
        make.width.height.equalTo(_leftOperationButton);
    }];
    
    MASAttachKeys(_nameTextField, _usernameTextField, _passwordTextField, _commitButton, _leftOperationButton, _rightOperationButton);
}

#pragma mark - events

- (void)leftButtonDidPress {
    if (_isSignUp) {    //Terms & Conditions
        SGWebViewController *viewController = [[SGWebViewController alloc] initWithURL:[NSURL URLWithString:kPrivacyPolicyUrl]];
        viewController.showCloseButton = YES;
        RTRootNavigationController *navigationController = [[RTRootNavigationController alloc] initWithRootViewController:viewController];
        [self.currentTopViewController presentViewController:navigationController animated:YES completion:nil];
    } else {    //Forgot password
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        UITextField *textField = [alert addTextField:@"Email"];
        
        [alert addButton:@"OK" actionBlock:^(void) {
            NSError *error = nil;
            [LCUser requestPasswordResetForEmail:textField.text error:&error];
            if (error) {
                [SGHelper errorAlertWithMessage:error.localizedDescription];
                return;
            }
        }];
        
        [alert showEdit:self.currentTopViewController title:Localized(@"Forgot Password?") subTitle:@"Please enter your registration email, we'll send you a link to reset your password." closeButtonTitle:Localized(@"Cancel") duration:0.0f];
    }
}

#pragma mark - commit & commit animation

- (void)commitButtonDidPress {
    __weak typeof(self) weakSelf = self;
    dispatch_queue_t serialQueue = dispatch_queue_create("LoginViewCommitSynchronizedLock", DISPATCH_QUEUE_SERIAL);
    dispatch_sync(serialQueue, ^{
        if (_commitButton.indicator.isAnimating)
            return;
        
        if ([_delegate respondsToSelector:@selector(loginViewDidPressCommitButton:isSignUp:)]) {
            
            [weakSelf startCommitAnimation];
            [weakSelf endEditing:YES];
            
            LCUser *user = [LCUser object];
            user.username = _usernameTextField.field.text;
            user.name = _nameTextField.field.text;
            user.email = user.username;
            user.password = _passwordTextField.field.text;
            user.avatarImage = _avatar;
            
            [_delegate loginViewDidPressCommitButton:user isSignUp:_isSignUp];
        }
    });
}

- (void)startCommitAnimation {
    [self enableView:NO];
}

- (void)stopCommitAnimation {
    [self enableView:YES];
}

- (void)enableView:(BOOL)isEnable {
    _headerView.userInteractionEnabled = isEnable;
    _leftOperationButton.enabled = isEnable;
    _rightOperationButton.enabled = isEnable;
    _commitButton.enabled = isEnable;
    
    if (isEnable)
        [_commitButton.indicator stopAnimating];
    else
        [_commitButton.indicator startAnimating];
}

#pragma mark - avatar

- (void)avatarButtonDidPress {
    if ([_delegate respondsToSelector:@selector(loginViewDidPressAvatarButton)])
        [_delegate loginViewDidPressAvatarButton];
}

- (void)setAvatar:(UIImage *)image {
    _avatar = image;
    [_headerView.avatarButton setBackgroundImage:image forState:UIControlStateNormal];
}

#pragma mark - switch to sign in/ sign up mode with animation

- (void)switchModeAnimate {
    _isSignUp = !_isSignUp;
    
    [self bindSwitchableData];
    
    __weak typeof(self) weakSelf = self;
    [_nameTextField mas_updateConstraints:^(MASConstraintMaker *make) {
        __typeof__(self) __strong strongSelf = weakSelf;
        make.height.offset(_isSignUp ? strongSelf->_textFieldHeight : 0);
    }];
    [_usernameTextField mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_nameTextField.mas_bottom).offset(_isSignUp ? 20 : 0);
    }];
    [UIView animateWithDuration:0.3 animations:^{
        _headerView.titleLabel.layer.opacity = _isSignUp;
        _nameTextField.layer.opacity = _isSignUp;
        [weakSelf layoutIfNeeded];
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
    __weak typeof(self) weakSelf = self;
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.offset(isShowAnimation ? -kPopHeightWhenKeyboardShow : 0);
    }];
    [_commitButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(_usernameTextField);
        make.height.equalTo(weakSelf).dividedBy(12);
        if (isShowAnimation)
            make.top.equalTo(_passwordTextField.mas_bottom).offset(20);
        else
            make.bottom.offset(-55);
    }];
    
    [UIView animateWithDuration:1 animations:^{[weakSelf.superview layoutIfNeeded];}];
}

#pragma mark - dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"%s", __func__);
}

@end