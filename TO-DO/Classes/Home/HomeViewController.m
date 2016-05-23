//
//  HomeViewController.m
//  TO-DO
//
//  Created by Siegrain on 16/5/13.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "CreateViewController.h"
#import "HomeViewController.h"
#import "LCTodo.h"
#import "Macros.h"
#import "TodoTableViewCell.h"
#import "UIImage+Extension.h"
#import "UIImage+Qiniu.h"
#import "UINavigationController+Transparent.h"
#import "UIScrollView+Extension.h"
#import "UITableView+Extension.h"
#import "UITableView+SDAutoTableViewCellHeight.h"

@implementation HomeViewController {
    UITableView* tableView;
}
#pragma mark - localization
- (void)localizeStrings
{
    headerView.titleLabel.text = NSLocalizedString(@"Tasks", nil);
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
    [tableView registerClass:[TodoTableViewCell class] forCellReuseIdentifier:kTodoIdentifierArray[TodoIdentifierNormal]];
    tableView.separatorInset = UIEdgeInsetsMake(0, kScreenHeight * kCellHorizontalInsetsMuiltipledByHeight, 0, kScreenHeight * kCellHorizontalInsetsMuiltipledByHeight);
    [self.view addSubview:tableView];

    headerView = [HeaderView headerViewWithAvatarPosition:HeaderAvatarPositionCenter titleAlignement:HeaderTitleAlignementCenter];
    [headerView.rightOperationButton setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    [headerView.avatarButton setImage:[UIImage qn_imageWithString:user.avatar andStyle:kImageStyleSmall] forState:UIControlStateNormal];
    headerView.backgroundImageView.image = [UIImage imageAtResourcePath:@"header bg"];
    [headerView setHeaderViewDidPressAvatarButton:^{
        [LCUser logOut];
    }];
    __weak typeof(self) weakSelf = self;
    [headerView setHeaderViewDidPressRightOperationButton:^{
        CreateViewController* createViewController = [[CreateViewController alloc] init];
        [weakSelf.navigationController pushViewController:createViewController animated:YES];
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
- (CGFloat)tableView:(UITableView*)tableView
  heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    //    Moment* model = self.momentsArray[indexPath.row];
    //    if (!model.height) {
    //        model.height = [self.tableView cellHeightForIndexPath:indexPath model:model keyPath:@"model" cellClass:[MomentTableViewCell class] contentViewWidth:[self cellContentViewWith]];
    //    }

    return [self->tableView cellHeightForIndexPath:indexPath model:[LCTodo object] keyPath:@"model" cellClass:[TodoTableViewCell class] contentViewWidth:kScreenWidth];
}
- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}
- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    TodoTableViewCell* cell = [self->tableView dequeueReusableCellWithIdentifier:kTodoIdentifierArray[TodoIdentifierNormal]];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}
- (void)configureCell:(TodoTableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    [cell setModel:[LCTodo object]];
}
@end
