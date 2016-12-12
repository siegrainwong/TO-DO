//
//  HomeViewController.m
//  TO-DO
//
//  Created by Siegrain on 16/5/13.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "CDTodo.h"
#import "CreateViewController.h"
#import "HomeViewController.h"
#import "UIImage+Extension.h"
#import "CommonDataManager.h"
#import "UIButton+WebCache.h"

// TODO: 搜索功能
// FIXME: 我的6P启动时会有一两秒黑屏，黑屏时间似乎和同步的准备同步时间相同，应该是有什么阻塞主线程了
// FIXME: HeaderView释放不了了，莫名其妙的

// Mark: 这里为了让Section能够挂在NavigationBar之下，设置了HeaderView的IgnoreInset属性忽略了NavigationBar的64Inset

@interface
HomeViewController ()
@property(nonatomic, strong) TodoTableViewController *todoTableViewController;
@property(nonatomic, assign) BOOL isOpacityNavigation;
@property(nonatomic, strong) UIButton *addButton;
@end

@implementation HomeViewController

- (void)dealloc {
    //Mark: 由于释放顺序的原因，导致TableView释放后KVO还没有移除，只有先移除HeaderView
    [_todoTableViewController.tableView.tableHeaderView removeFromSuperview];
    self.headerView = nil;
    DDLogWarn(@"%s", __func__);
}

#pragma mark - localization

- (void)localizeStrings {
    self.headerView.titleLabel.text = [NSString stringWithFormat:@"%ld %@", (long) _todoTableViewController.dataCount, NSLocalizedString(@"Tasks", nil)];
    if (self.titleLabel.alpha == 1) self.titleLabel.text = self.headerView.titleLabel.text;
}

#pragma mark - accessors

- (CGFloat)headerHeight {
    return kScreenWidth * 0.9f;
}

#pragma mark - initial

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self localizeStrings];
    [self retrieveData];
}

- (void)setupViews {
    [super setupViews];
    
    __weak typeof(self) weakSelf = self;
    
    //nav add button
    _addButton = [UIButton new];
    _addButton.tintColor = [UIColor whiteColor];
    _addButton.frame = CGRectMake(0, 0, 20, 20);
    _addButton.titleLabel.font = [SGHelper themeFontNavBar];
    [_addButton setImage:[UIImage imageNamed:@"nav_add"] forState:UIControlStateNormal];
    [_addButton addTarget:self action:@selector(showCreateViewController) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setRightBarButtonItems:@[[[UIBarButtonItem alloc] initWithCustomView:self.rightNavigationButton], [[UIBarButtonItem alloc] initWithCustomView:_addButton]] animated:NO];
    
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.alpha = 0;
    _addButton.alpha = 0;
    
    //header
    self.headerView = [SGHeaderView headerViewWithAvatarPosition:HeaderAvatarPositionCenter titleAlignement:HeaderTitleAlignmentCenter];
    self.headerView.subtitleLabel.text = [SGHelper localizedFormatDate:[NSDate date]];
    [self.headerView.rightOperationButton setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    [self.headerView.avatarButton sd_setImageWithURL:GetPictureUrl(super.lcUser.avatar, kQiniuImageStyleSmall) forState:UIControlStateNormal];
    [self.headerView setImage:[UIImage imageAtResourcePath:@"header bg"] style:HeaderMaskStyleLight];
    [self.headerView setHeaderViewDidPressAvatarButton:^{[SGHelper photoPickerFromTarget:weakSelf];}];
    [self.headerView setHeaderViewDidPressRightOperationButton:^{[weakSelf showCreateViewController];}];
    
    //table view
    _todoTableViewController = [TodoTableViewController new];
    _todoTableViewController.style = TodoTableViewControllerStyleHome;
    _todoTableViewController.delegate = self;
    _todoTableViewController.headerHeight = self.headerHeight;
    _todoTableViewController.tableView.tableHeaderView = self.headerView;
    [self addChildViewController:_todoTableViewController];
    [self.view addSubview:_todoTableViewController.tableView];
    
    //parallax configurations
    self.headerView.parallaxScrollView = _todoTableViewController.tableView;
    self.headerView.parallaxHeight = self.headerHeight;
    self.headerView.parallaxIgnoreInset = 64;
}

- (void)bindConstraints {
    [super bindConstraints];
    
    [_todoTableViewController.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.offset(0);
    }];
    
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.offset(CGFLOAT_MIN);
        make.width.offset(kScreenWidth);
        make.height.offset(self.headerHeight);
    }];
}

#pragma mark - events

- (void)showCreateViewController {
    CreateViewController *createViewController = [CreateViewController new];
    [createViewController setSelectedDate:[[NSDate date] dateByAddingTimeInterval:60 * 10]];
    [createViewController setCreateViewControllerDidFinishCreate:^(CDTodo *model) {model.photoImage = [model.photoImage imageAddCornerWithRadius:model.photoImage.size.width / 2 andSize:model.photoImage.size];}];
    [self.navigationController pushViewController:createViewController animated:YES];
}

#pragma mark - retrieve data

- (void)retrieveData {
    [_todoTableViewController retrieveDataWithUser:self.cdUser date:nil status:nil isComplete:@NO];
}

#pragma mark - TodoTableViewController

- (void)todoTableViewDidScrollToY:(CGFloat)y {
    //计算alpha
    float alpha = y > self.headerHeight ? 1 : y <= 0 ? 0 : y / self.headerHeight;
    //alpha为1时设置不透明
    [self.navigationController.navigationBar setTranslucent:alpha != 1];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:ColorWithRGBA(0xFF3366, alpha)] forBarMetrics:UIBarMetricsDefault];
    _todoTableViewController.tableView.showsVerticalScrollIndicator = alpha == 1;
    if (alpha == 1 && !_isOpacityNavigation) {
        _isOpacityNavigation = YES;
        
        [UIView animateWithDuration:.3 animations:^{
            self.titleLabel.text = self.headerView.titleLabel.text;
            self.titleLabel.alpha = 1;
            _addButton.alpha = 1;
        }];
    } else if (alpha != 1 && _isOpacityNavigation) {
        _isOpacityNavigation = NO;
        
        [UIView animateWithDuration:.3 animations:^{
            self.titleLabel.text = nil;
            self.titleLabel.alpha = 0;
            _addButton.alpha = 0;
        }];
    }
}

- (void)todoTableViewControllerDidReloadData {
    [self localizeStrings];
}
@end
