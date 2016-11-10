//
// Created by Siegrain on 16/11/7.
// Copyright (c) 2016 com.siegrain. All rights reserved.
//

#import "CommonDataManager.h"
#import "SGImageUpload.h"
#import "CDUser.h"
#import "AppDelegate.h"


@implementation CommonDataManager
+ (void)modifyAvatarWithImage:(UIImage *)image block:(void (^)())block {
    [SGHelper waitingAlert];
    [SGImageUpload uploadImage:image type:SGImageTypeAvatar prefix:kUploadPrefixAvatar completion:^(bool error, NSString *path) {
        if (error) return [SGHelper errorAlertWithMessage:Localized(@"Failed to upload avatar, please try again")];
        [AppDelegate globalDelegate].cdUser.avatar = path;
        [AppDelegate globalDelegate].lcUser.avatar = path;
        
        [[AppDelegate globalDelegate].lcUser saveInBackground];
        MR_saveAndWait();
        
        [SGHelper dismissAlert];
        if (block)block();
    }];
}
@end