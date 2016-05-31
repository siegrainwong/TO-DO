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
    //	CalendarDataManager* _dataManager;
    UITableView* _tableView;
}
#pragma mark - initial
- (void)viewDidLoad
{
    [super viewDidLoad];

    //	dataDictionary = [NSMutableDictionary new];
    //	dateArray = [NSMutableArray new];
    //	_dataManager = [HomeDataManager new];

    //    [self localizeStrings];
    //	[self retrieveDataFromServer];
}
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    [_tableView ignoreNavigationHeight];
    [_tableView resizeTableHeaderView];
}
- (void)setupView
{
    [super setupView];

    _tableView = [UITableView new];
    _tableView.bounces = NO;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.sectionHeaderHeight = 15;
    [_tableView registerClass:[TodoTableViewCell class] forCellReuseIdentifier:kTodoIdentifierArray[TodoIdentifierNormal]];
    _tableView.separatorInset = UIEdgeInsetsMake(0, kScreenHeight * kCellHorizontalInsetsMuiltipledByHeight, 0, kScreenHeight * kCellHorizontalInsetsMuiltipledByHeight);
    [self.view addSubview:_tableView];

    super.headerView = [HeaderView headerViewWithAvatarPosition:HeaderAvatarPositionCenter titleAlignement:HeaderTitleAlignementCenter];
    [super.headerView.avatarButton setHidden:YES];
    super.headerView.subtitleLabel.text = [TodoHelper localizedFormatDate:[NSDate date]];
    [super.headerView.rightOperationButton setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    super.headerView.backgroundImageView.image = [UIImage imageAtResourcePath:@"calendar header bg"];
    __weak typeof(self) weakSelf = self;
    [super.headerView setHeaderViewDidPressRightOperationButton:^{
        CreateViewController* createViewController = [[CreateViewController alloc] init];
        //        [createViewController setCreateViewControllerDidFinishCreate:^(LCTodo* model) {
        //            model.photoImage = [model.photoImage imageAddCornerWithRadius:model.photoImage.size.width / 2 andSize:model.photoImage.size];
        //            [weakSelf insertTodo:model];
        //        }];
        [weakSelf.navigationController pushViewController:createViewController animated:YES];
    }];
    _tableView.tableHeaderView = super.headerView;
}
- (void)bindConstraints
{
    [super bindConstraints];

    [_tableView mas_makeConstraints:^(MASConstraintMaker* make) {
        make.top.bottom.right.left.offset(0);
    }];

    [super.headerView mas_makeConstraints:^(MASConstraintMaker* make) {
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
