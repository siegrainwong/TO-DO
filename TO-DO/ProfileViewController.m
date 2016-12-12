//
// Created by Siegrain on 16/12/12.
// Copyright (c) 2016 com.siegrain. All rights reserved.
//

#import "ProfileViewController.h"
#import "TodoTableViewController.h"

@interface ProfileViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property(nonatomic, strong) TodoTableViewController *completedTableViewController;
@property(nonatomic, strong) TodoTableViewController *snoozedTableViewController;
@property(nonatomic, strong) TodoTableViewController *overdueTableViewController;
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
    
    __weak __typeof(self) weakSelf = self;
    //header
    self.headerView = [SGHeaderView headerViewWithAvatarPosition:HeaderAvatarPositionBottom titleAlignement:HeaderTitleAlignmentCenter];
    self.headerView.titleLabel.text = self.cdUser.name;
    self.headerView.subtitleLabel.text = self.cdUser.email;
    [self.headerView.rightOperationButton setHidden:YES];
    [self.headerView.avatarButton sd_setImageWithURL:GetPictureUrl(super.lcUser.avatar, kQiniuImageStyleSmall) forState:UIControlStateNormal];
    [self.headerView setImage:[UIImage imageAtResourcePath:@"header bg"] style:HeaderMaskStyleLight];
    [self.headerView setHeaderViewDidPressRightOperationButton:^{[SGHelper photoPickerFromTarget:weakSelf];}];
    self.segmentedPager.parallaxHeader.view = self.headerView;
    self.segmentedPager.parallaxHeader.height = self.headerHeight;
    self.segmentedPager.parallaxHeader.minimumHeight = 64;
    
    // segment view controllers
    _completedTableViewController = [TodoTableViewController new];
    [self addChildViewController:_completedTableViewController];
    _snoozedTableViewController = [TodoTableViewController new];
    [self addChildViewController:_snoozedTableViewController];
    _overdueTableViewController = [TodoTableViewController new];
    [self addChildViewController:_overdueTableViewController];
    
    _completedTableViewController.style = _snoozedTableViewController.style = _overdueTableViewController.style = TodoTableViewControllerStyleHome;
    _completedTableViewController.disableCellSwiping = _snoozedTableViewController.disableCellSwiping = _overdueTableViewController.disableCellSwiping = YES;
//    _completedTableViewController.headerHeight = _snoozedTableViewController.headerHeight = _overdueTableViewController.headerHeight = self.headerHeight;
    
    self.viewControllers = @[_completedTableViewController.tableView, _snoozedTableViewController.tableView, _overdueTableViewController.tableView];
    
    self.titleArray = @[@"COMPLETED".attributedString, @"SNOOZED".attributedString, @"OVERDUE".attributedString];
}

- (void)bindConstraints {
    [super bindConstraints];
    
    [@[_completedTableViewController.tableView, _snoozedTableViewController.tableView, _overdueTableViewController.tableView] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.offset(0);
    }];
}

- (void)retrieveData {
    [_completedTableViewController retrieveDataWithUser:self.cdUser date:nil status:nil isComplete:@YES];
    [_snoozedTableViewController retrieveDataWithUser:self.cdUser date:nil status:@(TodoStatusSnoozed) isComplete:@NO];
    [_overdueTableViewController retrieveDataWithUser:self.cdUser date:nil status:@(TodoStatusOverdue) isComplete:@NO];
}
@end