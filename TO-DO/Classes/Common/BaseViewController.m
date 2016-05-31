//
//  BaseViewController.m
//  TO-DO
//
//  Created by Siegrain on 16/5/19.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "AppDelegate.h"
#import "BaseViewController.h"
#import "UINavigationController+Transparent.h"

@interface
BaseViewController ()
@property (nonatomic, readwrite, strong) UIButton* menuButton;
@property (nonatomic, readwrite, strong) UILabel* titleLabel;
@property (nonatomic, readwrite, strong) UIButton* searchButton;
@end

@implementation BaseViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    _user = [LCUser currentUser];
    _releaseWhileDisappear = YES;

    [self setupView];
    [self bindConstraints];
}
- (void)setupView
{
    [self setupNavigation];
    [self attachGestureRecognizer];
}
- (void)bindConstraints
{
}
- (void)setupNavigation
{
    [self.navigationController transparentNavigationBar];

    _menuButton = [[UIButton alloc] init];
    _menuButton.tintColor = [UIColor whiteColor];
    _menuButton.frame = CGRectMake(0, 0, 20, 17);
    [_menuButton addTarget:self action:@selector(toggleDrawer) forControlEvents:UIControlEventTouchUpInside];
    [_menuButton setBackgroundImage:[UIImage imageNamed:@"menu"] forState:UIControlStateNormal];

    UIView* placeholderView = [[UIView alloc] init];
    placeholderView.frame = CGRectMake(0, 0, 5, 1);

    _titleLabel = [[UILabel alloc] init];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.frame = CGRectMake(0, 0, 100, 20);
    _titleLabel.font = [TodoHelper themeFontWithSize:17];

    UIBarButtonItem* menuBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_menuButton];
    UIBarButtonItem* titleBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_titleLabel];
    UIBarButtonItem* placeHolderBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:placeholderView];
    [self.navigationItem setLeftBarButtonItems:@[ menuBarButtonItem, placeHolderBarButtonItem, titleBarButtonItem ] animated:YES];

    _searchButton = [[UIButton alloc] init];
    _searchButton.tintColor = [UIColor whiteColor];
    _searchButton.frame = CGRectMake(0, 0, 20, 20);
    [_searchButton setBackgroundImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_searchButton];
}
- (void)attachGestureRecognizer
{
    UITapGestureRecognizer* tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    // Mark: 意为不要取消其他视图的触摸事件，为YES的话就不能触发为其他控件添加的触摸事件
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGestureRecognizer];

    UISwipeGestureRecognizer* leftSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(toggleDrawer)];
    leftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:leftSwipeGestureRecognizer];
}
#pragma mark - drawer
- (void)toggleDrawer
{
    [[AppDelegate globalDelegate] toggleDrawer:self animated:YES];
}
#pragma mark - navigationbar text
- (void)setMenuTitle:(NSString*)title
{
    _titleLabel.text = title;
}
#pragma mark - tap gesture method
- (void)hideKeyboard:(UITapGestureRecognizer*)recognizer
{
    [self.view endEditing:YES];
}
#pragma mark - release
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    if (!_releaseWhileDisappear) return;

    [_headerView removeFromSuperview];
    _headerView = nil;
}
@end
