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
#import "HSDatePickerViewController.h"

typedef NS_ENUM(NSInteger, SGDetailItem) {
    SGDetailItemDeadline,
    SGDetailItemDescription,
    SGDetailItemLocation,
    SGDetailItemPhoto
};

@interface DetailTableViewController ()
@property(nonatomic, strong) CDTodo *model;

@property(nonatomic, strong) NSArray<DetailModel *> *dataArray;
@end

@implementation DetailTableViewController

- (void)setModel:(CDTodo *)model {
    _model = model;
    
    _dataArray = @[
            [DetailModel modelWithIconName:@"watch" content:[DateUtil dateString:model.deadline withFormat:@"yyyy.MM.dd HH:mm"] location:nil photoUrl:nil photoPath:nil placeholder:Localized(@"Deadline")],
            [DetailModel modelWithIconName:@"description" content:model.sgDescription location:nil photoUrl:nil photoPath:nil placeholder:Localized(@"Description")],
            [DetailModel modelWithIconName:@"map" content:model.explicitAddress location:model.coordinate photoUrl:nil photoPath:nil placeholder:Localized(@"Add location")],
            [DetailModel modelWithIconName:@"camera" content:nil location:nil photoUrl:model.photoUrl photoPath:model.photoPath placeholder:Localized(@"Add a photo")],
    ];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupViews];
    [self bindConstraints];
}

- (void)setupViews {
    [self.tableView registerClass:[DetailTableViewCell class] forCellReuseIdentifier:@(DetailCellStyleMap).stringValue];
    [self.tableView registerClass:[DetailTableViewCell class] forCellReuseIdentifier:@(DetailCellStylePhoto).stringValue];
    [self.tableView registerClass:[DetailTableViewCell class] forCellReuseIdentifier:@(DetailCellStyleText).stringValue];
    [self.tableView registerClass:[DetailTableViewCell class] forCellReuseIdentifier:@(DetailCellStyleMultiLineText).stringValue];
}

- (void)bindConstraints {
    
}

#pragma mark - tableview

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    DetailModel *model = [self modelAtIndexPath:indexPath];
    if (!model.rowHeight) model.rowHeight = [self.tableView cellHeightForIndexPath:indexPath model:model keyPath:@"model" cellClass:[DetailTableViewCell class] contentViewWidth:kScreenWidth];
    return model.rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[self identifierAtIndexPath:indexPath] forIndexPath:indexPath];
    cell.model = [self modelAtIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == SGDetailItemDeadline) {
        
    } else if (indexPath.row == SGDetailItemDescription) {
        
    } else if (indexPath.row == SGDetailItemLocation) {
        
    } else if (indexPath.row == SGDetailItemPhoto) {
        
    }
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

@end