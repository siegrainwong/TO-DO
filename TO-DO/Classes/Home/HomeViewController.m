//
//  HomeViewController.m
//  TO-DO
//
//  Created by Siegrain on 16/5/13.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "CreateViewController.h"
#import "DateUtil.h"
#import "HSDatePickerViewController+Configure.h"
#import "HomeViewController.h"
#import "LCTodo.h"
#import "Macros.h"
#import "NSDate+Extension.h"
#import "TodoDataManager.h"
#import "TodoHeaderCell.h"
#import "TodoTableViewCell.h"
#import "UIButton+WebCache.h"
#import "UIImage+Extension.h"
#import "UIImage+Qiniu.h"
#import "UINavigationController+Transparent.h"
#import "UIScrollView+Extension.h"
#import "UITableView+Extension.h"
#import "UITableView+SDAutoTableViewCellHeight.h"

// TODO: 滚动到一定高度后需要修改导航栏颜色为不透明，同样需要调整状态栏字体颜色
// TODO: 搜索功能
// TODO: 待办事项展开功能
// TODO: 又尼玛不能释放内存了
// TODO: 空数据时展示的界面
// Mark: 再不能全局变量都用成员变量了，内存释放太操心

@interface
HomeViewController ()
@property (nonatomic, readwrite, strong) HSDatePickerViewController* datePickerViewController;
@property (nonatomic, readwrite, strong) TodoDataManager* dataManager;
@property (nonatomic, readwrite, strong) UITableView* tableView;
@property (nonatomic, readwrite, strong) NSMutableDictionary* dataDictionary;
@property (nonatomic, readwrite, strong) NSMutableArray<NSString*>* dateArray;

@property (nonatomic, readwrite, strong) NSTimer* timer;
@property (nonatomic, readwrite, assign) NSInteger dataCount;
@property (nonatomic, readwrite, strong) TodoTableViewCell* snoozingCell;
@end

@implementation HomeViewController
#pragma mark - localization
- (void)localizeStrings
{
    self.headerView.titleLabel.text = [NSString stringWithFormat:@"%ld %@", (long)_dataCount, NSLocalizedString(@"Tasks", nil)];
}
#pragma mark - initial
- (void)viewDidLoad
{
    [super viewDidLoad];

    _dataDictionary = [NSMutableDictionary new];
    _dateArray = [NSMutableArray new];
    _dataManager = [TodoDataManager new];

    [self localizeStrings];
    [self retrieveDataFromServer];
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

    self.headerView = [HeaderView headerViewWithAvatarPosition:HeaderAvatarPositionCenter titleAlignement:HeaderTitleAlignementCenter];
    self.headerView.subtitleLabel.text = [TodoHelper localizedFormatDate:[NSDate date]];
    [self.headerView.rightOperationButton setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    [self.headerView.avatarButton sd_setImageWithURL:GetPictureUrl(super.user.avatar, kQiniuImageStyleSmall) forState:UIControlStateNormal];
    self.headerView.backgroundImageView.image = [UIImage imageAtResourcePath:@"header bg"];
    [self.headerView setHeaderViewDidPressAvatarButton:^{ [LCUser logOut]; }];
    __weak typeof(self) weakSelf = self;
    [self.headerView setHeaderViewDidPressRightOperationButton:^{
        weakSelf.releaseWhileDisappear = NO;
        CreateViewController* createViewController = [[CreateViewController alloc] init];
        [createViewController setCreateViewControllerDidFinishCreate:^(LCTodo* model) {
            model.photoImage = [model.photoImage imageAddCornerWithRadius:model.photoImage.size.width / 2 andSize:model.photoImage.size];
            [weakSelf insertTodo:model];
        }];
        [createViewController setCreateViewControllerDidDisappear:^{
            weakSelf.releaseWhileDisappear = YES;
        }];
        [weakSelf.navigationController pushViewController:createViewController animated:YES];
    }];
    _tableView.tableHeaderView = self.headerView;

    _datePickerViewController = [HSDatePickerViewController new];
    [_datePickerViewController configure];
    _datePickerViewController.delegate = self;
}
- (void)bindConstraints
{
    [super bindConstraints];

    [_tableView mas_makeConstraints:^(MASConstraintMaker* make) {
        make.top.bottom.right.left.offset(0);
    }];

    [self.headerView mas_makeConstraints:^(MASConstraintMaker* make) {
        make.top.left.offset(0);
        make.width.offset(kScreenWidth);
        make.height.offset(kScreenHeight * 0.6);
    }];
}
#pragma mark - retreive data
- (void)retrieveDataFromServer
{
    __weak typeof(self) weakSelf = self;
    [_dataManager retrieveDataWithUser:self.user date:nil complete:^(bool succeed, NSDictionary* data, NSInteger count) {
        weakSelf.dataDictionary = [NSMutableDictionary dictionaryWithDictionary:data];
        weakSelf.dataCount = count;
        [weakSelf reloadData];
        [weakSelf setupTimer];
    }];
}
#pragma mark - reloadData
- (void)reloadData
{
    NSArray* dateArrayOrder = [_dataDictionary.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSString* dateString1, NSString* dateString2) {
        NSString* format = @"yyyy-MM-dd";
        NSNumber* interval1 = @([DateUtil stringToDate:dateString1 format:format].timeIntervalSince1970);
        NSNumber* interval2 = @([DateUtil stringToDate:dateString2 format:format].timeIntervalSince1970);
        return [interval1 compare:interval2];
    }];
    _dateArray = [NSMutableArray arrayWithArray:dateArrayOrder];
    [self localizeStrings];
    [_tableView reloadData];
}
- (void)removeEmptySection:(NSString*)dateString
{
    NSMutableArray<LCTodo*>* array = _dataDictionary[dateString];
    if (!array.count) {
        [_dataDictionary removeObjectForKey:dateString];
        NSInteger index = [_dateArray indexOfObject:dateString];
        [_dateArray removeObject:dateString];
        [_tableView deleteSections:[NSIndexSet indexSetWithIndex:index] withRowAnimation:UITableViewRowAnimationLeft];
    }
}
#pragma mark - tableview
#pragma mark - tableview delegate
- (CGFloat)tableView:(UITableView*)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return [self tableView:self->_tableView heightForRowAtIndexPath:indexPath];
}
- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    LCTodo* model = [self modelAtIndexPath:indexPath];
    if (!model.cellHeight) {
        model.cellHeight = [tableView cellHeightForIndexPath:indexPath model:model keyPath:@"model" cellClass:[TodoTableViewCell class] contentViewWidth:kScreenWidth];
    }

    return model.cellHeight;
}
#pragma mark - tableview datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return _dateArray.count;
}
- (UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    TodoHeaderCell* header = [TodoHeaderCell headerCell];
    header.text = _dateArray[section];
    return header;
}
- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self dataArrayAtSection:section].count;
}
- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    TodoTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kTodoIdentifierArray[TodoIdentifierNormal] forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}
#pragma mark - swipe left cell events
- (void)setupCellEvents:(TodoTableViewCell*)cell
{
    __weak typeof(self) weakSelf = self;
    if (!cell.todoDidComplete) {
        [cell setTodoDidComplete:^BOOL(TodoTableViewCell* sender) {
            [sender setUserInteractionEnabled:NO];
            sender.model.isCompleted = YES;
            [weakSelf.dataManager modifyTodo:sender.model complete:^(bool succeed) {
                [sender setUserInteractionEnabled:YES];
                if (succeed) [weakSelf removeTodo:sender.model atIndexPath:[weakSelf.tableView indexPathForCell:sender]];
            }];
            return NO;
        }];
    }
    if (!cell.todoDidSnooze) {
        [cell setTodoDidSnooze:^BOOL(TodoTableViewCell* sender) {
            [sender setUserInteractionEnabled:NO];
            weakSelf.snoozingCell = sender;
            [weakSelf showDatetimePicker:sender.model.deadline];
            return YES;
        }];
    }
    if (!cell.todoDidRemove) {
        [cell setTodoDidRemove:^BOOL(TodoTableViewCell* sender) {
            [sender setUserInteractionEnabled:NO];
            sender.model.isDeleted = YES;
            [weakSelf.dataManager modifyTodo:sender.model complete:^(bool succeed) {
                [sender setUserInteractionEnabled:YES];
                if (succeed) [weakSelf removeTodo:sender.model atIndexPath:[weakSelf.tableView indexPathForCell:sender]];
            }];
            return YES;
        }];
    }
}
#pragma mark - tableview helper
- (NSArray<LCTodo*>*)dataArrayAtSection:(NSInteger)section
{
    return _dataDictionary[_dateArray[section]];
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
    // FIXME: 多次请求会异常
    NSString* deadline = model.deadline.stringInYearMonthDay;
    NSMutableArray<LCTodo*>* array = _dataDictionary[deadline];
    [array removeObject:model];

    if (!array.count) {
        [self removeEmptySection:deadline];
    } else {
        [_tableView deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationLeft];
    }

    _dataCount--;
    // Mark:光用 deleteRows 方法删除该 Section 最后一行时，上一行会冒出一条迷の分割线，所以必须 reloadData
    [self reloadData];
}
- (void)insertTodo:(LCTodo*)model
{
    [self reorderTodo:model];
}
- (void)reorderTodo:(LCTodo*)model
{
    NSString* deadline = model.deadline.stringInYearMonthDay;

    NSMutableArray<LCTodo*>* array = _dataDictionary[deadline];
    if (!array) array = _dataDictionary[deadline] = [NSMutableArray new];
    if (![_dateArray containsObject:deadline]) [_dateArray addObject:deadline];

    // 检查是否是同一天，是同一天只需要重新排序即可
    // 不是则需要移除当前位置的 cell，加到另一个 section 中
    if (model.lastDeadline && ![model.lastDeadline.stringInYearMonthDay isEqualToString:deadline]) {
        NSString* lastDeadline = model.lastDeadline.stringInYearMonthDay;
        NSMutableArray<LCTodo*>* lastDateArray = _dataDictionary[lastDeadline];
        [lastDateArray removeObject:model];

        [self removeEmptySection:lastDeadline];
        // Mark: 必须在 remove sections 后再添加到数据源中，不然 remove 时会报错，即使该数据源不在原来的位置上..
        [array addObject:model];
    } else if (!model.lastDeadline) {
        _dataCount++;
        [array addObject:model];
    }

    NSSortDescriptor* sort = [NSSortDescriptor sortDescriptorWithKey:@"self.deadline.timeIntervalSince1970" ascending:YES];
    [array sortUsingDescriptors:@[ sort ]];

    [self reloadData];
}
#pragma mark - date time picker delegate
- (void)showDatetimePicker:(NSDate*)deadline
{
    super.releaseWhileDisappear = NO;

    _datePickerViewController.minDate = [[NSDate date] dateByAddingTimeInterval:-60];
    if ([deadline timeIntervalSince1970] > [_datePickerViewController.minDate timeIntervalSince1970])
        _datePickerViewController.minDate = deadline;

    [self presentViewController:_datePickerViewController animated:YES completion:nil];
}
- (BOOL)hsDatePickerPickedDate:(NSDate*)date
{
    super.releaseWhileDisappear = YES;

    if ([date timeIntervalSince1970] < [_datePickerViewController.minDate timeIntervalSince1970])
        date = [NSDate date];

    __weak typeof(self) weakSelf = self;
    LCTodo* todo = _snoozingCell.model;
    todo.lastDeadline = todo.deadline;
    todo.deadline = date;
    todo.status = LCTodoStatusSnoozed;
    [_dataManager modifyTodo:todo complete:^(bool succeed) {
        [weakSelf.snoozingCell setUserInteractionEnabled:YES];
        weakSelf.snoozingCell = nil;
        if (succeed)
            [weakSelf reorderTodo:todo];
    }];

    return YES;
}
#pragma mark - scrollview
#pragma mark - timer to overdue
- (void)setupTimer
{
    if (_timer.valid) return;

    _timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(expireTasksWhenTimerTick) userInfo:nil repeats:YES];
}
- (void)expireTasksWhenTimerTick
{
    NSDate* today = [NSDate date].dateInYearMonthDay;
    for (NSString* dateString in _dateArray) {
        NSDate* date = [DateUtil stringToDate:dateString format:@"yyyy-MM-dd"];
        // 只需要遍历今天及今天以前的任务
        if ([date compare:today] == NSOrderedDescending) continue;

        NSArray<LCTodo*>* array = _dataDictionary[dateString];
        for (LCTodo* todo in array) {
            if ([todo.deadline compare:[NSDate date]] == NSOrderedAscending) todo.status = LCTodoStatusOverdue;
        }
    }
}
#pragma mark - release
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    if (!super.releaseWhileDisappear) return;

    [_tableView removeFromSuperview];
    _tableView = nil;

    [self.view removeFromSuperview];
    self.view = nil;
    [self removeFromParentViewController];
}
- (void)dealloc
{
    NSLog(@"%s", __func__);
}
@end
