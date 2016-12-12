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
@property(nonatomic, strong) TodoTableViewController *tableViewController;
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
    self.headerView = [SGHeaderView headerViewWithAvatarPosition:HeaderAvatarPositionCenter titleAlignement:HeaderTitleAlignmentCenter];
    self.headerView.subtitleLabel.text = [SGHelper localizedFormatDate:[NSDate date]];
    [self.headerView.rightOperationButton setHidden:YES];
    [self.headerView.avatarButton sd_setImageWithURL:GetPictureUrl(super.lcUser.avatar, kQiniuImageStyleSmall) forState:UIControlStateNormal];
    [self.headerView setImage:[UIImage imageAtResourcePath:@"header bg"] style:HeaderMaskStyleLight];
    [self.headerView setHeaderViewDidPressRightOperationButton:^{[SGHelper photoPickerFromTarget:weakSelf];}];
    self.segmentedPager.parallaxHeader.view = self.headerView;
    
    // segment view controllers
    _tableViewController = [TodoTableViewController new];
    _tableViewController.style = TodoTableViewControllerStyleHome;
    [self addChildViewController:_tableViewController];
    [self.view addSubview:_tableViewController.tableView];
    self.viewControllers = @[_tableViewController.tableView];
    
    self.titleArray = @[@"COMPLETED".attributedString];
}

- (void)retrieveData {
    [_tableViewController retrieveDataWithUser:self.cdUser date:nil];
}
@end