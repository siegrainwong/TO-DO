//
//  TodoTableViewController.m
//  TO-DO
//
//  Created by Siegrain on 16/5/31.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "AppDelegate.h"
#import "CDTodo.h"
#import "DateUtil.h"
#import "HSDatePickerViewController+Configure.h"
#import "HomeViewController.h"
#import "MRTodoDataManager.h"
#import "NSDate+Extension.h"
#import "TodoHeaderCell.h"
#import "TodoTableViewCell.h"
#import "UITableView+SDAutoTableViewCellHeight.h"
#import "EmptyDataView.h"
#import "ZFModalTransitionAnimator.h"
#import "DetailViewController.h"

@interface
TodoTableViewController ()

@property(nonatomic, strong) HSDatePickerViewController *datePickerViewController;
@property(nonatomic, strong) MRTodoDataManager *dataManager;
@property(nonatomic, strong) NSMutableDictionary *dataDictionary;
@property(nonatomic, strong) NSMutableArray<NSString *> *sectionArray;

@property(nonatomic, strong) TodoTableViewCell *snoozingCell;

@property(nonatomic, strong) NSDate *date;
@property(nonatomic, strong) NSTimer *timer;

@property(nonatomic, strong) ZFModalTransitionAnimator *animator;
@end

@implementation TodoTableViewController

#pragma mark - release

- (void)dealloc {
    DDLogWarn(@"%s", __func__);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [_timer invalidate];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self setupTimer];
}

#pragma mark - initial

- (void)viewDidLoad {
    _dataDictionary = [NSMutableDictionary new];
    _sectionArray = [NSMutableArray new];
    _dataManager = [MRTodoDataManager new];
    
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(retrieveData) name:kFinishedSyncInOneBatchNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(retrieveData) name:kTaskChangedNotification object:nil];
}

- (void)setupViews {
    [super setupViews];
    
    [self.tableView registerClass:[TodoTableViewCell class] forCellReuseIdentifier:kTodoIdentifierArray[TodoIdentifierNormal]];
    [self setSeparatorInsetZeroWithTableView:self.tableView];
//    self.tableView.separatorInset = UIEdgeInsetsMake(0, kScreenHeight * kCellHorizontalInsetsMuiltipledByHeight, 0, kScreenHeight * kCellHorizontalInsetsMuiltipledByHeight);
}

#pragma mark - retrieve data

- (void)retrieveDataWithUser:(CDUser *)user date:(NSDate *)date {
    _date = date;
    __weak typeof(self) weakSelf = self;
    if (_style == TodoTableViewControllerStyleHome) {
        [_dataManager retrieveDataWithUser:user date:date complete:^(BOOL succeed, NSDictionary *data, NSInteger count) {
            weakSelf.dataDictionary = [NSMutableDictionary dictionaryWithDictionary:data];
            weakSelf.dataCount = count;
            [weakSelf reloadDataWithArrayNeedsToReorder:nil];
            [weakSelf setupTimer];
        }];
    } else if (_style == TodoTableViewControllerStyleCalendar) {
        [_dataManager retrieveCalendarDataWithUser:user date:date complete:^(BOOL succeed, NSDictionary *data, NSInteger count) {
            weakSelf.dataDictionary = [NSMutableDictionary dictionaryWithDictionary:data];
            weakSelf.dataCount = count;
            if (count)
                weakSelf.sectionArray = [@[kDataNotCompleteTaskKey, kDataCompletedTaskKey] mutableCopy];
            else
                [weakSelf.sectionArray removeAllObjects];
            
            [weakSelf.tableView reloadData];
            [weakSelf didReloadData];
            [weakSelf setupTimer];
        }];
    }
}

#pragma mark - reloadData

/* 将section按日期重新排序 */
- (void)reloadDataWithArrayNeedsToReorder:(NSMutableArray *)array {
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"self.deadline.timeIntervalSince1970" ascending:YES];
    [array sortUsingDescriptors:@[sort]];
    
    NSArray *dateArrayOrder = [_dataDictionary.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSString *dateString1, NSString *dateString2) {
        NSString *format = @"yyyy-MM-dd";
        NSNumber *interval1 = @([DateUtil stringToDate:dateString1 format:format].timeIntervalSince1970);
        NSNumber *interval2 = @([DateUtil stringToDate:dateString2 format:format].timeIntervalSince1970);
        return [interval1 compare:interval2];
    }];
    _sectionArray = [NSMutableArray arrayWithArray:dateArrayOrder];
    [self didReloadData];
    [self.tableView reloadData];
}

- (void)didReloadData {
    if ([_delegate respondsToSelector:@selector(todoTableViewControllerDidReloadData)]) [_delegate todoTableViewControllerDidReloadData];
    if (!_dataCount) {
        EmptyDataView *emptyDataView = [[EmptyDataView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, kScreenHeight - self.headerHeight)];
        self.tableView.backgroundColor = self.tableView.tableHeaderView.backgroundColor = [SGHelper themeColorLightGray];
        self.tableView.tableFooterView = emptyDataView;
    } else {
        self.tableView.tableFooterView = [UIView new];
        self.tableView.backgroundColor = self.tableView.tableHeaderView.backgroundColor = [UIColor whiteColor];
    }
}

#pragma mark - TableView

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CDTodo *model = [self modelAtIndexPath:indexPath];
    if (!model.cellHeight) model.cellHeight = [tableView cellHeightForIndexPath:indexPath model:model keyPath:@"model" cellClass:[TodoTableViewCell class] contentViewWidth:kScreenWidth];
    
    return model.cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (!section && _style == TodoTableViewControllerStyleCalendar) return 0;
    return 15;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _sectionArray.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    TodoHeaderCell *header = [TodoHeaderCell headerCell];
    header.text = _sectionArray[section];
    return header;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self dataArrayAtSection:section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TodoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTodoIdentifierArray[TodoIdentifierNormal] forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CDTodo *model = [self modelAtIndexPath:indexPath];
    
    DetailViewController *detailViewController = [DetailViewController new];
    [detailViewController setModel:model];
    
    self.animator = [[ZFModalTransitionAnimator alloc] initWithModalViewController:detailViewController];
    self.animator.dragable = YES;
    self.animator.direction = ZFModalTransitonDirectionBottom;
    self.animator.transitionDuration = .3;
    self.animator.behindViewAlpha = .8;
    self.animator.behindViewScale = 1;
    [self.animator setContentScrollView:detailViewController.tableView];
    detailViewController.transitioningDelegate = self.animator;
    detailViewController.modalPresentationStyle = UIModalPresentationCustom;
    
    [self presentViewController:detailViewController animated:YES completion:nil];
}

- (NSArray<CDTodo *> *)dataArrayAtSection:(NSInteger)section {
    return _dataDictionary[_sectionArray[section]];
}

- (CDTodo *)modelAtIndexPath:(NSIndexPath *)indexPath {
    NSArray<CDTodo *> *dataArray = [self dataArrayAtSection:indexPath.section];
    return dataArray[indexPath.row];
}

- (void)configureCell:(TodoTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    CDTodo *model = [self modelAtIndexPath:indexPath];
    cell.model = model;
    if (_style == TodoTableViewControllerStyleCalendar && indexPath.section == 1) return;   //已完成的任务暂时不需要滑动操作
    [self setupCellEvents:cell];
}

#pragma mark - swipe left cell events

- (void)setupCellEvents:(TodoTableViewCell *)cell {
    __weak typeof(self) weakSelf = self;
    if (cell.todoDidSwipe) return;
    
    [cell setTodoDidSwipe:^BOOL(TodoTableViewCell *sender, TodoSwipeOperation operation) {
        CDTodo *model = sender.model;
        if (operation == TodoSwipeOperationComplete) {
            model.isCompleted = @(YES);
            model.completedAt = [NSDate date];
            [weakSelf saveWithTask:model];
            
            return YES;
        } else if (operation == TodoSwipeOperationSnooze) {
            weakSelf.snoozingCell = sender;
            [weakSelf showDatetimePicker:[[NSDate date] dateByAddingTimeInterval:-60]];
            
            return NO;
        } else if (operation == TodoSwipeOperationRemove) {
            model.isHidden = @(YES);
            model.deletedAt = [NSDate date];
            [weakSelf saveWithTask:model];
            
            return YES;
        } else if (operation == TodoSwipeOperationRevert) {
            
        }
        return YES;
    }];
}

#pragma mark - date time picker delegate

- (void)showDatetimePicker:(NSDate *)deadline {
    // Mark: 这个库有Bug，每次必须重新初始化才能正确选择时间
    _datePickerViewController = [HSDatePickerViewController new];
    _datePickerViewController.delegate = self;
    [_datePickerViewController configure];
    [_datePickerViewController setDate:deadline];
    
    [self presentViewController:_datePickerViewController animated:YES completion:nil];
}

- (BOOL)hsDatePickerPickedDate:(NSDate *)date {
    CDTodo *model = _snoozingCell.model;
    if ([model.deadline compare:date] == NSOrderedAscending) model.status = @(TodoStatusSnoozed);   // 时间推迟了才算你Snoozed
    model.deadline = date;
    
    [self saveWithTask:model];
    [_snoozingCell hideSwipeAnimated:YES];
    _snoozingCell = nil;
    
    return YES;
}

- (void)hsDatePickerDidDismissWithQuitMethod:(HSDatePickerQuitMethod)method {
    [self.snoozingCell hideSwipeAnimated:YES];
    self.snoozingCell = nil;
}

#pragma mark - private methods

- (void)saveWithTask:(CDTodo *)model {
    if ([_dataManager isModifiedTodo:model]) [self retrieveData];
}

- (void)retrieveData {
    [self retrieveDataWithUser:[AppDelegate globalDelegate].cdUser date:_date];
}

#pragma mark - overdue tasks with timer

- (void)setupTimer {
    if (_timer.valid) return;
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(checkTaskDeadline) userInfo:nil repeats:YES];
}

- (void)checkTaskDeadline {
    __weak typeof(self) weakSelf = self;
    dispatch_queue_t serialQueue = dispatch_queue_create("TodoExpireTasksLock", DISPATCH_QUEUE_SERIAL);
    dispatch_sync(serialQueue, ^{
        NSDate *today = [NSDate date].dateInYearMonthDay;
        BOOL needsToReload = NO;
        for (NSString *sectionTitle in weakSelf.sectionArray) {
            if (_style == TodoTableViewControllerStyleHome) { // 首页中只需要遍历今天及今天以前的任务
                NSDate *date = [DateUtil stringToDate:sectionTitle format:@"yyyy-MM-dd"];
                if ([date compare:today] == NSOrderedDescending) continue;
            } else if (_style == TodoTableViewControllerStyleCalendar) {  // 日历页面只需要遍历未完成的任务
                if ([sectionTitle isEqualToString:kDataCompletedTaskKey]) continue;
            }
            
            NSArray<CDTodo *> *array = weakSelf.dataDictionary[sectionTitle];
            for (CDTodo *todo in array) {
                if ([todo.status integerValue] != TodoStatusOverdue && [todo.deadline compare:[NSDate date]] == NSOrderedAscending) {
                    todo.status = @(TodoStatusOverdue);
                    [weakSelf.dataManager isModifiedTodo:todo];
                    needsToReload = YES;
                }
            }
        }
        
        if (needsToReload) [self.tableView reloadData];
    });
}

#pragma mark - scrollView

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([_delegate respondsToSelector:@selector(todoTableViewDidScrollToY:)]) [_delegate todoTableViewDidScrollToY:scrollView.contentOffset.y];
}
@end
