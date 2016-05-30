//
//  CalendarViewController.m
//  TO-DO
//
//  Created by Siegrain on 16/5/30.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "CalendarViewController.h"
#import "CreateViewController.h"
#import "DateUtil.h"
#import "HSDatePickerViewController+Configure.h"
#import "HomeDataManager.h"
#import "HomeViewController.h"
#import "LCTodo.h"
#import "Macros.h"
#import "NSDate+Extension.h"
#import "TodoHeaderCell.h"
#import "TodoTableViewCell.h"
#import "UIButton+WebCache.h"
#import "UIImage+Extension.h"
#import "UIImage+Qiniu.h"
#import "UINavigationController+Transparent.h"
#import "UIScrollView+Extension.h"
#import "UITableView+Extension.h"
#import "UITableView+SDAutoTableViewCellHeight.h"

@implementation CalendarViewController {
    //	CalendarDataManager* dataManager;
    UITableView* tableView;
}
#pragma mark - initial
- (void)viewDidLoad
{
    [super viewDidLoad];

    //	dataDictionary = [NSMutableDictionary new];
    //	dateArray = [NSMutableArray new];
    //	dataManager = [HomeDataManager new];

    //    [self localizeStrings];
    //	[self retrieveDataFromServer];
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

    tableView = [UITableView new];
    tableView.bounces = NO;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.showsHorizontalScrollIndicator = NO;
    tableView.showsVerticalScrollIndicator = NO;
    tableView.sectionHeaderHeight = 15;
    [tableView registerClass:[TodoTableViewCell class] forCellReuseIdentifier:kTodoIdentifierArray[TodoIdentifierNormal]];
    tableView.separatorInset = UIEdgeInsetsMake(0, kScreenHeight * kCellHorizontalInsetsMuiltipledByHeight, 0, kScreenHeight * kCellHorizontalInsetsMuiltipledByHeight);
    [self.view addSubview:tableView];

    headerView = [HeaderView headerViewWithAvatarPosition:HeaderAvatarPositionCenter titleAlignement:HeaderTitleAlignementCenter];
    [headerView.avatarButton setHidden:YES];
    headerView.subtitleLabel.text = [TodoHelper localizedFormatDate:[NSDate date]];
    [headerView.rightOperationButton setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    headerView.backgroundImageView.image = [UIImage imageAtResourcePath:@"calendar header bg"];
    __weak typeof(self) weakSelf = self;
    [headerView setHeaderViewDidPressRightOperationButton:^{
        CreateViewController* createViewController = [[CreateViewController alloc] init];
        //        [createViewController setCreateViewControllerDidFinishCreate:^(LCTodo* model) {
        //            model.photoImage = [model.photoImage imageAddCornerWithRadius:model.photoImage.size.width / 2 andSize:model.photoImage.size];
        //            [weakSelf insertTodo:model];
        //        }];
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
        make.height.offset(kScreenHeight * 0.7);
    }];
}
#pragma mark - tableview
#pragma mark - tableview datasource
- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}
- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return [UITableViewCell new];
}
@end
