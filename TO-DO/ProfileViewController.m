//
// Created by Siegrain on 16/12/12.
// Copyright (c) 2016 com.siegrain. All rights reserved.
//

#import <SDWebImage/UIButton+WebCache.h>
#import "ProfileViewController.h"
#import "SGHeaderView.h"
#import "UIImage+Extension.h"
#import "NSString+EMAdditions.h"
#import "TodoTableViewController.h"

@interface ProfileViewController ()
@property(nonatomic, strong) TodoTableViewController *completedTableViewController;
@property(nonatomic, strong) TodoTableViewController *snoozedTableViewController;
@property(nonatomic, strong) TodoTableViewController *overdueTableViewController;
@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self retrieveData];
}

- (void)setupViews {
    [super setupViews];
    
    __weak __typeof(self) weakSelf = self;
    //header
    self.headerView = [SGHeaderView headerViewWithAvatarPosition:HeaderAvatarPositionBottom titleAlignement:HeaderTitleAlignmentCenter];
    self.headerView.subtitleLabel.text = [SGHelper localizedFormatDate:[NSDate date]];
    self.headerView.titleLabel.text = self.cdUser.name;
    [self.headerView.rightOperationButton setHidden:YES];
    [self.headerView.avatarButton sd_setImageWithURL:GetPictureUrl(super.lcUser.avatar, kQiniuImageStyleSmall) forState:UIControlStateNormal];
    [self.headerView setImage:[UIImage imageAtResourcePath:@"header bg"] style:HeaderMaskStyleLight];
    [self.headerView setHeaderViewDidPressRightOperationButton:^{[SGHelper photoPickerFromTarget:weakSelf];}];
    self.segmentedPager.parallaxHeader.view = self.headerView;
    self.segmentedPager.parallaxHeader.height = (CGFloat) (kScreenWidth * 0.75);
    
    // segment view controllers
    _completedTableViewController = [TodoTableViewController new];
    _completedTableViewController.style = TodoTableViewControllerStyleHome;
    [self addChildViewController:_completedTableViewController];
    
    _snoozedTableViewController = [TodoTableViewController new];
    _snoozedTableViewController.style = TodoTableViewControllerStyleHome;
    [self addChildViewController:_snoozedTableViewController];
    
    _overdueTableViewController = [TodoTableViewController new];
    _overdueTableViewController.style = TodoTableViewControllerStyleHome;
    [self addChildViewController:_overdueTableViewController];
    self.viewControllers = @[_completedTableViewController.tableView, _snoozedTableViewController.tableView, _overdueTableViewController.tableView];
    
    self.titleArray = @[@"COMPLETED".attributedString, @"SNOOZED".attributedString, @"OVERDUE".attributedString];
}

- (void)retrieveData {
    [_completedTableViewController retrieveDataWithUser:self.cdUser date:nil];
    [_snoozedTableViewController retrieveDataWithUser:self.cdUser date:nil];
    [_overdueTableViewController retrieveDataWithUser:self.cdUser date:nil];
}
@end