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
#pragma mark - strange
/** 或许还会有用的方法...
 *      [self keyboardAnimationWithContainer:containerView
 bottomView:commitButton
 stickToView:locationTextField
 showKeyboard:isShowAnimation
 bottomViewCommonConstraints:^(MASConstraintMaker* make) {
 make.left.right.equalTo(linearView);
 make.height.offset(fieldHeight);
 }];
 *
 *  @param container       <#container description#>
 *  @param bottomView      <#bottomView description#>
 *  @param stickedView     <#stickedView description#>
 *  @param isShowAnimation <#isShowAnimation description#>
 *  @param block           <#block description#>
 */
//- (void)keyboardAnimationWithContainer:(UIView*)container bottomView:(UIView*)bottomView stickToView:(UIView*)stickedView showKeyboard:(BOOL)isShowAnimation bottomViewCommonConstraints:(void (^)(MASConstraintMaker* make))block
//{
//    CGFloat viewPopHeight = isShowAnimation ? kPopHeightWhenKeyboardShow : 0;
//    [container mas_updateConstraints:^(MASConstraintMaker* make) {
//        make.top.bottom.offset(-viewPopHeight);
//    }];
//
//    [bottomView mas_remakeConstraints:^(MASConstraintMaker* make) {
//        block(make);
//        if (isShowAnimation) {
//            make.top.equalTo(stickedView.mas_bottom).offset(20);
//        } else {
//            make.bottom.offset(-20);
//        }
//
//    }];
//
//    [UIView animateWithDuration:1 animations:^{ [container.superview layoutIfNeeded]; }];
//}
@end
