//
// Created by Siegrain on 16/12/3.
// Copyright (c) 2016 com.siegrain. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SGNavigationBar <NSObject>
@optional
- (void)leftNavButtonDidPress;
- (void)rightNavButtonDidPress;
@end

@interface UIViewController (SGConfigure)
- (void)setupNavigationBar;

- (void)setupNavigationBackIndicator;
@end