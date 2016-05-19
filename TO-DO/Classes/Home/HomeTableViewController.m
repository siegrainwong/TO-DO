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
#import "Macros.h"
#import "Masonry.h"
#import "SGUser.h"
#import "UIImage+Extension.h"
#import "UIImage+Qiniu.h"
#import "UINavigationController+Transparent.h"
#import "UIScrollView+Extension.h"
#import "UITableView+Extension.h"

@implementation HomeTableViewController {
    UITableView* tableView;
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

    [self localizeStrings];
}
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    [tableView ignoreNavigationHeight];
    [tableView resizeTableHeaderView];
}
- (void)setupView
{
    [super setupView];

    tableView = [[UITableView alloc] init];
    tableView.bounces = NO;
    tableView.dataSource = self;
    tableView.delegate = self;
    [self.view addSubview:tableView];

    headerView = [HeaderView headerViewWithAvatarPosition:HeaderAvatarPositionCenter titleAlignement:HeaderTitleAlignementCenter];
    [headerView.rightOperationButton setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    [headerView.avatarButton setImage:[UIImage qn_imageWithString:user.avatar andStyle:kImageStyleSmall] forState:UIControlStateNormal];
    headerView.backgroundImageView.image = [UIImage imageAtResourcePath:@"header bg"];
    [headerView setHeaderViewDidPressAvatarButton:^{
        [SGUser logOut];
    }];
    tableView.tableHeaderView = headerView;
}
- (void)bindConstraints
{
    [super bindConstraints];

    [tableView mas_makeConstraints:^(MASConstraintMaker* make) {
        make.top.bottom.right.left.offset(0);
    }];

    [headerView mas_makeConstraints:^(MASConstraintMaker* make) {
        make.top.left.offset(0);
        make.width.offset(kScreenWidth);
        make.height.offset(kScreenHeight * 0.6);
    }];
}
#pragma mark - tableview
- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}
- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return [UITableViewCell new];
}

@end
