//
// Created by Siegrain on 16/12/25.
// Copyright (c) 2016 com.siegrain. All rights reserved.
//

#import "AboutViewController.h"
#import "SettingModel.h"
#import "SettingTableViewCell.h"
#import "SGSectionHeader.h"
#import "TOWebViewController.h"
#import "SGWebViewController.h"
#import "LicenseViewController.h"
#import "AcknowledgementViewController.h"


@interface AboutViewController () <SGNavigationBar>
@property(nonatomic, copy) NSArray<NSArray<SettingModel *> *> *dataArray;
@property(nonatomic, strong) NSArray *titleArray;

@property(nonatomic, strong) UIView *headerView;
@property(nonatomic, strong) UIImageView *logoView;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *contentLabel;
@end

@implementation AboutViewController
#pragma mark - initial

- (void)viewDidLoad {
    _titleArray = @[@"", @"", @""];
    _dataArray = @[
            @[
                    [SettingModel modelWithIconName:nil title:Localized(@"Privacy Policy") content:nil style:SettingCellStyleNavigator isOn:NO],
                    [SettingModel modelWithIconName:nil title:Localized(@"Licenses") content:nil style:SettingCellStyleNavigator isOn:NO],
            ],
            @[
                    [SettingModel modelWithIconName:nil title:Localized(@"Acknowledgements") content:nil style:SettingCellStyleNavigator isOn:NO],
            ],
            @[
                    [SettingModel modelWithIconName:nil title:Localized(@"Version") content:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] style:SettingCellStyleNone isOn:NO],
            ]
    ];
    
    [super viewDidLoad];
}

- (void)setupViews {
    [super setupViews];
    [self setupNavigationBar];
    [self setupNavigationBackIndicator];
    
    self.title = Localized(@"About");
    
    self.tableView.backgroundColor = [SGHelper themeColorLightGray];
    
    _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 185)];
    
    _logoView = [UIImageView new];
    NSDictionary *infoPlist = [[NSBundle mainBundle] infoDictionary];
    NSString *iconName = [[infoPlist valueForKeyPath:@"CFBundleIcons.CFBundlePrimaryIcon.CFBundleIconFiles"] lastObject];
    _logoView.image = [UIImage imageNamed:iconName];
    [_headerView addSubview:_logoView];
    
    _titleLabel = [UILabel new];
    _titleLabel.text = @"TO-DO";
    _titleLabel.font = [SGHelper themeFontNavBar];
    _titleLabel.textColor = [SGHelper subTextColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [_headerView addSubview:_titleLabel];
    
    _contentLabel = [UILabel new];
    _contentLabel.text = Localized(@"Developer email: siegrainwong@gmail.com");
    _contentLabel.font = [SGHelper themeFontDefault];
    _contentLabel.textAlignment = NSTextAlignmentCenter;
    [_headerView addSubview:_contentLabel];
    
    [self setSeparatorInsetWithTableView:self.tableView inset:UIEdgeInsetsMake(0, kScreenWidth * kSpacingRatioToWidth, 0, 0)];
    self.tableView.sectionFooterHeight = 20;
    self.tableView.tableHeaderView = _headerView;
    
    [self.tableView registerClass:[SettingTableViewCell class] forCellReuseIdentifier:@(SettingCellStyleNavigator).stringValue];
    [self.tableView registerClass:[SettingTableViewCell class] forCellReuseIdentifier:@(SettingCellStyleNone).stringValue];
}

- (void)bindConstraints {
    [super bindConstraints];
    
    [_logoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(10);
        make.centerX.offset(0);
        make.height.width.offset(100);
    }];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_logoView.mas_bottom).offset(10);
        make.left.right.offset(0);
        make.height.offset(20);
    }];
    
    [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_titleLabel.mas_bottom).offset(15);
        make.left.right.offset(0);
        make.height.offset(20);
    }];
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    NSString *title = _titleArray[section];
    return title.length ? 20 : 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    SGSectionHeader *header = [SGSectionHeader new];
    header.backgroundColor = [UIColor clearColor];
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
    
    if (indexPath.section == 0 && indexPath.row == 0) { //Privacy policy
        SGWebViewController *viewController = [[SGWebViewController alloc] initWithURL:[NSURL URLWithString:kPrivacyPolicyUrl]];
        [self.navigationController pushViewController:viewController animated:YES];
    } else if (indexPath.section == 0 && indexPath.row == 1) {  //Licenses
        LicenseViewController *viewController = [LicenseViewController new];
        [self.navigationController pushViewController:viewController animated:YES];
    } else if (indexPath.section == 1 && indexPath.row == 0) {  //Acknowledgements
        AcknowledgementViewController *viewController = [AcknowledgementViewController new];
        [self.navigationController pushViewController:viewController animated:YES];
    }
}
@end