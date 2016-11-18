//
// Created by Siegrain on 16/10/19.
// Copyright (c) 2016 com.lurenwang.gameplatform. All rights reserved.
//

#import "MBProgressHUD+SGExtension.h"

@implementation MBProgressHUD (SGExtension)
+ (instancetype)show {
    UIWindow *window = [[[UIApplication sharedApplication] windows] lastObject];
    if(!window) return nil;
    [self dismiss];    //hide before show
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
    [hud configure];
    return hud;
}

+ (instancetype)showWithText:(NSString *)text dismissAfter:(NSInteger)seconds {
    MBProgressHUD *hud = [self show];
    if(!hud) return nil;
    hud.mode = MBProgressHUDModeText;
    hud.label.text = text;
    hud.userInteractionEnabled = NO;
    if (seconds) dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{[self dismiss];});
    return hud;
}

+ (void)dismiss {
    UIWindow *window = [[[UIApplication sharedApplication] windows] lastObject];
    [MBProgressHUD hideHUDForView:window animated:YES];
}

#pragma mark - configure

- (void)configure {
//    [self.bezelView setColor:ColorWithRGB(0x000000)];
//    self.contentColor = [UIColor whiteColor];
}
@end
