//
//  TodoHelper.m
//  TO-DO
//
//  Created by Siegrain on 16/5/7.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "Macros.h"
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
#pragma mark - pick a picture by camera or album
+ (void)pickPictureFromSource:(UIImagePickerControllerSourceType)sourceType target:(UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate>*)target error:(BOOL*)error
{
    // 判断相机权限
    if (sourceType == UIImagePickerControllerSourceTypeCamera) {
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
            [SCLAlertHelper errorAlertWithContent:NSLocalizedString(@"ERROR_CAMERA_DENIED", nil)];
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
        [SCLAlertHelper errorAlertWithContent:NSLocalizedString(@"EXCEPTION_CAMERA_OR_ALBUM_UNAVAILABLE", nil)];
        *error = true;
        return;
    }
}
@end
