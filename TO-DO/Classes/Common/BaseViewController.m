//
//  BaseViewController.m
//  TO-DO
//
//  Created by Siegrain on 16/5/19.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "BaseViewController.h"
#import "HeaderView.h"
#import "SGUser.h"
#import "UINavigationController+Transparent.h"

@implementation BaseViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    user = [SGUser currentUser];

    [self setupNavigation];
    [self setupView];
    [self bindConstraints];
}
- (void)setupNavigation
{
    [self.navigationController transparentNavigationBar];

    UIButton* menuBarbutton = [[UIButton alloc] init];
    menuBarbutton.tintColor = [UIColor whiteColor];
    menuBarbutton.frame = CGRectMake(0, 0, 20, 20);
    [menuBarbutton setBackgroundImage:[UIImage imageNamed:@"menu"] forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuBarbutton];

    UIButton* searchBarbutton = [[UIButton alloc] init];
    searchBarbutton.tintColor = [UIColor whiteColor];
    searchBarbutton.frame = CGRectMake(0, 0, 20, 20);
    [searchBarbutton setBackgroundImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:searchBarbutton];
}
- (void)setupView
{
}
- (void)bindConstraints
{
}
@end
