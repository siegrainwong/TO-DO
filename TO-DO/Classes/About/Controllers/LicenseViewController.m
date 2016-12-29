//
// Created by Siegrain on 16/12/26.
// Copyright (c) 2016 com.siegrain. All rights reserved.
//

#import "LicenseViewController.h"
#import "SettingModel.h"
#import "SettingTableViewCell.h"
#import "SGSectionHeader.h"
#import "SGWebViewController.h"

@interface LicenseViewController ()
@property(nonatomic, copy) NSArray<NSArray<SettingModel *> *> *dataArray;
@property(nonatomic, copy) NSArray *titleArray;
@property(nonatomic, copy) NSDictionary *repositories;
@end

@implementation LicenseViewController
#pragma mark - initial

- (void)viewDidLoad {
    _repositories = @{
            @"ACEExpandableTextCell": @"https://github.com/acerbetti/ACEExpandableTextCell",
            @"SDAutoLayout": @"https://github.com/gsdios/SDAutoLayout",
            @"FSCalendar": @"https://github.com/WenchaoD/FSCalendar",
            @"HMSegmentedControl": @"https://github.com/HeshamMegid/HMSegmentedControl",
            @"MXSegmentedPager": @"https://github.com/maxep/MXSegmentedPager",
            @"MXPagerView": @"https://github.com/maxep/MXPagerView",
            @"MBProgressHUD": @"https://github.com/jdg/MBProgressHUD",
            @"TPKeyboardAvoiding": @"https://github.com/michaeltyson/TPKeyboardAvoiding",
            @"Masonry": @"https://github.com/SnapKit/Masonry",
            @"SDWebImage": @"https://github.com/rs/SDWebImage",
            @"RTRootNavigationController": @"https://github.com/rickytan/RTRootNavigationController",
            @"AutoLinearLayoutView": @"https://github.com/qianbin/AutoLinearLayoutView",
            @"JVFloatingDrawer": @"https://github.com/JVillella/JVFloatingDrawer",
            @"MGSwipeTableCell": @"https://github.com/MortimerGoro/MGSwipeTableCell",
            @"ZFDragableModalTransition": @"https://github.com/zoonooz/ZFDragableModalTransition",
            @"MagicalRecord": @"https://github.com/magicalpanda/MagicalRecord",
            @"CocoaLumberjack": @"https://github.com/CocoaLumberjack/CocoaLumberjack",
            @"DGActivityIndicatorView": @"https://github.com/gontovnik/DGActivityIndicatorView",
            @"AFNetworking-Synchronous": @"https://github.com/paulmelnikow/AFNetworking-Synchronous",
            @"RealReachability": @"https://github.com/dustturtle/RealReachability",
            @"IGLDropDownMenu": @"https://github.com/bestwnh/IGLDropDownMenu",
            @"LCActionSheet": @"https://github.com/iTofu/LCActionSheet",
            @"FDFullscreenPopGesture": @"https://github.com/forkingdog/FDFullscreenPopGesture",
            @"MJExtension": @"https://github.com/CoderMJLee/MJExtension",
            @"JMRoundedCorner": @"https://github.com/raozhizhen/JMRoundedCorner",
            @"BEMCheckBox": @"https://github.com/Boris-Em/BEMCheckBox",
            @"EMString": @"https://github.com/TanguyAladenise/EMString",
            @"TOWebViewController": @"https://github.com/TimOliver/TOWebViewController",
    };
    _titleArray = @[Localized(@"VERY APPRECIATE FOR THESE PROJECTS"),@""];
    NSMutableArray *data = [NSMutableArray new];
    for (NSString *name in _repositories.allKeys) {
        [data addObject:[SettingModel modelWithIconName:nil title:name content:nil style:SettingCellStyleNavigator isOn:NO]];
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
    
    self.title = Localized(@"Licenses");
    
    self.tableView.backgroundColor = [SGHelper themeColorLightGray];
    
    [self setSeparatorInsetWithTableView:self.tableView inset:UIEdgeInsetsMake(0, kScreenWidth * kSpacingRatioToWidth, 0, 0)];
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
    SGWebViewController *viewController = [[SGWebViewController alloc] initWithURL:[NSURL URLWithString:_repositories[model.title]]];
    [self.navigationController pushViewController:viewController animated:YES];
}
@end