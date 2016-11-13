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
#import "UIButton+WebCache.h"
#import "UIImage+Extension.h"
#import "EmptyDataView.h"
#import "MXParallaxHeader.h"
#import "CommonDataManager.h"

// TODO: 搜索功能
// TODO: 待办事项展开功能
// Mark: 再不能全局变量都用成员变量了，内存释放太操心

@interface
HomeViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property(nonatomic, readwrite, strong) TodoTableViewController *todoTableViewController;
@property(nonatomic, strong) EmptyDataView *emptyDataView;
@property(nonatomic, assign) BOOL isOpacityNavigation;
@end

@implementation HomeViewController

- (void)dealloc {
    DDLogWarn(@"%s", __func__);
}

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
    
    //Mark: 切换到新的NavigationController加载进来之后ContentOffset.Y会是负的不明数值。
    [_todoTableViewController.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (void)setupViews {
    [super setupViews];
    
    __weak typeof(self) weakSelf = self;
    
    _todoTableViewController = [TodoTableViewController todoTableViewControllerWithStyle:TodoTableViewControllerStyleCellAndSection];
    _todoTableViewController.delegate = self;
    _todoTableViewController.headerHeight = self.headerHeight;
    [self addChildViewController:_todoTableViewController];
    [self.view addSubview:_todoTableViewController.tableView];
    
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.alpha = 0;
    
    self.headerView = [HeaderView headerViewWithAvatarPosition:HeaderAvatarPositionCenter titleAlignement:HeaderTitleAlignmentCenter];
    self.headerView.frame = CGRectMake(0, 0, kScreenWidth, self.headerHeight);
    self.headerView.subtitleLabel.text = [SGHelper localizedFormatDate:[NSDate date]];
    [self.headerView.rightOperationButton setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    [self.headerView.avatarButton sd_setImageWithURL:GetPictureUrl(super.lcUser.avatar, kQiniuImageStyleSmall) forState:UIControlStateNormal];
    self.headerView.backgroundImage = [UIImage imageAtResourcePath:@"header bg"];
    [self.headerView setHeaderViewDidPressAvatarButton:^{[SGHelper photoPickerFromTarget:weakSelf];}];
    [self.headerView setHeaderViewDidPressRightOperationButton:^{
        CreateViewController *createViewController = [[CreateViewController alloc] init];
        [createViewController setCreateViewControllerDidFinishCreate:^(CDTodo *model) {
            model.photoImage = [model.photoImage imageAddCornerWithRadius:model.photoImage.size.width / 2 andSize:model.photoImage.size];
            [weakSelf.todoTableViewController insertTodo:model];
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

#pragma mark - imagePicker delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *, id> *)info {
    UIImage *image = info[UIImagePickerControllerEditedImage];
    [picker dismissViewControllerAnimated:true completion:nil];
    __weak __typeof(self) weakSelf = self;
    [CommonDataManager modifyAvatarWithImage:image block:^{
        [weakSelf.headerView.avatarButton sd_setImageWithURL:GetPictureUrl(weakSelf.lcUser.avatar, kQiniuImageStyleSmall) forState:UIControlStateNormal];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:true completion:nil];
}


#pragma mark - retrieve data

- (void)retrieveDataFromServer {
    [_todoTableViewController retrieveDataWithUser:self.cdUser date:nil];
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
        
        //Mark: 我反正是不清楚为啥设置autoAdjustScrollViewInsets = NO是没有效果的，只能改约束，为了避免滚动条跳跃，设置其在alpha = 1时才显示
        [_todoTableViewController.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.right.left.offset(0);
            make.top.offset(alpha == 1 ? -64 : 0);
        }];
        
        [UIView animateWithDuration:.3 animations:^{
            self.titleLabel.text = self.headerView.titleLabel.text;
            self.titleLabel.alpha = 1;
        }];
    } else if (alpha != 1 && _isOpacityNavigation) {
        _isOpacityNavigation = NO;
        
        [_todoTableViewController.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.right.left.offset(0);
            make.top.offset(alpha == 1 ? -64 : 0);
        }];
        
        [UIView animateWithDuration:.3 animations:^{
            self.titleLabel.text = nil;
            self.titleLabel.alpha = 0;
        }];
    }
}

- (void)todoTableViewControllerDidReloadData {
    [self localizeStrings];
}
@end
