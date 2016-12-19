//
// Created by Siegrain on 16/12/19.
// Copyright (c) 2016 com.siegrain. All rights reserved.
//

#import "SettingViewController.h"
#import "SettingTableViewController.h"


@interface SettingViewController() <SGBaseTableViewControllerDelegate>
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
    return kScreenWidth * 0.5f;
}

#pragma mark - initial

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self retrieveData];
}

- (void)setupViews {
    [super setupViews];
    
    __weak typeof(self) weakSelf = self;
    
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.titleLabel.text = Localized(@"System");
    [self.rightNavigationButton setHidden:YES];
    
    //header
    self.headerView = [SGHeaderView headerViewWithAvatarPosition:HeaderAvatarPositionBottom titleAlignement:NSTextAlignmentLeft];
    self.headerView.titleLabel.text = self.cdUser.name;
    [self.headerView.avatarButton setHidden:YES];
    [self.headerView.rightOperationButton sd_setImageWithURL:GetPictureUrl(self.lcUser.avatar, kQiniuImageStyleSmall) forState:UIControlStateNormal];
    [self.headerView setImage:[UIImage imageAtResourcePath:@"setting header bg"] style:HeaderMaskStyleMedium];
    [self.headerView setHeaderViewDidPressRightOperationButton:^{[SGHelper photoPickerFromTarget:weakSelf];}];
    
    //table view
    _tableViewController = [SettingTableViewController new];
    _tableViewController.tableView.tableHeaderView = self.headerView;
    _tableViewController.delegate = self;
    [self addChildViewController:_tableViewController];
    [self.view addSubview:_tableViewController.tableView];
    
    //parallax configurations
    self.headerView.parallaxScrollView = _tableViewController.tableView;
    self.headerView.parallaxHeight = self.headerHeight;
    self.headerView.parallaxIgnoreInset = 64;
}

- (void)bindConstraints {
    [super bindConstraints];
    
    [_tableViewController.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.offset(0);
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
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:ColorWithRGBA(0xFF3366, alpha)] forBarMetrics:UIBarMetricsDefault];
}
@end