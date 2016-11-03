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
#import "TodoTableViewController.h"
#import "UIButton+WebCache.h"
#import "UIImage+Extension.h"
#import "EmptyDataView.h"
#import "MXParallaxHeader.h"

// TODO: 滚动到一定高度后需要修改导航栏颜色为不透明，同样需要调整状态栏字体颜色
// TODO: 搜索功能
// TODO: 待办事项展开功能
// Mark: 再不能全局变量都用成员变量了，内存释放太操心

@interface
HomeViewController ()
@property(nonatomic, readwrite, strong) TodoTableViewController *todoTableViewController;
@property(nonatomic, strong) EmptyDataView *emptyDataView;
@end

@implementation HomeViewController

#pragma mark - localization

- (void)localizeStrings {
    self.headerView.titleLabel.text = [NSString stringWithFormat:@"%ld %@", (long) _todoTableViewController.dataCount, NSLocalizedString(@"Tasks", nil)];
}

#pragma mark - accessors

- (CGFloat)headerHeight {
    return kScreenHeight * 0.6;
}

#pragma mark - initial

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self localizeStrings];
    [self retrieveDataFromServer];
}

- (void)setupView {
    [super setupView];
    
    _todoTableViewController = [TodoTableViewController todoTableViewControllerWithStyle:TodoTableViewControllerStyleCellAndSection];
    _todoTableViewController.delegate = self;
    _todoTableViewController.headerHeight = self.headerHeight;
    [self addChildViewController:_todoTableViewController];
    [self.view addSubview:_todoTableViewController.tableView];
    
    self.headerView = [HeaderView headerViewWithAvatarPosition:HeaderAvatarPositionCenter titleAlignement:HeaderTitleAlignmentCenter];
    self.headerView.frame = CGRectMake(0, 0, kScreenWidth, self.headerHeight);
    self.headerView.subtitleLabel.text = [SGHelper localizedFormatDate:[NSDate date]];
    [self.headerView.rightOperationButton setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    [self.headerView.avatarButton sd_setImageWithURL:GetPictureUrl(super.lcUser.avatar, kQiniuImageStyleSmall) forState:UIControlStateNormal];
    self.headerView.backgroundImage = [UIImage imageAtResourcePath:@"header bg"];
    [self.headerView setHeaderViewDidPressAvatarButton:^{[LCUser logOut];}];
    __weak typeof(self) weakSelf = self;
    [self.headerView setHeaderViewDidPressRightOperationButton:^{
        weakSelf.releaseWhileDisappear = NO;
        CreateViewController *createViewController = [[CreateViewController alloc] init];
        [createViewController setCreateViewControllerDidFinishCreate:^(CDTodo *model) {
            model.photoImage = [model.photoImage imageAddCornerWithRadius:model.photoImage.size.width / 2 andSize:model.photoImage.size];
            [weakSelf.todoTableViewController insertTodo:model];
        }];
        [createViewController setCreateViewControllerDidDisappear:^{
            weakSelf.releaseWhileDisappear = YES;
        }];
        [weakSelf.navigationController pushViewController:createViewController animated:YES];
    }];
    
    MXParallaxHeader *header = _todoTableViewController.tableView.parallaxHeader;
    header.view = self.headerView;
    header.height = self.headerHeight;
    header.mode = MXParallaxHeaderModeFill;
    header.minimumHeight = 20;
}

- (void)bindConstraints {
    [super bindConstraints];
    
    [_todoTableViewController.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.right.left.offset(0);
    }];
    
    [_emptyDataView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(self.headerHeight);
        make.bottom.right.left.offset(0);
    }];
}

#pragma mark - retrieve data

- (void)retrieveDataFromServer {
    [_todoTableViewController retrieveDataWithUser:self.cdUser date:nil];
}

#pragma mark - TodoTableViewController

- (void)todoTableViewControllerDidReloadData {
    [self localizeStrings];
}

#pragma mark - release

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if (!super.releaseWhileDisappear) return;
    
    [_todoTableViewController.timer invalidate];
    _todoTableViewController.timer = nil;
    
    [_todoTableViewController removeFromParentViewController];
    [self removeFromParentViewController];
}

- (void)dealloc {
    DDLogWarn(@"%s", __func__);
}
@end
