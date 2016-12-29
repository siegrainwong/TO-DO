//
//  LoginViewController.m
//  TO-DO
//
//  Created by Siegrain on 16/5/7.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeViewController.h"
#import "LCUserDataManager.h"
#import "LoginViewController.h"

@interface LoginViewController () <TZImagePickerControllerDelegate>
@property(nonatomic, readwrite, strong) LoginView *loginView;
@property(nonatomic, readwrite, strong) LCUserDataManager *dataManager;
@end

@implementation LoginViewController
#pragma mark - initial

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)setup {
    _loginView = [LoginView loginView];
    _loginView.delegate = self;
    [self.view addSubview:_loginView];
    
    [_loginView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.offset(0);
    }];
    
    _dataManager = [[LCUserDataManager alloc] init];
}

#pragma mark - loginView delegate
#pragma mark - commit

- (void)loginViewDidPressCommitButton:(LCUser *)user isSignUp:(BOOL)isSignUp {
    [_dataManager commitWithUser:user isSignUp:isSignUp complete:^(bool succeed, NSString *errorMessage) {
        [_loginView stopCommitAnimation];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if (!succeed) return;
        
        [[AppDelegate globalDelegate] logIn];
    }];
}

#pragma mark - avatar

- (void)loginViewDidPressAvatarButton {
    __weak __typeof(self) weakSelf = self;
    [SGHelper photoPickerFrom:self allowCrop:YES currentPhoto:_loginView.avatar pickerDidPicked:^(UIImage *image) {weakSelf.loginView.avatar = image;}];
}

#pragma mark - release

- (void)dealloc {
    NSLog(@"%s", __func__);
}
@end
