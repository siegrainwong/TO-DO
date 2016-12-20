//
// Created by Siegrain on 16/12/18.
// Copyright (c) 2016 com.siegrain. All rights reserved.
//

#import "SettingTableViewController.h"
#import "MRTodoDataManager.h"
#import "SGTextEditorViewController.h"
#import "SettingModel.h"
#import "SettingTableViewCell.h"
#import "SGSectionHeader.h"
#import "UITableView+Extension.h"

typedef NS_ENUM(NSInteger, SGSettingSection) {
    SGSettingSectionUser,
    SGSettingSectionSync,
    SGSettingSectionNotification,
    SGSettingSectionApplication
};

typedef NS_ENUM(NSInteger, SGSettingUser) {
    SGSettingUserAccount,
    SGSettingUserName,
    SGSettingUserChangePassword
};

typedef NS_ENUM(NSInteger, SGSettingSync) {
    SGSettingSyncAuto,
    SGSettingSyncTime
};

typedef NS_ENUM(NSInteger, SGSettingNotification) {
    SGSettingNotificationAuto
};

typedef NS_ENUM(NSInteger, SGSettingApplication) {
    SGSettingApplicationAbout,
    SGSettingApplicationClearCache
};

@interface SettingTableViewController ()
@property(nonatomic, strong) CDUser *user;

@property(nonatomic, strong) NSArray *titleArray;
@property(nonatomic, copy) NSArray<NSArray<SettingModel *> *> *dataArray;

@property(nonatomic, strong) MRTodoDataManager *dataManager;
@property(nonatomic, strong) SGTextEditorViewController *editorViewController;
@end

@implementation SettingTableViewController

#pragma mark - lazy load

- (SGTextEditorViewController *)editorViewController {
    if (!_editorViewController) {
        _editorViewController = [SGTextEditorViewController new];
        _editorViewController.title = Localized(@"Description");
//        __weak __typeof(self) weakSelf = self;
//        [_editorViewController setEditorDidSave:^(NSString *value) {
//            weakSelf.model.sgDescription = value;
//            weakSelf.dataArray[SGDetailItemDescription].content = value;
//            weakSelf.dataArray[SGDetailItemDescription].rowHeight = 0;
//            [weakSelf saveAndReload];
//        }];
    }
    return _editorViewController;
}


#pragma mark - initial

- (void)viewDidLoad {
    _dataManager = [MRTodoDataManager new];
    _user = [AppDelegate globalDelegate].cdUser;
    
    _titleArray = @[@"ACCOUNT", @"SYNC", @"REMINDER", @"EXTRAS"];
    _dataArray = @[
            @[
                    [SettingModel modelWithIconName:@"sys_account" title:Localized(@"Account") content:_user.email style:SettingCellStyleNavigator isOn:NO],
                    [SettingModel modelWithIconName:@"sys_name" title:Localized(@"Name") content:_user.name style:SettingCellStyleNavigator isOn:NO],
                    [SettingModel modelWithIconName:@"sys_password" title:Localized(@"Change Password") content:nil style:SettingCellStyleNavigator isOn:NO],
                    [SettingModel modelWithIconName:@"sys_signout" title:Localized(@"Sign Out") content:nil style:SettingCellStyleNone isOn:NO],
            ],
            @[
                    [SettingModel modelWithIconName:@"sys_sync" title:Localized(@"Enable auto sync") content:nil style:SettingCellStyleSwitch isOn:NO],
                    [SettingModel modelWithIconName:@"sys_synctime" title:Localized(@"Last sync time") content:_user.name style:SettingCellStyleNone isOn:NO],
            ],
            @[
                    [SettingModel modelWithIconName:@"sys_notification" title:Localized(@"Enable auto reminder") content:nil style:SettingCellStyleSwitch isOn:NO],
            ],
            @[
                    [SettingModel modelWithIconName:@"sys_info" title:Localized(@"About") content:nil style:SettingCellStyleNavigator isOn:NO],
                    [SettingModel modelWithIconName:@"sys_clean" title:Localized(@"Clear Cache") content:nil style:SettingCellStyleNone isOn:NO],
            ]
    ];
    
    [super viewDidLoad];
}

- (void)setupViews {
    [super setupViews];
    
    [self setSeparatorInsetWithTableView:self.tableView inset:UIEdgeInsetsMake(0, kScreenWidth * kSpacingRatioToWidth * 2 + kIconSize, 0, kScreenWidth * kSpacingRatioToWidth)];
    self.tableView.sectionHeaderHeight = 20;
    self.tableView.sectionFooterHeight = 20;
    
    [self.tableView registerClass:[SettingTableViewCell class] forCellReuseIdentifier:@(SettingCellStyleNavigator).stringValue];
    [self.tableView registerClass:[SettingTableViewCell class] forCellReuseIdentifier:@(SettingCellStyleNone).stringValue];
    [self.tableView registerClass:[SettingTableViewCell class] forCellReuseIdentifier:@(SettingCellStyleSwitch).stringValue];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

#pragma mark - tableview

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray[section].count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    SGSectionHeader *header = [SGSectionHeader new];
    header.text = _titleArray[section];
    return header;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    SettingModel *model = (SettingModel *) [self modelAtIndexPath:indexPath];
    if (!model.rowHeight) model.rowHeight = [self.tableView cellHeightForIndexPath:indexPath model:model keyPath:@"model" cellClass:[SettingTableViewCell class] contentViewWidth:kScreenWidth];
    return model.rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[self identifierAtIndexPath:indexPath] forIndexPath:indexPath];
    cell.model = (SettingModel *) [self modelAtIndexPath:indexPath];
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
    
    
}

#pragma mark - private methods

- (void)save {
//    if (![_dataManager modifyTask:_model]) return;
//
//    [[NSNotificationCenter defaultCenter] postNotificationName:kTaskChangedNotification object:self];
}
@end