//
// Created by Siegrain on 16/11/21.
// Copyright (c) 2016 com.siegrain. All rights reserved.
//

#import "DetailTableViewController.h"
#import "DetailTableViewCell.h"
#import "CDTodo.h"
#import "DetailModel.h"
#import "DateUtil.h"
#import "UITableView+SDAutoTableViewCellHeight.h"
#import "HSDatePickerViewController+Configure.h"
#import "MRTodoDataManager.h"
#import "RTRootNavigationController.h"
#import "SGTextEditorViewController.h"

typedef NS_ENUM(NSInteger, SGDetailItem) {
    SGDetailItemDeadline,
    SGDetailItemDescription,
    SGDetailItemLocation,
    SGDetailItemPhoto
};

@interface DetailTableViewController () <HSDatePickerViewControllerDelegate>
@property(nonatomic, strong) CDTodo *model;
@property(nonatomic, strong) NSArray<DetailModel *> *dataArray;
@property(nonatomic, assign) CGFloat cellsTotalHeight;

@property(nonatomic, strong) HSDatePickerViewController *datePickerViewController;
@property(nonatomic, strong) MRTodoDataManager *dataManager;
@property(nonatomic, strong) SGTextEditorViewController *editorViewController;
@end

@implementation DetailTableViewController

#pragma mark - lazy load

- (SGTextEditorViewController *)editorViewController {
    if (!_editorViewController) {
        _editorViewController = [SGTextEditorViewController new];
        _editorViewController.title = Localized(@"Description");
        _editorViewController.value = _model.sgDescription;
        __weak __typeof(self) weakSelf = self;
        [_editorViewController setEditorDidSave:^(NSString *value) {
            weakSelf.model.sgDescription = value;
            weakSelf.dataArray[SGDetailItemDescription].content = value;
            weakSelf.dataArray[SGDetailItemDescription].rowHeight = 0;
            [weakSelf save];
        }];
    }
    return _editorViewController;
}


#pragma mark - initial

- (void)setModel:(CDTodo *)model {
    _model = model;
    
    _dataArray = @[
            [DetailModel modelWithIconName:@"watch" content:[DateUtil dateString:model.deadline withFormat:@"yyyy.MM.dd HH:mm"] location:nil photoUrl:nil photoPath:nil placeholder:Localized(@"Deadline") identifier:model.identifier cellStyle:DetailCellStyleText],
            [DetailModel modelWithIconName:@"description" content:model.sgDescription location:nil photoUrl:nil photoPath:nil placeholder:Localized(@"Input description") identifier:model.identifier cellStyle:DetailCellStyleMultiLineText],
            [DetailModel modelWithIconName:@"map" content:model.coordinate.address location:model.coordinate photoUrl:nil photoPath:nil placeholder:Localized(@"Add location") identifier:model.identifier cellStyle:DetailCellStyleMap],
            [DetailModel modelWithIconName:@"camera" content:nil location:nil photoUrl:model.photoUrl photoPath:model.photoPath placeholder:Localized(@"Add a photo") identifier:model.identifier cellStyle:DetailCellStylePhoto],
    ];
}

- (void)setupViews {
    [super setupViews];
    
    self.dataManager = [MRTodoDataManager new];
    [self setSeparatorInsetWithTableView:self.tableView inset:UIEdgeInsetsMake(0, 58, 0, 0)];
    
    [self.tableView registerClass:[DetailTableViewCell class] forCellReuseIdentifier:@(DetailCellStyleMap).stringValue];
    [self.tableView registerClass:[DetailTableViewCell class] forCellReuseIdentifier:@(DetailCellStylePhoto).stringValue];
    [self.tableView registerClass:[DetailTableViewCell class] forCellReuseIdentifier:@(DetailCellStyleText).stringValue];
    [self.tableView registerClass:[DetailTableViewCell class] forCellReuseIdentifier:@(DetailCellStyleMultiLineText).stringValue];
}

#pragma mark - tableview

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    DetailModel *model = [self modelAtIndexPath:indexPath];
    if (!model.rowHeight) model.rowHeight = [self.tableView cellHeightForIndexPath:indexPath model:model keyPath:@"model" cellClass:[DetailTableViewCell class] contentViewWidth:kScreenWidth];
    if (indexPath.row == _dataArray.count - 1 && self.tableViewDidCalculateHeight && !_cellsTotalHeight) {  //如果不进行最后一个判断会无限递归，因为外部layout后tableview也会reload data
        _cellsTotalHeight = self.tableView.cellsTotalHeight;
        self.tableViewDidCalculateHeight(_cellsTotalHeight);
    }
    return model.rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[self identifierAtIndexPath:indexPath] forIndexPath:indexPath];
    cell.model = [self modelAtIndexPath:indexPath];
    return cell;
}

- (DetailModel *)modelAtIndexPath:(NSIndexPath *)indexPath {
    return _dataArray[indexPath.row];
}

- (NSString *)identifierAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == SGDetailItemDeadline) return @(DetailCellStyleText).stringValue;
    else if (indexPath.row == SGDetailItemDescription) return @(DetailCellStyleMultiLineText).stringValue;
    else if (indexPath.row == SGDetailItemLocation) return @(DetailCellStyleMap).stringValue;
    else if (indexPath.row == SGDetailItemPhoto) return @(DetailCellStylePhoto).stringValue;
    
    return @(DetailCellStyleText).stringValue;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == SGDetailItemDeadline) {
        [self showDatetimePicker:_model.deadline];
    } else if (indexPath.row == SGDetailItemDescription) {
        RTRootNavigationController *rootNavigationController = [[RTRootNavigationController alloc] initWithRootViewController:self.editorViewController];
        self.editorViewController.value = _model.sgDescription;
        [self presentViewController:rootNavigationController animated:YES completion:nil];
    } else if (indexPath.row == SGDetailItemLocation) {
        
    } else if (indexPath.row == SGDetailItemPhoto) {
        
    }
}

#pragma mark - date time picker

- (void)showDatetimePicker:(NSDate *)deadline {
    _datePickerViewController = [HSDatePickerViewController new];
    _datePickerViewController.delegate = self;
    [_datePickerViewController configure];
    [_datePickerViewController setDate:deadline];
    
    [self presentViewController:_datePickerViewController animated:YES completion:nil];
}

- (BOOL)hsDatePickerPickedDate:(NSDate *)date {
    if ([_model.deadline compare:date] == NSOrderedAscending) _model.status = @(TodoStatusSnoozed);  // 时间推迟了才算你Snoozed
    _model.deadline = date;
    
    _dataArray[SGDetailItemDeadline].content = [DateUtil dateString:_model.deadline withFormat:@"yyyy.MM.dd HH:mm"];
    [self save];
    
    return YES;
}

#pragma mark - private methods

- (void)save {
    if (![_dataManager isModifiedTodo:_model]) return [SGHelper errorAlertWithMessage:@"Saving failed, please try again"];
    [self.tableView reloadData];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kTaskChangedNotification object:self];
}

@end
