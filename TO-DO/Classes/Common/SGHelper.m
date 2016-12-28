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
#import "SDImageCache.h"
#import "TZImagePickerController.h"
#import "IDMPhoto.h"
#import "IDMPhotoBrowser.h"
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

#pragma mark - photo picker

+ (void)photoPickerFrom:(UIViewController <TZImagePickerControllerDelegate> *)viewController allowCrop:(BOOL)allowCrop currentPhoto:(UIImage *)currentPhoto pickerDidPicked:(void (^)(UIImage *image))pickerDidPicked {
    if (currentPhoto) {
        LCActionSheet *sheet = [LCActionSheet sheetWithTitle:Localized(@"Choose operation") cancelButtonTitle:Localized(@"Cancel") clicked:^(LCActionSheet *actionSheet, NSInteger buttonIndex) {
            if (buttonIndex == 1){
                IDMPhoto * photo = [IDMPhoto photoWithImage:currentPhoto];
                IDMPhotoBrowser * browser = [[IDMPhotoBrowser alloc] initWithPhotos:@[photo]];
                [viewController presentViewController:browser animated:YES completion:nil];
            }
            else if (buttonIndex == 2)
                [self photoPickerFrom:viewController allowCrop:allowCrop pickerDidPicked:pickerDidPicked];
        } otherButtonTitles:Localized(@"View original"), Localized(@"Pick from album"), nil];
        [sheet show];
    } else {
        [self photoPickerFrom:viewController allowCrop:allowCrop pickerDidPicked:pickerDidPicked];
    }
}

+ (void)photoPickerFrom:(UIViewController <TZImagePickerControllerDelegate> *)viewController allowCrop:(BOOL)allowCrop pickerDidPicked:(void (^)(UIImage *image))pickerDidPicked {
    TZImagePickerController *controller = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:viewController];
    controller.allowPickingOriginalPhoto = NO;
    controller.allowPickingVideo = NO;
    controller.allowCrop = allowCrop;
    [controller setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        pickerDidPicked(photos.firstObject);
    }];
    [viewController presentViewController:controller animated:YES completion:nil];
}

#pragma mark - photo browser


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

#pragma mark - file

+ (CGFloat)fileSizeAtPath:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        long long size = [fileManager attributesOfItemAtPath:path error:nil].fileSize;
        return (CGFloat) (size / 1024.0 / 1024.0);
    }
    return 0;
}

+ (CGFloat)folderSizeAtPath:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    CGFloat folderSize;
    if ([fileManager fileExistsAtPath:path]) {
        NSArray *childFiles = [fileManager subpathsAtPath:path];
        for (NSString *fileName in childFiles) {
            NSString *absolutePath = [path stringByAppendingPathComponent:fileName];
            folderSize += [self fileSizeAtPath:absolutePath];
        }
        //SDWebImage框架自身计算缓存的实现
        folderSize += [[SDImageCache sharedImageCache] getSize] / 1024.0 / 1024.0;
        return folderSize;
    }
    return 0;
}

+ (void)clearCache:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        NSArray *childFiles = [fileManager subpathsAtPath:path];
        for (NSString *fileName in childFiles) {
            NSString *absolutePath = [path stringByAppendingPathComponent:fileName];
            [fileManager removeItemAtPath:absolutePath error:nil];
        }
    }
    [[SDImageCache sharedImageCache] cleanDisk];
}


#pragma mark - device helper

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
