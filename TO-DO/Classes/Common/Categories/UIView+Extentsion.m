//
//  UIView+Extentsion.m
//  TO-DO
//
//  Created by Siegrain on 16/5/11.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "UIView+Extentsion.h"

@implementation UIView (Extentsion)
- (UIViewController*)currentTopViewController
{
    UIViewController* topVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    while (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    return topVC;
}
@end
