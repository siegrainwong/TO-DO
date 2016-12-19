//
// Created by Siegrain on 16/12/19.
// Copyright (c) 2016 com.siegrain. All rights reserved.
//

#import "SettingViewController.h"
#import "SettingTableViewController.h"


@interface SettingViewController()
@property(nonatomic, strong) SettingTableViewController *tableViewController;

@property(nonatomic, assign) BOOL isOpacityNavigation;
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
    
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.alpha = 0;
    
    //header
    self.headerView = [SGHeaderView headerViewWithAvatarPosition:HeaderAvatarPositionBottom titleAlignement:NSTextAlignmentLeft];
    self.headerView.titleLabel.text = self.cdUser.name;
    [self.headerView.avatarButton setHidden:YES];
    [self.headerView.rightOperationButton sd_setImageWithURL:GetPictureUrl(self.lcUser.avatar, kQiniuImageStyleSmall) forState:UIControlStateNormal];
    [self.headerView setImage:[UIImage imageAtResourcePath:@"header bg"] style:HeaderMaskStyleLight];
    [self.headerView setHeaderViewDidPressRightOperationButton:^{[SGHelper photoPickerFromTarget:weakSelf];}];
    
    //table view
    _tableViewController = [SettingTableViewController new];
    _tableViewController.tableView.tableHeaderView = self.headerView;
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

#pragma mark - TodoTableViewController

- (void)todoTableViewDidScrollToY:(CGFloat)y {
    //计算alpha
    float alpha = y > self.headerHeight ? 1 : y <= 0 ? 0 : y / self.headerHeight;
    //alpha为1时设置不透明
    [self.navigationController.navigationBar setTranslucent:alpha != 1];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:ColorWithRGBA(0xFF3366, alpha)] forBarMetrics:UIBarMetricsDefault];
    _tableViewController.tableView.showsVerticalScrollIndicator = alpha == 1;
    if (alpha == 1 && !_isOpacityNavigation) {
        _isOpacityNavigation = YES;
        
        [UIView animateWithDuration:.3 animations:^{
            self.titleLabel.text = self.headerView.titleLabel.text;
            self.titleLabel.alpha = 1;
        }];
    } else if (alpha != 1 && _isOpacityNavigation) {
        _isOpacityNavigation = NO;
        
        [UIView animateWithDuration:.3 animations:^{
            self.titleLabel.text = nil;
            self.titleLabel.alpha = 0;
        }];
    }
}
@end