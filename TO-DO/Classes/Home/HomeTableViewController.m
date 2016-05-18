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

@implementation HomeTableViewController {
    HeaderView* headerView;
    SGUser* user;
}
#pragma mark - localization
- (void)localizeStrings
{
    headerView.headerTitleLabel.text = NSLocalizedString(@"LABEL_TASKS", nil);
}
#pragma mark - initial
- (void)viewDidLoad
{
    user = [SGUser currentUser];

    [self setup];
    [self bindConstraints];
    [self localizeStrings];
}
- (void)viewDidLayoutSubviews
{
    // Mark: tableviewHeader 不认约束
    CGFloat height = [headerView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    CGRect frame = headerView.frame;
    frame.size.height = height;
    headerView.frame = frame;

    self.tableView.tableHeaderView = headerView;
}
- (void)setup
{
    headerView = [HeaderView headerView];
    headerView.avatarPosition = HeaderAvatarPositionCenter;
    [headerView.rightOperationButton setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    [headerView.avatarButton setImage:[UIImage qn_imageWithString:user.avatar andStyle:kImageStyleSmall] forState:UIControlStateNormal];
    headerView.headerImageView.image = [UIImage imageAtResourcePath:@"header bg"];
    self.tableView.tableHeaderView = headerView;
}
- (void)bindConstraints
{
    [headerView mas_makeConstraints:^(MASConstraintMaker* make) {
        make.top.left.offset(0);
        make.width.offset(kScreenWidth);
        make.height.offset(kScreenHeight * 0.65);
    }];
}
@end
