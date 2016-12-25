//
// Created by Siegrain on 16/12/26.
// Copyright (c) 2016 com.siegrain. All rights reserved.
//

#import "SGWebViewController.h"
#import "UIViewController+SGConfigure.h"


@implementation SGWebViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.loadingBarTintColor = [SGHelper themeColorRed];
    self.buttonTintColor = [SGHelper themeColorRed];
    
    [self setupNavigationBar];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self setupNavigationBackIndicator];
}
@end