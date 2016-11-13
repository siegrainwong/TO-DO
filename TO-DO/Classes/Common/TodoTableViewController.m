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
#import "UIScrollView+Extension.h"
#import "UITableView+SDAutoTableViewCellHeight.h"
#import "EmptyDataView.h"

@interface
TodoTableViewController ()
@property(nonatomic, readwrite, assign) TodoTableViewControllerStyle style;

@property(nonatomic, readwrite, strong) HSDatePickerViewController *datePickerViewController;
@property(nonatomic, readwrite, strong) MRTodoDataManager *dataManager;
@property(nonatomic, readwrite, strong) NSMutableDictionary *dataDictionary;
@property(nonatomic, readwrite, strong) NSMutableArray<NSString *> *dateArray;

@property(nonatomic, readwrite, strong) TodoTableViewCell *snoozingCell;

@property(nonatomic, readwrite, strong) NSDate *date;
@end

@implementation TodoTableViewController

#pragma mark - release

- (void)dealloc {
    DDLogWarn(@"%s", __func__);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - initial

+ (instancetype)todoTableViewControllerWithStyle:(TodoTableViewControllerStyle)style {
    TodoTableViewController *controller = [TodoTableViewController new];
    controller.style = style;
    return controller;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _dataDictionary = [NSMutableDictionary new];
    _dateArray = [NSMutableArray new];
    _dataManager = [MRTodoDataManager new];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncDataManagerDidFinishedSyncInOneBatch) name:kFinishedSyncInOneBatchNotification object:nil];
    
    [self setupView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    //Mark: 这里如果把ScrollView的ContentInset设为0的话，TopBounce的效果就没了。。。不过正常情况下如果不设置这个，会留出几个像素的空白出来，所以才会写了这一句代码。
//    [self.tableView ignoreNavigationHeight];
}

- (void)setupView {
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.sectionHeaderHeight = _style == TodoTableViewControllerStyleWithoutSection ? 0 : 15;
    [self.tableView registerClass:[TodoTableViewCell class] forCellReuseIdentifier:kTodoIdentifierArray[TodoIdentifierNormal]];
    self.tableView.separatorInset = UIEdgeInsetsMake(0, kScreenHeight * kCellHorizontalInsetsMuiltipledByHeight, 0, kScreenHeight * kCellHorizontalInsetsMuiltipledByHeight);
}

#pragma mark - retrieve data

- (void)retrieveDataWithUser:(CDUser *)user date:(NSDate *)date {
    _date = date;
    __weak typeof(self) weakSelf = self;
    [_dataManager retrieveDataWithUser:user date:date complete:^(bool succeed, NSDictionary *data, NSInteger count) {
        weakSelf.dataDictionary = [NSMutableDictionary dictionaryWithDictionary:data];
        weakSelf.dataCount = count;
        [weakSelf reloadDataWithArrayNeedsToReorder:nil];
        [weakSelf setupTimer];
    }];
}

#pragma mark - reloadData

- (void)reloadDataWithArrayNeedsToReorder:(NSMutableArray *)array {
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"self.deadline.timeIntervalSince1970" ascending:YES];
    [array sortUsingDescriptors:@[sort]];
    
    NSArray *dateArrayOrder = [_dataDictionary.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSString *dateString1, NSString *dateString2) {
        NSString *format = @"yyyy-MM-dd";
        NSNumber *interval1 = @([DateUtil stringToDate:dateString1 format:format].timeIntervalSince1970);
        NSNumber *interval2 = @([DateUtil stringToDate:dateString2 format:format].timeIntervalSince1970);
        return [interval1 compare:interval2];
    }];
    _dateArray = [NSMutableArray arrayWithArray:dateArrayOrder];
    [self didReloadData];
    [self.tableView reloadData];
}

- (void)removeEmptySection:(NSString *)dateString {
    NSMutableArray<CDTodo *> *array = _dataDictionary[dateString];
    if (!array.count) {
        [_dataDictionary removeObjectForKey:dateString];
        NSInteger index = [_dateArray indexOfObject:dateString];
        [_dateArray removeObject:dateString];
        
        if (_style != TodoTableViewControllerStyleWithoutSection) [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:index] withRowAnimation:UITableViewRowAnimationLeft];
    }
}

- (void)didReloadData {
    if ([_delegate respondsToSelector:@selector(todoTableViewControllerDidReloadData)]) [_delegate todoTableViewControllerDidReloadData];
    if (!self.dataCount) {
        EmptyDataView *emptyDataView = [[EmptyDataView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, kScreenHeight - self.headerHeight)];
        self.tableView.backgroundColor = self.tableView.tableHeaderView.backgroundColor = [SGHelper themeColorLightGray];
        self.tableView.tableFooterView = emptyDataView;
    } else {
        self.tableView.tableFooterView = nil;
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _dateArray.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    TodoHeaderCell *header = [TodoHeaderCell headerCell];
    header.text = _dateArray[section];
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
}

#pragma mark - swipe left cell events

- (void)setupCellEvents:(TodoTableViewCell *)cell {
    __weak typeof(self) weakSelf = self;
    if (!cell.todoDidComplete) {
        [cell setTodoDidComplete:^BOOL(TodoTableViewCell *sender) {
            [sender setUserInteractionEnabled:NO];
            sender.model.isCompleted = @(YES);
            if ([weakSelf.dataManager isModifiedTodo:sender.model])
                [weakSelf removeTodo:sender.model atIndexPath:[weakSelf.tableView indexPathForCell:sender] reordering:NO animate:YES];
            
            [sender setUserInteractionEnabled:YES];
            return NO;
        }];
    }
    if (!cell.todoDidSnooze) {
        [cell setTodoDidSnooze:^BOOL(TodoTableViewCell *sender) {
            weakSelf.snoozingCell = sender;
            [weakSelf showDatetimePicker:sender.model.deadline];
            return YES;
        }];
    }
    if (!cell.todoDidRemove) {
        [cell setTodoDidRemove:^BOOL(TodoTableViewCell *sender) {
            [sender setUserInteractionEnabled:NO];
            sender.model.isHidden = @(YES);
            if ([weakSelf.dataManager isModifiedTodo:sender.model])
                [weakSelf removeTodo:sender.model atIndexPath:[weakSelf.tableView indexPathForCell:sender] reordering:NO animate:YES];
            
            [sender setUserInteractionEnabled:YES];
            return YES;
        }];
    }
}

- (NSArray<CDTodo *> *)dataArrayAtSection:(NSInteger)section {
    return _dataDictionary[_dateArray[section]];
}

- (CDTodo *)modelAtIndexPath:(NSIndexPath *)indexPath {
    NSArray<CDTodo *> *dataArray = [self dataArrayAtSection:indexPath.section];
    return dataArray[indexPath.row];
}

- (void)configureCell:(TodoTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    CDTodo *model = [self modelAtIndexPath:indexPath];
    [self setupCellEvents:cell];
    cell.model = model;
}

#pragma mark - tableview helper

- (void)removeTodo:(CDTodo *)model atIndexPath:(NSIndexPath *)indexPath reordering:(BOOL)reordering animate:(BOOL)animate {
    // FIXME: 多次请求可能会异常
    NSString *deadline = reordering ? model.lastDeadline.stringInYearMonthDay : model.deadline.stringInYearMonthDay;
    NSMutableArray<CDTodo *> *array = _dataDictionary[deadline];
    [array removeObject:model];
    
    [UIView setAnimationsEnabled:animate];
    if (!array.count) {
        [self removeEmptySection:deadline];
    } else {
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
    [UIView setAnimationsEnabled:YES];
    
    _dataCount--;
    // Mark:光用 deleteRows 方法删除该 Section 最后一行时，上一行会冒出一条迷の分割线，所以必须 reloadData
    [self reloadDataWithArrayNeedsToReorder:nil];
}

- (void)insertTodo:(CDTodo *)model {
    // [self reorderTodo:model];
    NSString *deadline = model.deadline.stringInYearMonthDay;
    NSMutableArray<CDTodo *> *array = _dataDictionary[deadline];
    if (!array) array = _dataDictionary[deadline] = [NSMutableArray new];
    if (![_dateArray containsObject:deadline]) [_dateArray addObject:deadline];
    
    _dataCount++;
    [array addObject:model];
    
    [self reloadDataWithArrayNeedsToReorder:array];
}

- (void)reorderTodo:(CDTodo *)model atIndexPath:(NSIndexPath *)indexPath {
    [self removeTodo:model atIndexPath:indexPath reordering:YES animate:NO];
    
    NSString *deadline = model.deadline.stringInYearMonthDay;
    // 日历视图中，如果不是同一天的话，删掉就可以返回了
    if (_style == TodoTableViewControllerStyleWithoutSection && ![model.lastDeadline.stringInYearMonthDay isEqualToString:deadline]) return;
    
    [self insertTodo:model];
}

#pragma mark - date time picker delegate

- (void)showDatetimePicker:(NSDate *)deadline {
    // Mark: 这个库有Bug，每次必须重新初始化才能正确选择时间
    _datePickerViewController = [HSDatePickerViewController new];
    [_datePickerViewController configure];
    _datePickerViewController.delegate = self;
    _datePickerViewController.minDate = [[NSDate date] dateByAddingTimeInterval:-60];
    [_datePickerViewController setDate:deadline];
    
    [self presentViewController:_datePickerViewController animated:YES completion:nil];
}

- (BOOL)hsDatePickerPickedDate:(NSDate *)date {
    if ([date compare:_datePickerViewController.minDate] == NSOrderedAscending) date = [NSDate date];
    
    __weak typeof(self) weakSelf = self;
    CDTodo *todo = _snoozingCell.model;
    todo.lastDeadline = todo.deadline;
    todo.deadline = date;
    // 时间推迟了才算你Snoozed
    if ([todo.lastDeadline compare:todo.deadline] == NSOrderedAscending)
        todo.status = @(TodoStatusSnoozed);
    [_snoozingCell setUserInteractionEnabled:NO];
    if ([_dataManager isModifiedTodo:todo])
        [weakSelf reorderTodo:todo atIndexPath:[self.tableView indexPathForCell:weakSelf.snoozingCell]];
    
    [weakSelf.snoozingCell setUserInteractionEnabled:YES];
    weakSelf.snoozingCell = nil;
    
    return YES;
}

#pragma mark - timer to overdue

- (void)setupTimer {
    if (_timer.valid) return;
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(expireTasksWhenTimerTick) userInfo:nil repeats:YES];
}

- (void)expireTasksWhenTimerTick {
    __weak typeof(self) weakSelf = self;
    dispatch_queue_t serialQueue = dispatch_queue_create("TodoExpireTasksLock", DISPATCH_QUEUE_SERIAL);
    dispatch_sync(serialQueue, ^{
        NSDate *today = [NSDate date].dateInYearMonthDay;
        BOOL needsToReload = NO;
        for (NSString *dateString in weakSelf.dateArray) {
            NSDate *date = [DateUtil stringToDate:dateString format:@"yyyy-MM-dd"];
            // 只需要遍历今天及今天以前的任务
            if ([date compare:today] == NSOrderedDescending) continue;
            
            NSArray<CDTodo *> *array = weakSelf.dataDictionary[dateString];
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

#pragma mark - reload data when sync finished

- (void)syncDataManagerDidFinishedSyncInOneBatch {
    [self retrieveDataWithUser:[AppDelegate globalDelegate].cdUser date:_date];
}

#pragma mark - scrollView

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([_delegate respondsToSelector:@selector(todoTableViewDidScrollToY:)]) [_delegate todoTableViewDidScrollToY:scrollView.contentOffset.y];
}
@end
