//
// Created by Siegrain on 16/12/19.
// Copyright (c) 2016 com.siegrain. All rights reserved.
//

#import "SettingViewController.h"
#import "SettingTableViewController.h"
#import "TodoTableViewController.h"


@interface SettingViewController () <TodoTableViewControllerDelegate, SGBaseTableViewControllerDelegate>
@property(nonatomic, strong) SettingTableViewController *tableViewController;
@end

@implementation SettingViewController

- (void)dealloc {
    //Mark: 由于释放顺序的原因，导致TableView释放后KVO还没有移除，只有先移除HeaderView
    [_tableViewController.tableView.tableHeaderView removeFromSuperview];
    self.headerView = nil;
    DDLogWarn(@"%s", __func__);
}

#pragma mark - accessors

- (CGFloat)headerHeight {
    return kScreenHeight * 0.3f;
}

- (CGFloat)headerMinimumHeight {
    return self.headerHeight / 2;
}

#pragma mark - initial

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self retrieveData];
    [_tableViewController.tableView setContentOffset:CGPointMake(0, -self.headerMinimumHeight)];
}

- (void)setupViews {
    [super setupViews];
    
    __weak typeof(self) weakSelf = self;
    
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.titleLabel.text = Localized(@"Setting");
    [self.rightNavigationButton setHidden:YES];
    
    //header
    self.headerView = [SGHeaderView headerViewWithAvatarPosition:HeaderAvatarPositionCenter titleAlignement:NSTextAlignmentLeft];
    if (iOSVersion < 10) self.headerView.frame = CGRectMake(0, 0, kScreenWidth, self.headerHeight);  //真™神了，之前的表格都没有这个Bug，不给一个frame的话tableHeaderView不会有大小
    self.headerView.titleLabel.text = self.cdUser.name;
    [self.headerView.avatarButton setHidden:YES];
    [self.headerView.rightOperationButton sd_setImageWithURL:GetQiniuPictureUrl(self.lcUser.avatar) forState:UIControlStateNormal];
    [self.headerView setImage:[UIImage imageAtResourcePath:@"setting header bg"] style:HeaderMaskStyleMedium];
    [self.headerView setHeaderViewDidPressAvatarButton:^{[weakSelf avatarButtonDidPress];}];
    
    //table view
    _tableViewController = [SettingTableViewController new];
    _tableViewController.tableView.tableHeaderView = self.headerView;
    _tableViewController.tableView.contentInset = UIEdgeInsetsMake(self.headerMinimumHeight, 0, 0, 0);
    _tableViewController.delegate = self;
    [self addChildViewController:_tableViewController];
    [self.view addSubview:_tableViewController.tableView];
    
    //parallax configurations
    self.headerView.parallaxScrollView = _tableViewController.tableView;
    self.headerView.parallaxHeight = self.headerHeight;
    self.headerView.parallaxMinimumHeight = self.headerMinimumHeight;
}

- (void)bindConstraints {
    [super bindConstraints];
    
    [_tableViewController.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(-64);
        make.left.bottom.right.offset(0);
    }];
    
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.offset(CGFLOAT_MIN);
        make.width.offset(kScreenWidth);
        make.height.offset(self.headerHeight);
    }];
}

#pragma mark - retrieve data

- (void)retrieveData {
//    [_tableViewController retrieveDataWithUser:self.cdUser date:nil status:nil isComplete:@(NO) keyword:nil];
}

#pragma mark - table view controller

- (void)tableViewDidScrollToY:(CGFloat)y {
    float alpha = y > self.headerHeight ? 1 : y <= 0 ? 0 : y / self.headerHeight;   //计算alpha
}
@end