//
//  HomeViewController.m
//  TO-DO
//
//  Created by Siegrain on 16/5/13.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "CreateViewController.h"
#import "DateUtil.h"
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

@implementation HomeViewController {
    HSDatePickerViewController* datePickerViewController;
    HomeDataManager* dataManager;
    UITableView* tableView;
    NSMutableDictionary* dataDictionary;
    NSMutableArray* dateArray;

    NSInteger dataCount;
}
#pragma mark - localization
- (void)localizeStrings
{
    headerView.titleLabel.text = [NSString stringWithFormat:@"%ld %@", dataCount, NSLocalizedString(@"Tasks", nil)];
}
#pragma mark - initial
- (void)viewDidLoad
{
    [super viewDidLoad];

    dataDictionary = [NSMutableDictionary new];
    dateArray = [NSMutableArray new];
    dataManager = [HomeDataManager new];

    [self localizeStrings];
    [self retrieveDataFromServer];
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
    headerView.subtitleLabel.text = [TodoHelper localizedFormatDate:[NSDate date]];
    [headerView.rightOperationButton setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    [headerView.avatarButton sd_setImageWithURL:GetPictureUrl(user.avatar, kQiniuImageStyleSmall) forState:UIControlStateNormal];
    headerView.backgroundImageView.image = [UIImage imageAtResourcePath:@"header bg"];
    [headerView setHeaderViewDidPressAvatarButton:^{ [LCUser logOut]; }];
    __weak typeof(self) weakSelf = self;
    [headerView setHeaderViewDidPressRightOperationButton:^{
        CreateViewController* createViewController = [[CreateViewController alloc] init];
        [createViewController setCreateViewControllerDidFinishCreate:^(LCTodo* model) {
            //            model.photoImage = [model.photoImage imageAddCornerWithRadius:model.photoImage.size.width / 2 andSize:model.photoImage.size];
            [weakSelf insertTodo:model];
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
#pragma mark - retreive data
- (void)retrieveDataFromServer
{
    __weak typeof(self) weakSelf = self;
    [dataManager retrieveDataWithUser:user complete:^(bool succeed, NSDictionary* data, NSInteger count) {
        dataDictionary = [NSMutableDictionary dictionaryWithDictionary:data];
        dataCount = count;
        [weakSelf reloadData];
    }];
}
#pragma mark - reloadData
- (void)reloadData
{
    NSArray* dateArrayOrder = [dataDictionary.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSString* dateString1, NSString* dateString2) {
        NSString* format = @"yyyy-MM-dd";
        NSNumber* interval1 = @([DateUtil stringToDate:dateString1 format:format].timeIntervalSince1970);
        NSNumber* interval2 = @([DateUtil stringToDate:dateString2 format:format].timeIntervalSince1970);
        return [interval1 compare:interval2];
    }];
    dateArray = [NSMutableArray arrayWithArray:dateArrayOrder];
    [self localizeStrings];
    [tableView reloadData];
}
#pragma mark - tableview
#pragma mark - tableview delegate
- (CGFloat)tableView:(UITableView*)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return [self tableView:self->tableView heightForRowAtIndexPath:indexPath];
}
- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    LCTodo* model = [self modelAtIndexPath:indexPath];
    if (!model.cellHeight) {
        model.cellHeight = [self->tableView cellHeightForIndexPath:indexPath model:model keyPath:@"model" cellClass:[TodoTableViewCell class] contentViewWidth:kScreenWidth];
    }

    return model.cellHeight;
}
#pragma mark - tableview datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return dateArray.count;
}
- (UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    TodoHeaderCell* header = [TodoHeaderCell headerCell];
    header.text = dateArray[section];
    return header;
}
- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self dataArrayAtSection:section].count;
}
- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    TodoTableViewCell* cell = [self->tableView dequeueReusableCellWithIdentifier:kTodoIdentifierArray[TodoIdentifierNormal] forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}
#pragma mark - swipe left cell events
- (void)setupCellEvents:(TodoTableViewCell*)cell
{
    __weak typeof(self) weakSelf = self;
    if (!cell.todoDidComplete) {
        [cell setTodoDidComplete:^BOOL(TodoTableViewCell* sender) {
            sender.model.status = LCTodoStatusCompleted;
            [dataManager modifyTodo:sender.model complete:^(bool succeed) {
                if (succeed) [weakSelf removeTodo:sender.model atIndexPath:[tableView indexPathForCell:sender]];
            }];
            return NO;
        }];
    }
    if (!cell.todoDidSnooze) {
        [cell setTodoDidSnooze:^BOOL(TodoTableViewCell* sender) {
            return YES;
        }];
    }
    if (!cell.todoDidRemove) {
        [cell setTodoDidRemove:^BOOL(TodoTableViewCell* sender) {
            sender.model.status = LCTodoStatusDeleted;
            [dataManager modifyTodo:sender.model complete:^(bool succeed) {
                if (succeed) [weakSelf removeTodo:sender.model atIndexPath:[tableView indexPathForCell:sender]];
            }];
            return YES;
        }];
    }
}
#pragma mark - tableview helper
- (NSArray<LCTodo*>*)dataArrayAtSection:(NSInteger)section
{
    return dataDictionary[dateArray[section]];
}
- (LCTodo*)modelAtIndexPath:(NSIndexPath*)indexPath
{
    NSArray<LCTodo*>* dataArray = [self dataArrayAtSection:indexPath.section];
    return dataArray[indexPath.row];
}
- (void)configureCell:(TodoTableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    LCTodo* model = [self modelAtIndexPath:indexPath];
    [self setupCellEvents:cell];
    cell.model = model;
}
- (void)removeTodo:(LCTodo*)model atIndexPath:(NSIndexPath*)indexPath
{
    NSString* date = model.deadline.stringInYearMonthDay;
    NSMutableArray<LCTodo*>* array = dataDictionary[date];
    [array removeObject:model];

    if (!array.count) {
        [dataDictionary removeObjectForKey:date];
        [dateArray removeObject:date];
        [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationLeft];
    } else {
        [tableView deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationLeft];
    }

    dataCount--;
    [self reloadData];
}
- (void)insertTodo:(LCTodo*)model
{
    NSString* dateString = model.deadline.stringInYearMonthDay;
    NSMutableArray<LCTodo*>* array = dataDictionary[dateString];
    if (!array) array = dataDictionary[dateString] = [NSMutableArray new];

    [array addObject:model];
    NSSortDescriptor* sort = [NSSortDescriptor sortDescriptorWithKey:@"self.deadline.timeIntervalSince1970"
                                                           ascending:YES];
    [array sortUsingDescriptors:@[ sort ]];

    if (![dateArray containsObject:dateString])
        [dateArray addObject:dateString];

    dataCount++;
    [self reloadData];
}
#pragma mark - scrollview
@end
