//
//  TodoHelper.m
//  TO-DO
//
//  Created by Siegrain on 16/5/7.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "Macros.h"
#import "Masonry.h"
#import "SCLAlertHelper.h"
#import "TodoHelper.h"
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/UTCoreTypes.h>

@implementation TodoHelper
#pragma mark - font
+ (UIFont*)themeFontWithSize:(CGFloat)size
{
    return [UIFont fontWithName:@"Avenir" size:size];
}
#pragma mark - color
+ (UIColor*)buttonColorNormal
{
    return ColorWithRGB(0xFF3366);
}
+ (UIColor*)buttonColorHighlighted
{
    return ColorWithRGB(0xEE2B5B);
}
+ (UIColor*)buttonColorDisabled
{
    return ColorWithRGB(0xFE7295);
}
#pragma mark - 创建一个选择照片的 action sheet
+ (void)pictureActionSheetFrom:(UIViewController*)viewController selectCameraHandler:(void (^)())cameraHandler selectAlbumHandler:(void (^)())albumHandler
{
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction* photoAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Take a photo", nil)
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction* action) {
                                                            cameraHandler();
                                                        }];
    UIAlertAction* albumAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Pick from album", nil)
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction* action) {
                                                            albumHandler();
                                                        }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil];

    [alertController addAction:photoAction];
    [alertController addAction:albumAction];
    [alertController addAction:cancelAction];

    [viewController presentViewController:alertController animated:YES completion:nil];
}
#pragma mark - pick a picture by camera or album
+ (void)pickPictureFromSource:(UIImagePickerControllerSourceType)sourceType target:(UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate>*)target error:(BOOL*)error
{
    // 判断相机权限
    if (sourceType == UIImagePickerControllerSourceTypeCamera) {
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
            [SCLAlertHelper errorAlertWithContent:NSLocalizedString(@"Please allow app to access your device's camera in \"Settings\" -> \"Privacy\" -> \"Camera\"", nil)];
            *error = true;
            return;
        }
    }

    if ([UIImagePickerController isSourceTypeAvailable:sourceType]) {
        UIImagePickerController* picker = [[UIImagePickerController alloc] init];
        picker.mediaTypes = @[ (NSString*)kUTTypeImage ];
        picker.delegate = target;
        picker.allowsEditing = true;
        picker.sourceType = sourceType;
        [target presentViewController:picker animated:true completion:nil];
    } else {
        [SCLAlertHelper errorAlertWithContent:NSLocalizedString(@"Unable to open your camera or album because of an unexpected error", nil)];
        *error = true;
        return;
    }
}
#pragma mark -
@end
