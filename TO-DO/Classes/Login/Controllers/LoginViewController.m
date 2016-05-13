//
//  LoginViewController.m
//  TO-DO
//
//  Created by Siegrain on 16/5/7.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "LoginDataManager.h"
#import "LoginViewController.h"
#import "Masonry.h"
#import "SCLAlertView.h"
#import "SGUser.h"
#import "TodoHelper.h"
#import "UIView+SDAutoLayout.h"

/* localization dictionary keys */
static NSString* const kAvatarTakePhotoKey = @"takePhoto";
static NSString* const kAvatarFromAlbumKey = @"album";
static NSString* const kAvatarCancelKey = @"cancel";

@implementation LoginViewController {
    LoginView* loginView;
    LoginDataManager* dataManager;

    BOOL releaseWhileDisappear;
}
@synthesize localDictionary = _localDictionary;
#pragma mark - localization
- (void)localizeStrings
{
    [_localDictionary setObject:NSLocalizedString(@"ACTION_TAKEPHOTO", nil) forKey:kAvatarTakePhotoKey];
    [_localDictionary setObject:NSLocalizedString(@"ACTION_FROMALBUM", nil) forKey:kAvatarFromAlbumKey];
    [_localDictionary setObject:NSLocalizedString(@"ACTION_CANCEL", nil) forKey:kAvatarCancelKey];
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

    dataManager = [[LoginDataManager alloc] init];

    _localDictionary = [NSMutableDictionary dictionary];
    [self localizeStrings];

    releaseWhileDisappear = true;
}

#pragma mark - loginView delegate
#pragma mark - commit
- (void)loginViewDidPressCommitButton:(SGUser*)user isSignUp:(BOOL)isSignUp
{
    [dataManager handleCommit:user
                     isSignUp:isSignUp
                     complete:^(bool succeed) {
                         [loginView stopCommitAnimation];
                         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                         if (!succeed) return;
                     }];
}
#pragma mark - avatar
- (void)loginViewDidPressAvatarButton
{
    __weak typeof(self) weakSelf = self;
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction* photoAction = [UIAlertAction actionWithTitle:_localDictionary[kAvatarTakePhotoKey]
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction* _Nonnull action) {
                                                            [weakSelf alertActionDidSelect:UIImagePickerControllerSourceTypeCamera];
                                                        }];
    UIAlertAction* albumAction = [UIAlertAction actionWithTitle:_localDictionary[kAvatarFromAlbumKey]
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction* _Nonnull action) {
                                                            [weakSelf alertActionDidSelect:UIImagePickerControllerSourceTypePhotoLibrary];
                                                        }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:_localDictionary[kAvatarCancelKey] style:UIAlertActionStyleCancel handler:nil];

    [alertController addAction:photoAction];
    [alertController addAction:albumAction];
    [alertController addAction:cancelAction];

    [self presentViewController:alertController animated:YES completion:nil];
}
- (void)alertActionDidSelect:(UIImagePickerControllerSourceType)type
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
    if (!releaseWhileDisappear)
        return;

    [loginView removeFromSuperview];
    loginView = nil;
    dataManager = nil;
    _localDictionary = nil;
}
@end
