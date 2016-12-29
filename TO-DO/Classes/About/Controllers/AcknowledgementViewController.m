//
// Created by Siegrain on 16/12/26.
// Copyright (c) 2016 com.siegrain. All rights reserved.
//

#import "AcknowledgementViewController.h"
#import "SettingModel.h"
#import "SettingTableViewCell.h"
#import "SGSectionHeader.h"
#import "SGWebViewController.h"

@interface AcknowledgementViewController ()
@property(nonatomic, copy) NSArray<NSArray<SettingModel *> *> *dataArray;
@property(nonatomic, copy) NSArray *titleArray;
@property(nonatomic, copy) NSDictionary *acknowledgements;
@end

@implementation AcknowledgementViewController
#pragma mark - initial

- (void)viewDidLoad {
    _acknowledgements = @{
            @"DO": @"https://www.invisionapp.com/do"
    };
    _titleArray = @[Localized(@"SOURCE OF UI DESIGN"),@""];
    NSMutableArray *data = [NSMutableArray new];
    for (NSString *name in _acknowledgements.allKeys) {
        [data addObject:[SettingModel modelWithIconName:@"ack_invision" title:name content:nil style:SettingCellStyleNavigator isOn:NO]];
    }
    _dataArray = @[
            @[],
            [data copy]
    ];
    
    [super viewDidLoad];
}

- (void)setupViews {
    [super setupViews];
    [self setupNavigationBar];
    [self setupNavigationBackIndicator];
    
    self.title = Localized(@"Acknowledgements");
    
    self.tableView.backgroundColor = [SGHelper themeColorLightGray];
    
    [self setSeparatorInsetWithTableView:self.tableView inset:UIEdgeInsetsMake(0, kScreenWidth * kSpacingRatioToWidth * 2 + kIconSize, 0, kScreenWidth * kSpacingRatioToWidth)];
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 30)];
    self.tableView.sectionFooterHeight = 20;
    
    [self.tableView registerClass:[SettingTableViewCell class] forCellReuseIdentifier:@(SettingCellStyleNavigator).stringValue];
    [self.tableView registerClass:[SettingTableViewCell class] forCellReuseIdentifier:@(SettingCellStyleNone).stringValue];
}

#pragma mark - events

- (void)leftNavButtonDidPress {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - tableview

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray[section].count;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    SGSectionHeader *header = [SGSectionHeader new];
    header.backgroundColor = [UIColor clearColor];
    header.text = _titleArray[section];
    return header;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    SettingModel *model = (SettingModel *) [self modelAtIndexPath:indexPath];
    if (!model.rowHeight) model.rowHeight = [self.tableView cellHeightForIndexPath:indexPath model:model keyPath:@"model" cellClass:[SettingTableViewCell class] contentViewWidth:kScreenWidth];
    return model.rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[self identifierAtIndexPath:indexPath] forIndexPath:indexPath];
    SettingModel *model = (SettingModel *) [self modelAtIndexPath:indexPath];
    cell.model = model;
    return cell;
}

- (SettingModel *)modelAtIndexPath:(NSIndexPath *)indexPath {
    return _dataArray[indexPath.section][indexPath.row];
}

- (NSString *)identifierAtIndexPath:(NSIndexPath *)indexPath {
    return @(_dataArray[indexPath.section][indexPath.row].style).stringValue;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SettingModel *model = (SettingModel *) [self modelAtIndexPath:indexPath];
    SGWebViewController *viewController = [[SGWebViewController alloc] initWithURL:[NSURL URLWithString:_acknowledgements[model.title]]];
    [self.navigationController pushViewController:viewController animated:YES];
}
@end