//
//  BaseViewController.m
//  TO-DO
//
//  Created by Siegrain on 16/5/19.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "BaseViewController.h"
#import "UINavigationController+Transparent.h"

@implementation BaseViewController {
    UIButton* menuButton;
    UILabel* titleLabel;
    UIButton* searchButton;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    user = [SGUser currentUser];

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

    menuButton = [[UIButton alloc] init];
    menuButton.tintColor = [UIColor whiteColor];
    menuButton.frame = CGRectMake(0, 0, 20, 17);
    [menuButton setBackgroundImage:[UIImage imageNamed:@"menu"] forState:UIControlStateNormal];

    UIView* placeholderView = [[UIView alloc] init];
    placeholderView.frame = CGRectMake(0, 0, 5, 1);

    titleLabel = [[UILabel alloc] init];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.frame = CGRectMake(0, 0, 100, 20);
    titleLabel.font = [TodoHelper themeFontWithSize:17];

    UIBarButtonItem* menuBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
    UIBarButtonItem* titleBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:titleLabel];
    UIBarButtonItem* placeHolderBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:placeholderView];
    [self.navigationItem setLeftBarButtonItems:@[ menuBarButtonItem, placeHolderBarButtonItem, titleBarButtonItem ] animated:YES];

    searchButton = [[UIButton alloc] init];
    searchButton.tintColor = [UIColor whiteColor];
    searchButton.frame = CGRectMake(0, 0, 20, 20);
    [searchButton setBackgroundImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:searchButton];
}
- (void)attachGestureRecognizer
{
    UITapGestureRecognizer* tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    // Mark: 意为不要取消其他视图的触摸事件，为YES的话就不能触发为其他控件添加的触摸事件
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGestureRecognizer];
}
#pragma mark - modify the titile on navigation bar
- (void)setMenuTitle:(NSString*)title
{
    titleLabel.text = title;
}
#pragma mark - tap gesture method
- (void)hideKeyboard:(UITapGestureRecognizer*)recognizer
{
    [self.view endEditing:YES];
}
@end
