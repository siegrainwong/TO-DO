//
//  UINavigationController+Transparent.m
//  TO-DO
//
//  Created by Siegrain on 16/5/18.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "UINavigationController+Transparent.h"

@implementation UINavigationController (Transparent)
- (void)transparentNavigationBar
{
    [self.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.shadowImage = [UIImage new];
    self.navigationBar.translucent = YES;
}
@end
