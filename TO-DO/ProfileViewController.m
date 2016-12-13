//
// Created by Siegrain on 16/12/12.
// Copyright (c) 2016 com.siegrain. All rights reserved.
//

#import "ProfileViewController.h"
#import "TodoTableViewController.h"

static CGFloat const kSegmentedControlHeight = 60;
static CGFloat const kParallaxHeaderMinimumHeight = 64;

@interface ProfileViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, TodoTableViewControllerDelegate>
@property(nonatomic, strong) TodoTableViewController *completedTableViewController;
@property(nonatomic, strong) TodoTableViewController *snoozedTableViewController;
@property(nonatomic, strong) TodoTableViewController *overdueTableViewController;

@property(nonatomic, assign) BOOL titleIsShowing;
@end

@implementation ProfileViewController

#pragma mark - accessors

- (CGFloat)headerHeight {
    return (CGFloat) (kScreenWidth * 0.75);
}


#pragma mark - initial

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self retrieveData];
}

- (void)setupViews {
    [super setupViews];
    
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    __weak __typeof(self) weakSelf = self;
    //header
    self.headerView = [SGHeaderView headerViewWithAvatarPosition:HeaderAvatarPositionBottom titleAlignement:HeaderTitleAlignmentCenter];
    self.headerView.titleLabel.text = self.cdUser.name;
    self.headerView.subtitleLabel.text = self.cdUser.email;
    [self.headerView.rightOperationButton setHidden:YES];
    [self.headerView.avatarButton sd_setImageWithURL:GetPictureUrl(super.lcUser.avatar, kQiniuImageStyleSmall) forState:UIControlStateNormal];
    [self.headerView setImage:[UIImage imageAtResourcePath:@"header bg"] style:HeaderMaskStyleLight];
    [self.headerView setHeaderViewDidPressAvatarButton:^{[SGHelper photoPickerFromTarget:weakSelf];}];
    self.segmentedPager.parallaxHeader.view = self.headerView;
    self.segmentedPager.parallaxHeader.height = self.headerHeight;
    self.segmentedPager.parallaxHeader.minimumHeight = kParallaxHeaderMinimumHeight;
    self.segmentedPager.parallaxHeader.mode = MXParallaxHeaderModeTopFill;
    
    // segment view controllers
    _completedTableViewController = [TodoTableViewController new];
    [self addChildViewController:_completedTableViewController];
    _snoozedTableViewController = [TodoTableViewController new];
    [self addChildViewController:_snoozedTableViewController];
    _overdueTableViewController = [TodoTableViewController new];
    [self addChildViewController:_overdueTableViewController];
    
    _completedTableViewController.style = _snoozedTableViewController.style = _overdueTableViewController.style = TodoTableViewControllerStyleHome;
    _completedTableViewController.disableCellSwiping = _snoozedTableViewController.disableCellSwiping = _overdueTableViewController.disableCellSwiping = YES;
    _completedTableViewController.headerHeight = _snoozedTableViewController.headerHeight = _overdueTableViewController.headerHeight = self.headerHeight + kSegmentedControlHeight;
    
    self.views = @[_completedTableViewController.tableView, _snoozedTableViewController.tableView, _overdueTableViewController.tableView];
    self.titles = @[@"COMPLETED".attributedString, @"SNOOZED".attributedString, @"OVERDUE".attributedString];
}

- (void)retrieveData {
    [_completedTableViewController retrieveDataWithUser:self.cdUser date:nil status:nil isComplete:@YES keyword:nil];
    [_snoozedTableViewController retrieveDataWithUser:self.cdUser date:nil status:@(TodoStatusSnoozed) isComplete:@NO keyword:nil];
    [_overdueTableViewController retrieveDataWithUser:self.cdUser date:nil status:@(TodoStatusOverdue) isComplete:@NO keyword:nil];
}

#pragma mark <MXSegmentedPagerDelegate>

- (CGFloat)heightForSegmentedControlInSegmentedPager:(MXSegmentedPager *)segmentedPager {
    return kSegmentedControlHeight;
}

- (void)segmentedPager:(MXSegmentedPager *)segmentedPager didScrollWithParallaxHeader:(MXParallaxHeader *)parallaxHeader {
    //这里的progress估计是没有将minimumHeight纳入计算，这里要根据比例来得到近似值...还要纠正误差...
    CGFloat ratio = self.headerHeight / (kParallaxHeaderMinimumHeight + self.headerHeight);
    CGFloat alpha = fabsf(parallaxHeader.progress > 0 ? 0 : parallaxHeader.progress) / ratio;
    
    //alpha大于0.8就显示title，这里由于progress值波动过大只能缩小显示阈值，且这里不要设置NavigationBar为不透明，太不稳定
    BOOL shouldDisplayTitle = alpha >= 0.8;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:ColorWithRGBA(0xFF3366, alpha)] forBarMetrics:UIBarMetricsDefault];
    if (shouldDisplayTitle && !_titleIsShowing) {
        _titleIsShowing = YES;
        
        [UIView animateWithDuration:.3 animations:^{
            self.titleLabel.text = self.cdUser.name;
            self.titleLabel.alpha = 1;
        }];
    } else if (!shouldDisplayTitle && _titleIsShowing) {
        _titleIsShowing = NO;
        
        [UIView animateWithDuration:.3 animations:^{
            self.titleLabel.text = nil;
            self.titleLabel.alpha = 0;
        }];
    }
}
@end