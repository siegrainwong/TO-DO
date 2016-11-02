//
//  LoginViewController.m
//  TO-DO
//
//  Created by Siegrain on 16/5/7.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeViewController.h"
#import "LCUser.h"
#import "LCUserDataManager.h"
#import "LoginViewController.h"
#import "Masonry.h"
#import "SCLAlertView.h"
#import "SGHelper.h"
#import "UIView+SDAutoLayout.h"

@interface
LoginViewController ()
@property (nonatomic, readwrite, strong) LoginView* loginView;
@property (nonatomic, readwrite, strong) LCUserDataManager* dataManager;
@property (nonatomic, readwrite, assign) BOOL releaseWhileDisappear;
@end

@implementation LoginViewController
#pragma mark - initial
- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setup];
}
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}
- (void)setup
{
    _loginView = [LoginView loginView];
    _loginView.delegate = self;
    [self.view addSubview:_loginView];

    [_loginView mas_makeConstraints:^(MASConstraintMaker* make) {
        make.left.right.top.bottom.offset(0);
    }];

    _dataManager = [[LCUserDataManager alloc] init];

    _releaseWhileDisappear = true;
}

#pragma mark - loginView delegate
#pragma mark - commit
- (void)loginViewDidPressCommitButton:(LCUser*)user isSignUp:(BOOL)isSignUp
{
    [_dataManager handleCommit:user isSignUp:isSignUp complete:^(bool succeed) {
        [_loginView stopCommitAnimation];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if (!succeed) return;

        AppDelegate* delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        [delegate setupUser];
        [delegate switchRootViewController:[[HomeViewController alloc] init] isNavigation:YES];
    }];
}
#pragma mark - avatar
- (void)loginViewDidPressAvatarButton
{
    __weak typeof(self) weakSelf = self;
    [SGHelper pictureActionSheetFrom:self
      selectCameraHandler:^{ [weakSelf actionSheetItemDidSelect:UIImagePickerControllerSourceTypeCamera]; }
      selectAlbumHandler:^{ [weakSelf actionSheetItemDidSelect:UIImagePickerControllerSourceTypePhotoLibrary]; }];
}
- (void)actionSheetItemDidSelect:(UIImagePickerControllerSourceType)type
{
    BOOL error = false;
    [SGHelper pickPictureFromSource:type target:self error:&error];
    _releaseWhileDisappear = error;
}
#pragma mark - imagePicker delegate
- (void)imagePickerController:(UIImagePickerController*)picker
didFinishPickingMediaWithInfo:(NSDictionary<NSString*, id>*)info
{
    [_loginView setAvatar:info[UIImagePickerControllerEditedImage]];
    [picker dismissViewControllerAnimated:true completion:nil];
    _releaseWhileDisappear = true;
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController*)picker
{
    [picker dismissViewControllerAnimated:true completion:nil];
    _releaseWhileDisappear = true;
}
#pragma mark - release
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    if (!_releaseWhileDisappear)
        return;

    [_loginView removeFromSuperview];
    _loginView = nil;
}
- (void)dealloc
{
    NSLog(@"%s", __func__);
}
@end
