//
//  HomeViewController.m
//  TO-DO
//
//  Created by Siegrain on 16/5/13.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "AVOSCloud.h"
#import "HeaderView.h"
#import "HomeTableViewController.h"
#import "JTNavigationController.h"
#import "Macros.h"
#import "Masonry.h"
#import "SGUser.h"
#import "UIImage+Extension.h"
#import "UIImage+Qiniu.h"
#import "UINavigationController+Transparent.h"

@implementation HomeTableViewController {
    HeaderView* headerView;
    SGUser* user;
}
#pragma mark - localization
- (void)localizeStrings
{
    headerView.titleLabel.text = NSLocalizedString(@"LABEL_TASKS", nil);
    headerView.subtitleLabel.text = @"MAY 14, 2016";
}
#pragma mark - initial
- (void)viewDidLoad
{
    [super viewDidLoad];

    user = [SGUser currentUser];

    [self setupNavigationBar];
    [self setup];
    [self bindConstraints];
    [self localizeStrings];
}
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    // Mark: 因为导航栏多出的64的高度，如果想忽略的话需要在这里设置
    self.tableView.contentInset = UIEdgeInsetsZero;

    // Mark: tableviewHeader 不认约束
    CGFloat height = [headerView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    CGRect frame = headerView.frame;
    frame.size.height = height;
    headerView.frame = frame;

    self.tableView.tableHeaderView = headerView;
}
- (void)setupNavigationBar
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
- (void)setup
{
    headerView = [HeaderView headerViewWithAvatarPosition:HeaderAvatarPositionCenter titleAlignement:HeaderTitleAlignementCenter];
    [headerView.rightOperationButton setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    [headerView.avatarButton setImage:[UIImage qn_imageWithString:user.avatar andStyle:kImageStyleSmall] forState:UIControlStateNormal];
    headerView.backgroundImageView.image = [UIImage imageAtResourcePath:@"header bg"];
    [headerView setHeaderViewDidPressAvatarButton:^{
        [SGUser logOut];
    }];
    self.tableView.tableHeaderView = headerView;
}
- (void)bindConstraints
{
    [headerView mas_makeConstraints:^(MASConstraintMaker* make) {
        make.top.left.offset(0);
        make.width.offset(kScreenWidth);
        make.height.offset(kScreenHeight * 0.6);
    }];
}
#pragma mark -

@end
