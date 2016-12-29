//
// Created by Siegrain on 16/12/26.
// Copyright (c) 2016 com.siegrain. All rights reserved.
//

#import "SGWebViewController.h"
#import "UIViewController+SGConfigure.h"

@interface SGWebViewController () <SGNavigationBar>
@end

@implementation SGWebViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.loadingBarTintColor = [SGHelper themeColorRed];
    self.buttonTintColor = [SGHelper themeColorRed];
    
    [self setupNavigationBar];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self setupNavigationBar];
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.leftBarButtonItem.title = Localized(@"Close");
    if(!_showCloseButton) [self setupNavigationBackIndicator];
}

- (void)leftNavButtonDidPress {
    if (_showCloseButton) [self dismissViewControllerAnimated:YES completion:nil];
}

@end