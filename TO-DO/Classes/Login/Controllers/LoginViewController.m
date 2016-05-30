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
#import "LoginDataManager.h"
#import "LoginViewController.h"
#import "Masonry.h"
#import "SCLAlertView.h"
#import "TodoHelper.h"
#import "UIView+SDAutoLayout.h"

@implementation LoginViewController {
    LoginView* loginView;
    LoginDataManager* _dataManager;

    BOOL releaseWhileDisappear;
}

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
    loginView = [LoginView loginView];
    loginView.delegate = self;
    [self.view addSubview:loginView];

    [loginView mas_makeConstraints:^(MASConstraintMaker* make) {
        make.left.right.top.bottom.offset(0);
    }];

    _dataManager = [[LoginDataManager alloc] init];

    releaseWhileDisappear = true;
}

#pragma mark - loginView delegate
#pragma mark - commit
- (void)loginViewDidPressCommitButton:(LCUser*)user isSignUp:(BOOL)isSignUp
{
    [_dataManager handleCommit:user
                     isSignUp:isSignUp
                     complete:^(bool succeed) {
                         [loginView stopCommitAnimation];
                         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                         if (!succeed) return;

                         AppDelegate* delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
                         [delegate switchRootViewController:[[HomeViewController alloc] init] isNavigation:YES];
                     }];
}
#pragma mark - avatar
- (void)loginViewDidPressAvatarButton
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
    releaseWhileDisappear = error;
}
#pragma mark - imagePicker delegate
- (void)imagePickerController:(UIImagePickerController*)picker
  didFinishPickingMediaWithInfo:(NSDictionary<NSString*, id>*)info
{
    [loginView setAvatar:info[UIImagePickerControllerEditedImage]];
    [picker dismissViewControllerAnimated:true completion:nil];
    releaseWhileDisappear = true;
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController*)picker
{
    [picker dismissViewControllerAnimated:true completion:nil];
    releaseWhileDisappear = true;
}
#pragma mark - release
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    // 不能在UIImagePickerController作为TopController的时候释放
    // 在切换RootViewController时，这个viewDidDisappear不一定会被调用...
    if (!releaseWhileDisappear)
        return;

    [loginView removeFromSuperview];
    loginView = nil;

    NSLog(@"%s", __func__);
}
- (void)dealloc
{
    [loginView removeFromSuperview];
    loginView = nil;

    NSLog(@"%s", __func__);
}
@end
