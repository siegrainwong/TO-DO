//
//  SGHelper.m
//  TO-DO
//
//  Created by Siegrain on 16/5/7.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "DateUtil.h"
#import "SCLAlertHelper.h"
#import "MBProgressHUD.h"
#import "LCActionSheet.h"
#import "MBProgressHUD+SGExtension.h"
#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <sys/utsname.h>

@implementation SGHelper
#pragma mark - font

+ (NSString *)themeFontName {
    return @"Avenir";
}

+ (UIFont *)themeFontWithSize:(CGFloat)size {
    return [UIFont fontWithName:@"Avenir" size:size];
}

+ (UIFont *)themeFontDefault {
    return [self themeFontWithSize:13];
}

+ (UIFont *)themeFontNavBar {
    return [self themeFontWithSize:17];
}

#pragma mark - color

+ (UIColor *)themeColorGray {
    return ColorWithRGB(0x999999);
}

+ (UIColor *)themeColorLightGray {
    return ColorWithRGB(0xEEEEEE);
}

+ (UIColor *)themeColorRed {
    return ColorWithRGB(0xFF3366);
}

+ (UIColor *)themeColorCyan {
    return ColorWithRGB(0x50D2C2);
}

+ (UIColor *)themeColorYellow {
    return ColorWithRGB(0xFCAB53);
}

+ (UIColor *)themeColorPurple {
    return ColorWithRGB(0x9F9CF8);
}

+ (UIColor *)buttonColorHighlighted {
    return ColorWithRGB(0xEE2B5B);
}

+ (UIColor *)buttonColorDisabled {
    return ColorWithRGB(0xFE7295);
}

+ (UIColor *)subTextColor {
    return ColorWithRGB(0x777777);
}

#pragma mark - 创建一个选择照片的 action sheet

+ (void)photoPickerFromTarget:(UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate> *)viewController {
    LCActionSheet *sheet = [LCActionSheet sheetWithTitle:Localized(@"Choose photo") cancelButtonTitle:Localized(@"Cancel") clicked:^(LCActionSheet *actionSheet, NSInteger buttonIndex) {
        if (buttonIndex == 1)
            [self pickPictureFromSource:UIImagePickerControllerSourceTypeCamera target:viewController error:nil];
        else if (buttonIndex == 2)
            [self pickPictureFromSource:UIImagePickerControllerSourceTypePhotoLibrary target:viewController error:nil];
    } otherButtonTitles:Localized(@"Take a photo"), Localized(@"Pick from album"), nil];
    [sheet show];
}

#pragma mark - pick a picture by camera or album

+ (void)pickPictureFromSource:(UIImagePickerControllerSourceType)sourceType target:(UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate> *)target error:(BOOL *)error {
    // 判断相机权限
    if (sourceType == UIImagePickerControllerSourceTypeCamera) {
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
            [SCLAlertHelper errorAlertWithContent:NSLocalizedString(@"Please allow app to access your device's camera in \"Settings\" -> \"Privacy\" -> \"Camera\"", nil)];
            if (error) *error = true;
            return;
        }
    }
    
    if ([UIImagePickerController isSourceTypeAvailable:sourceType]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.mediaTypes = @[(NSString *) kUTTypeImage];
        picker.delegate = target;
        picker.allowsEditing = true;
        picker.sourceType = sourceType;
        [target presentViewController:picker animated:true completion:nil];
    } else {
        if (error) *error = true;
        return;
    }
}

#pragma mark - convenience

+ (NSString *)photoPath {
    return [[[AppDelegate globalDelegate] sandboxUrl] stringByAppendingPathComponent:[NSString stringWithFormat:@"savedImages"]];
}


#pragma mark - alerts

+ (void)waitingAlert {
    [MBProgressHUD show];
}

+ (void)dismissAlert {
    [MBProgressHUD dismiss];
}

+ (void)errorAlertWithMessage:(NSString *)message {
    [SCLAlertHelper errorAlertWithContent:message];
}

+ (void)alertWithMessage:(NSString *)message {
    [MBProgressHUD showWithText:message dismissAfter:3];
}

#pragma mark - get localized format date string

+ (NSString *)localizedFormatDate:(NSDate *)date {
    NSString *dateFormat = isChina ? @"yyyy MMM d" : @"MMM d, yyyy";
    return [DateUtil dateString:date withFormat:dateFormat];
}

#pragma mark -
+ (NSString *)phoneModel {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
    
    if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 2G";
    
    if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G";
    
    if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS";
    
    if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4";
    
    if ([platform isEqualToString:@"iPhone3,2"]) return @"iPhone 4";
    
    if ([platform isEqualToString:@"iPhone3,3"]) return @"iPhone 4";
    
    if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4S";
    
    if ([platform isEqualToString:@"iPhone5,1"]) return @"iPhone 5";
    
    if ([platform isEqualToString:@"iPhone5,2"]) return @"iPhone 5";
    
    if ([platform isEqualToString:@"iPhone5,3"]) return @"iPhone 5c";
    
    if ([platform isEqualToString:@"iPhone5,4"]) return @"iPhone 5c";
    
    if ([platform isEqualToString:@"iPhone6,1"]) return @"iPhone 5s";
    
    if ([platform isEqualToString:@"iPhone6,2"]) return @"iPhone 5s";
    
    if ([platform isEqualToString:@"iPhone7,1"]) return @"iPhone 6 Plus";
    
    if ([platform isEqualToString:@"iPhone7,2"]) return @"iPhone 6";
    
    if ([platform isEqualToString:@"iPhone8,1"]) return @"iPhone 6s";
    
    if ([platform isEqualToString:@"iPhone8,2"]) return @"iPhone 6s Plus";
    
    if ([platform isEqualToString:@"iPhone8,4"]) return @"iPhone SE";
    
    if ([platform isEqualToString:@"iPhone9,1"]) return @"iPhone 7";
    
    if ([platform isEqualToString:@"iPhone9,2"]) return @"iPhone 7 Plus";
    
    if ([platform isEqualToString:@"iPod1,1"]) return @"iPod Touch 1G";
    
    if ([platform isEqualToString:@"iPod2,1"]) return @"iPod Touch 2G";
    
    if ([platform isEqualToString:@"iPod3,1"]) return @"iPod Touch 3G";
    
    if ([platform isEqualToString:@"iPod4,1"]) return @"iPod Touch 4G";
    
    if ([platform isEqualToString:@"iPod5,1"]) return @"iPod Touch 5G";
    
    if ([platform isEqualToString:@"iPad1,1"]) return @"iPad 1G";
    
    if ([platform isEqualToString:@"iPad2,1"]) return @"iPad 2";
    
    if ([platform isEqualToString:@"iPad2,2"]) return @"iPad 2";
    
    if ([platform isEqualToString:@"iPad2,3"]) return @"iPad 2";
    
    if ([platform isEqualToString:@"iPad2,4"]) return @"iPad 2";
    
    if ([platform isEqualToString:@"iPad2,5"]) return @"iPad Mini 1G";
    
    if ([platform isEqualToString:@"iPad2,6"]) return @"iPad Mini 1G";
    
    if ([platform isEqualToString:@"iPad2,7"]) return @"iPad Mini 1G";
    
    if ([platform isEqualToString:@"iPad3,1"]) return @"iPad 3";
    
    if ([platform isEqualToString:@"iPad3,2"]) return @"iPad 3";
    
    if ([platform isEqualToString:@"iPad3,3"]) return @"iPad 3";
    
    if ([platform isEqualToString:@"iPad3,4"]) return @"iPad 4";
    
    if ([platform isEqualToString:@"iPad3,5"]) return @"iPad 4";
    
    if ([platform isEqualToString:@"iPad3,6"]) return @"iPad 4";
    
    if ([platform isEqualToString:@"iPad4,1"]) return @"iPad Air";
    
    if ([platform isEqualToString:@"iPad4,2"]) return @"iPad Air";
    
    if ([platform isEqualToString:@"iPad4,3"]) return @"iPad Air";
    
    if ([platform isEqualToString:@"iPad4,4"]) return @"iPad Mini 2G";
    
    if ([platform isEqualToString:@"iPad4,5"]) return @"iPad Mini 2G";
    
    if ([platform isEqualToString:@"iPad4,6"]) return @"iPad Mini 2G";
    
    if ([platform isEqualToString:@"i386"]) return @"iPhone Simulator";
    
    if ([platform isEqualToString:@"x86_64"]) return @"iPhone Simulator";
    
    return platform;
}

@end
