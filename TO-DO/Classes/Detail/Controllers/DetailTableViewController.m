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
#import "SGBaseMapViewController.h"
#import "SGImageUpload.h"

typedef NS_ENUM(NSInteger, SGDetailItem) {
    SGDetailItemDeadline,
    SGDetailItemDescription,
    SGDetailItemLocation,
    SGDetailItemPhoto
};

@interface DetailTableViewController () <HSDatePickerViewControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, TZImagePickerControllerDelegate>
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
        _editorViewController.maxLength = kMaxLengthOfDescription;
        __weak __typeof(self) weakSelf = self;
        [_editorViewController setEditorDidSave:^(NSString *value) {
            weakSelf.model.sgDescription = value;
            weakSelf.dataArray[SGDetailItemDescription].content = value;
            weakSelf.dataArray[SGDetailItemDescription].rowHeight = 0;
            [weakSelf saveAndReload];
        }];
    }
    return _editorViewController;
}


#pragma mark - initial

- (void)setModel:(CDTodo *)model {
    _model = model;
    
    _dataArray = @[
            [DetailModel modelWithIconName:@"detail_watch" content:[DateUtil dateString:model.deadline withFormat:@"yyyy.MM.dd HH:mm"] location:nil photoUrl:nil photoPath:nil placeholder:Localized(@"Deadline") identifier:model.identifier cellStyle:DetailCellStyleText],
            [DetailModel modelWithIconName:@"detail_description" content:model.sgDescription location:nil photoUrl:nil photoPath:nil placeholder:Localized(@"Input description") identifier:model.identifier cellStyle:DetailCellStyleMultiLineText],
            [DetailModel modelWithIconName:@"detail_map" content:model.coordinate.address location:model.coordinate photoUrl:nil photoPath:nil placeholder:Localized(@"Add location") identifier:model.identifier cellStyle:DetailCellStyleMap],
            [DetailModel modelWithIconName:@"detail_camera" content:nil location:nil photoUrl:model.photoUrl photoPath:model.photoPath placeholder:Localized(@"Add a photo") identifier:model.identifier cellStyle:DetailCellStylePhoto],
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
    DetailModel *model = (DetailModel *) [self modelAtIndexPath:indexPath];
    if (!model.rowHeight) model.rowHeight = [self.tableView cellHeightForIndexPath:indexPath model:model keyPath:@"model" cellClass:[DetailTableViewCell class] contentViewWidth:kScreenWidth];
    if (indexPath.row == _dataArray.count - 1 && self.tableViewDidCalculateHeight && !_cellsTotalHeight) {  //如果不进行最后一个判断会无限递归，因为外部layout后tableview也会reload data
        _cellsTotalHeight = self.tableView.cellsTotalHeight;
        self.tableViewDidCalculateHeight(_cellsTotalHeight);
    }
    return model.rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[self identifierAtIndexPath:indexPath] forIndexPath:indexPath];
    cell.model = (DetailModel *) [self modelAtIndexPath:indexPath];
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
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == SGDetailItemDeadline) {
        [self showDatetimePicker:_model.deadline];
    } else if (indexPath.row == SGDetailItemDescription) {
        RTRootNavigationController *rootNavigationController = [[RTRootNavigationController alloc] initWithRootViewController:self.editorViewController];
        self.editorViewController.value = _model.sgDescription;
        [self presentViewController:rootNavigationController animated:YES completion:nil];
    } else if (indexPath.row == SGDetailItemLocation) {
        SGBaseMapViewController *viewController = [SGBaseMapViewController new];
        viewController.isEditing = YES;
        viewController.coordinate = _model.coordinate;
        __weak __typeof(self) weakSelf = self;
        [viewController setBlock:^(SGCoordinate *coordinate) {
            weakSelf.model.coordinate = coordinate;
            weakSelf.model.longitude = @(coordinate.longitude);
            weakSelf.model.latitude = @(coordinate.latitude);
            weakSelf.model.generalAddress = coordinate.generalAddress;
            weakSelf.model.explicitAddress = coordinate.explicitAddress;
            
            DetailModel *model = weakSelf.dataArray[SGDetailItemLocation];
            model.rowHeight = 0;
            model.content = coordinate.address;
            model.location = coordinate;
            
            [weakSelf saveAndReload];
        }];
        
        RTRootNavigationController *rootNavigationController = [[RTRootNavigationController alloc] initWithRootViewController:viewController];
        [self presentViewController:rootNavigationController animated:YES completion:nil];
    } else if (indexPath.row == SGDetailItemPhoto) {
        __weak __typeof(self) weakSelf = self;
        [SGHelper photoPickerFrom:self allowCrop:NO currentPhoto:weakSelf.model.photoImage pickerDidPicked:^(UIImage *image) {
            weakSelf.model.photoData = [SGImageUpload dataWithImage:image type:SGImageTypePhoto quality:kSGDefaultImageQuality];
            weakSelf.model.photoImage = [UIImage imageWithData:_model.photoData];
            [weakSelf.model saveImageWithBlock:^(BOOL succeed) {
                if(!succeed){
                    [SGHelper errorAlertWithMessage:Localized(@"Failed to save photo, please check your storage on device and try again")];
                    return;
                }
    
                DetailModel *model = weakSelf.dataArray[SGDetailItemPhoto];
                model.photoPath = weakSelf.model.photoPath;
                model.rowHeight = 0;
    
                [weakSelf saveAndReload];
            }];
        }];
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
    [self saveAndReload];
    
    return YES;
}

#pragma mark - private methods

- (void)saveAndReload {
    [self save];
    
    [self.tableView reloadData];
}

- (void)save {
    if (![_dataManager modifyTask:_model]) return;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kTaskChangedNotification object:self];
}

@end
