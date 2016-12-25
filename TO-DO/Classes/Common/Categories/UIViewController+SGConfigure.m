//
// Created by Siegrain on 16/12/3.
// Copyright (c) 2016 com.siegrain. All rights reserved.
//

#import "UIViewController+SGConfigure.h"
#import "UIImage+Extension.h"

@implementation UIViewController (SGConfigure)

- (void)setupNavigationBar {
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:Localized(@"OK") style:UIBarButtonItemStylePlain target:self action:@selector(rightNavButtonDidPress)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:Localized(@"Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(leftNavButtonDidPress)];
    self.navigationItem.rightBarButtonItem.tintColor = self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:[SGHelper themeColorRed]] forBarMetrics:UIBarMetricsDefault];
}

- (void)setupNavigationBackIndicator {
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.leftBarButtonItem.title = nil;
    self.navigationItem.leftBarButtonItem.image = [UIImage imageNamed:@"back"];
    self.navigationItem.leftBarButtonItem.imageInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    self.navigationItem.rightBarButtonItem.tintColor = self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
}
@end