//
//  LoginView.m
//  TO-DO
//
//  Created by Siegrain on 16/5/8.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "HeaderView.h"
#import "LoginView.h"
#import "Macros.h"
#import "Masonry.h"
#import "SGTextField.h"
#import "SGUser.h"
#import "TodoHelper.h"
#import "UIImage+Extension.h"
#import "UIView+Extentsion.h"

static NSInteger const kPopHeightWhenKeyboardShow = 170;

@implementation LoginView {
    HeaderView* headerView;
    SGTextField* nameTextField;
    SGTextField* usernameTextField;
    SGTextField* passwordTextField;
    UIButton* commitButton;
    UIButton* leftOperationButton;
    UIButton* rightOperationButton;
    UIActivityIndicatorView* commitIndicatorView;

    BOOL isSignUp;
    CGFloat textFieldHeight;
    UIImage* avatarImage;
}
#pragma mark - localization
- (void)localizeStrings
{
    headerView.headerTitleLabel.text = NSLocalizedString(@"LABEL_SIGNUP", nil);
    nameTextField.title = NSLocalizedString(@"LABEL_NAME", nil);
    passwordTextField.title = NSLocalizedString(@"LABEL_PASSWORD", nil);

    [self bindSwitchableDatas];
}
- (void)bindSwitchableDatas
{
    if (isSignUp) {
        usernameTextField.title = NSLocalizedString(@"LABEL_EMAIL", nil);
        [commitButton setTitle:NSLocalizedString(@"BUTTON_SIGNUP", nil) forState:UIControlStateNormal];
        [rightOperationButton setTitle:NSLocalizedString(@"LABEL_SIGNIN", nil) forState:UIControlStateNormal];
        [leftOperationButton setTitle:NSLocalizedString(@"LABEL_TERMS&CONDITIONS", nil) forState:UIControlStateNormal];
        [headerView.avatarButton setBackgroundImage:avatarImage ? avatarImage : [UIImage imageAtResourcePath:@"mark-signup"] forState:UIControlStateNormal];
        headerView.userInteractionEnabled = YES;
    } else {
        usernameTextField.title = NSLocalizedString(@"LABEL_USERNAME", nil);
        [commitButton setTitle:NSLocalizedString(@"BUTTON_SIGNIN", nil) forState:UIControlStateNormal];
        [rightOperationButton setTitle:NSLocalizedString(@"LABEL_SIGNUP", nil) forState:UIControlStateNormal];
        [leftOperationButton setTitle:NSLocalizedString(@"LABEL_FORGOTPASSWORD", nil) forState:UIControlStateNormal];
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
    [loginView attachKeyboardObserver];
    [loginView localizeStrings];

    return loginView;
}
- (void)setup
{
    __weak typeof(self) weakSelf = self;
    headerView = [HeaderView headerView];
    [headerView.headerImageView setImage:[UIImage imageAtResourcePath:@"login header bg"]];
    [headerView setHeaderViewDidPressAvatarButton:^{
        [weakSelf avatarButtonDidPress];
    }];
    [self addSubview:headerView];

    nameTextField = [SGTextField textField];
    nameTextField.returnKeyType = UIReturnKeyNext;
    nameTextField.layer.opacity = 0;
    // Mark: 由于该 block 为属性，而在 block 内通过->访问私有成员变量在 ARC 下是不允许的，所以此刻要么在 block 内使用strongSelf，要么不持有该 block ,现在采用的方案是不持有该 block
    __weak SGTextField* weakNameTextField = nameTextField;
    [weakNameTextField setTextFieldShouldReturn:^(SGTextField* textField) {
        [usernameTextField becomeFirstResponder];
    }];
    [self addSubview:nameTextField];

    usernameTextField = [SGTextField textField];
    usernameTextField.returnKeyType = UIReturnKeyNext;
    __weak SGTextField* weakUsernameTextField = usernameTextField;
    [weakUsernameTextField setTextFieldShouldReturn:^(SGTextField* textField) {
        [passwordTextField becomeFirstResponder];
    }];
    [self addSubview:usernameTextField];

    passwordTextField = [SGTextField textField];
    passwordTextField.returnKeyType = UIReturnKeyJoin;
    passwordTextField.secureTextEntry = YES;
    __weak SGTextField* weakPasswordTextField = passwordTextField;
    [weakPasswordTextField setTextFieldShouldReturn:^(SGTextField* textField) {
        [self commitButtonDidPress];
    }];
    [self addSubview:passwordTextField];

    commitButton = [[UIButton alloc] init];
    [commitButton setBackgroundImage:[UIImage imageWithColor:[TodoHelper buttonColorNormal]]
                            forState:UIControlStateNormal];
    [commitButton setBackgroundImage:[UIImage imageWithColor:[TodoHelper buttonColorHighlighted]]
                            forState:UIControlStateHighlighted];
    [commitButton setBackgroundImage:[UIImage imageWithColor:[TodoHelper buttonColorDisabled]]
                            forState:UIControlStateDisabled];
    commitButton.titleLabel.font = [TodoHelper themeFontWithSize:14];
    [commitButton addTarget:self action:@selector(commitButtonDidPress) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:commitButton];

    commitIndicatorView = [[UIActivityIndicatorView alloc] init];
    commitIndicatorView.hidesWhenStopped = YES;
    [commitButton addSubview:commitIndicatorView];

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
    [rightOperationButton addTarget:self
                             action:@selector(switchModeAnimate)
                   forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:rightOperationButton];
}

- (void)bindConstraints
{
    [headerView mas_makeConstraints:^(MASConstraintMaker* make) {
        make.left.top.right.offset(0);
        make.height.equalTo(self).multipliedBy(0.4);
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
        make.height.equalTo(self).dividedBy(12);
    }];

    [commitIndicatorView mas_makeConstraints:^(MASConstraintMaker* make) {
        make.centerY.offset(0);
        make.height.equalTo(commitButton).dividedBy(2);
        make.width.equalTo(commitIndicatorView.mas_height);
        make.centerX.offset(-40);
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

- (void)attachKeyboardObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}
#pragma mark - commit & commit animation
- (void)commitButtonDidPress
{
    // Mark: synchronized lock
    dispatch_queue_t serialQueue = dispatch_queue_create("LoginViewCommitSynchronizedLock", DISPATCH_QUEUE_SERIAL);
    dispatch_sync(serialQueue, ^{
        if (commitIndicatorView.isAnimating)
            return;

        if ([_delegate respondsToSelector:@selector(loginViewDidPressCommitButton:isSignUp:)]) {
            __weak typeof(self) weakSelf = self;

            [weakSelf startCommitAnimation];

            SGUser* user = [[SGUser alloc] init];
            user.name = nameTextField.text;
            user.email = usernameTextField.text;
            user.password = passwordTextField.text;
            user.lastLoginTime = [NSDate date];
            user.avatarImage = avatarImage;

            if (isSignUp)
                user.registerTime = [NSDate date];

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
        [commitIndicatorView stopAnimating];
    else
        [commitIndicatorView startAnimating];
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
                         headerView.headerTitleLabel.layer.opacity = isSignUp;
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
- (void)animateByKeyboard:(BOOL)show
{
    CGFloat viewPopHeight = show ? kPopHeightWhenKeyboardShow : 0;

    // Mark: SDAutoLayout 更新约束有动画的话有 Bug ，只能用 Masonry
    __weak typeof(self) weakSelf = self;
    [self mas_updateConstraints:^(MASConstraintMaker* make) {
        make.top.offset(-viewPopHeight);
        make.bottom.offset(-viewPopHeight);
    }];
    if (show) {
        [commitButton mas_remakeConstraints:^(MASConstraintMaker* make) {
            make.left.right.equalTo(usernameTextField);
            make.top.equalTo(passwordTextField.mas_bottom).offset(20);
            make.height.equalTo(weakSelf).dividedBy(12);
        }];
    } else {
        [commitButton mas_remakeConstraints:^(MASConstraintMaker* make) {
            make.left.right.equalTo(usernameTextField);
            make.bottom.offset(-55);
            make.height.equalTo(weakSelf).dividedBy(12);
        }];
    }

    [UIView animateWithDuration:1
                     animations:^{
                         [self.superview layoutIfNeeded];
                     }];
}

#pragma mark - dealloc
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end