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
    NSMutableArray<LCTodo*>* dataArray;
}
#pragma mark - localization
- (void)localizeStrings
{
    headerView.titleLabel.text = NSLocalizedString(@"Tasks", nil);
    headerView.subtitleLabel.text = @"MAY 14, 2016";
}
#pragma mark -
- (void)testData
{
    LCTodo* model1 = [LCTodo object];
    model1.title = @"单标题";
    model1.deadline = [[NSDate date] dateByAddingTimeInterval:60 * 30];
    model1.photoImage = [UIImage imageNamed:@"avatar1"];

    LCTodo* model2 = [LCTodo object];
    model2.title = @"标题带描述";
    model2.deadline = [[NSDate date] dateByAddingTimeInterval:60 * 60 * 12];
    model2.photoImage = [UIImage imageNamed:@"avatar2"];
    model2.sgDescription = @"我也是醉求了。。。";

    LCTodo* model3 = [LCTodo object];
    model3.title = @"没有图";
    model3.deadline = [[NSDate date] dateByAddingTimeInterval:60 * 60 * 4];
    model3.sgDescription = @"呵呵呵呵";

    LCTodo* model4 = [LCTodo object];
    model4.title = @"没有图，没有描述";
    model4.deadline = [[NSDate date] dateByAddingTimeInterval:60 * 60 * 24];

    [dataArray addObjectsFromArray:@[ model1, model2, model3, model4 ]];
}
#pragma mark - initial
- (void)viewDidLoad
{
    [super viewDidLoad];

    dataArray = [NSMutableArray new];
    [self testData];
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
        [createViewController setCreateViewControllerDidFinishCreate:^(LCTodo* model) {
            __strong typeof(self) strongSelf = weakSelf;
            [strongSelf->dataArray insertObject:model atIndex:0];
            [strongSelf->tableView reloadData];
        }];
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
    LCTodo* model = dataArray[indexPath.row];
    if (!model.cellHeight) {
        model.cellHeight = [self->tableView cellHeightForIndexPath:indexPath model:[LCTodo object] keyPath:@"model" cellClass:[TodoTableViewCell class] contentViewWidth:kScreenWidth];
    }

    return model.cellHeight;
}
- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataArray.count;
}
- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    TodoTableViewCell* cell = [self->tableView dequeueReusableCellWithIdentifier:kTodoIdentifierArray[TodoIdentifierNormal]];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}
- (void)configureCell:(TodoTableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    [cell setModel:dataArray[indexPath.row]];
}
@end
