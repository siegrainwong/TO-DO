//
//  HomeViewController.m
//  TO-DO
//
//  Created by Siegrain on 16/5/13.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "CreateViewController.h"
#import "HomeViewController.h"
#import "LCTodo.h"
#import "Macros.h"
#import "TodoTableViewController.h"
#import "UIButton+WebCache.h"
#import "UIImage+Extension.h"

// TODO: 滚动到一定高度后需要修改导航栏颜色为不透明，同样需要调整状态栏字体颜色
// TODO: 搜索功能
// TODO: 待办事项展开功能
// TODO: 又尼玛不能释放内存了
// TODO: 空数据时展示的界面
// Mark: 再不能全局变量都用成员变量了，内存释放太操心

@interface
HomeViewController ()
@property (nonatomic, readwrite, strong) TodoTableViewController* todoTableViewController;
@end

@implementation HomeViewController
#pragma mark - localization
- (void)localizeStrings
{
    self.headerView.titleLabel.text = [NSString stringWithFormat:@"%ld %@", (long)_todoTableViewController.dataCount, NSLocalizedString(@"Tasks", nil)];
}
#pragma mark - initial
- (void)viewDidLoad
{
    [super viewDidLoad];

    [self localizeStrings];
    [self retrieveDataFromServer];
}

- (void)setupView
{
    [super setupView];

    _todoTableViewController = [TodoTableViewController todoTableViewControllerWithStyle:TodoTableViewControllerStyleCellAndSection];
    _todoTableViewController.delegate = self;
    [self addChildViewController:_todoTableViewController];
    [self.view addSubview:_todoTableViewController.tableView];

    self.headerView = [HeaderView headerViewWithAvatarPosition:HeaderAvatarPositionCenter titleAlignement:HeaderTitleAlignementCenter];
    self.headerView.subtitleLabel.text = [TodoHelper localizedFormatDate:[NSDate date]];
    [self.headerView.rightOperationButton setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    [self.headerView.avatarButton sd_setImageWithURL:GetPictureUrl(super.user.avatar, kQiniuImageStyleSmall) forState:UIControlStateNormal];
    self.headerView.backgroundImageView.image = [UIImage imageAtResourcePath:@"header bg"];
    [self.headerView setHeaderViewDidPressAvatarButton:^{ [LCUser logOut]; }];
    __weak typeof(self) weakSelf = self;
    [self.headerView setHeaderViewDidPressRightOperationButton:^{
        weakSelf.releaseWhileDisappear = NO;
        CreateViewController* createViewController = [[CreateViewController alloc] init];
        [createViewController setCreateViewControllerDidFinishCreate:^(LCTodo* model) {
            model.photoImage = [model.photoImage imageAddCornerWithRadius:model.photoImage.size.width / 2 andSize:model.photoImage.size];
            [weakSelf.todoTableViewController insertTodo:model];
        }];
        [createViewController setCreateViewControllerDidDisappear:^{
            weakSelf.releaseWhileDisappear = YES;
        }];
        [weakSelf.navigationController pushViewController:createViewController animated:YES];
    }];
    _todoTableViewController.tableView.tableHeaderView = self.headerView;
}
- (void)bindConstraints
{
    [super bindConstraints];

    [_todoTableViewController.tableView mas_makeConstraints:^(MASConstraintMaker* make) {
        make.top.bottom.right.left.offset(0);
    }];

    [self.headerView mas_makeConstraints:^(MASConstraintMaker* make) {
        make.top.left.offset(0);
        make.width.offset(kScreenWidth);
        make.height.offset(kScreenHeight * 0.6);
    }];
}
#pragma mark - retrieve data
- (void)retrieveDataFromServer
{
    [_todoTableViewController retrieveDataWithUser:self.user date:nil];
}
#pragma mark - todotableviewcontroller delegate
- (void)todoTableViewControllerDidReloadData
{
    [self localizeStrings];
}
#pragma mark - release
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    if (!super.releaseWhileDisappear) return;

    [self.view removeFromSuperview];
    self.view = nil;
    [self removeFromParentViewController];
}
- (void)dealloc
{
    NSLog(@"%s", __func__);
}
@end
