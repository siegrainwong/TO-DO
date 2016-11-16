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
#import "UITableView+Extension.h"
#import "CommonDataManager.h"

// TODO: 搜索功能
// TODO: 待办事项展开功能
// TODO: Calendar页面下，日历收起时滑动会很卡
// TODO: Canlendar页面下要显示完成和未完成的任务
// TODO: 导航栏不透明时，需要把+号按钮添加到导航栏上。
// TODO: HeaderView上的花式屏幕分辨率问题


// Mark: 再不能全局变量都用成员变量了，内存释放太操心

@interface
HomeViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property(nonatomic, readwrite, strong) TodoTableViewController *todoTableViewController;
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
    return kScreenWidth * 1.1f;
}

#pragma mark - initial

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self localizeStrings];
    [self retrieveDataFromServer];
}

- (void)setupViews {
    [super setupViews];
    
    __weak typeof(self) weakSelf = self;
    
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.alpha = 0;
    
    self.headerView = [SGHeaderView headerViewWithAvatarPosition:HeaderAvatarPositionCenter titleAlignement:HeaderTitleAlignmentCenter];
    self.headerView.subtitleLabel.text = [SGHelper localizedFormatDate:[NSDate date]];
    [self.headerView.rightOperationButton setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    [self.headerView.avatarButton sd_setImageWithURL:GetPictureUrl(super.lcUser.avatar, kQiniuImageStyleSmall) forState:UIControlStateNormal];
    self.headerView.image = [UIImage imageAtResourcePath:@"header bg"];
    [self.headerView setHeaderViewDidPressAvatarButton:^{[SGHelper photoPickerFromTarget:weakSelf];}];
    [self.headerView setHeaderViewDidPressRightOperationButton:^{
        CreateViewController *createViewController = [[CreateViewController alloc] init];
        [createViewController setCreateViewControllerDidFinishCreate:^(CDTodo *model) {
            model.photoImage = [model.photoImage imageAddCornerWithRadius:model.photoImage.size.width / 2 andSize:model.photoImage.size];
            [weakSelf.todoTableViewController insertTodo:model];
        }];
        [weakSelf.navigationController pushViewController:createViewController animated:YES];
    }];
    
    _todoTableViewController = [TodoTableViewController todoTableViewControllerWithStyle:TodoTableViewControllerStyleHome];
    _todoTableViewController.delegate = self;
    _todoTableViewController.headerHeight = self.headerHeight;
    _todoTableViewController.tableView.tableHeaderView = self.headerView;
    [self addChildViewController:_todoTableViewController];
    [self.view addSubview:_todoTableViewController.tableView];
    
    self.headerView.parallaxScrollView = _todoTableViewController.tableView;
    self.headerView.parallaxHeight = self.headerHeight;
    self.headerView.parallaxMode = SGParallaxModeScaleToFill;
}

- (void)bindConstraints {
    [super bindConstraints];
    
    [_todoTableViewController.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(-64);
        make.bottom.right.left.offset(0);
    }];
    
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.offset(CGFLOAT_MIN);
        make.width.offset(kScreenWidth);
        make.height.offset(self.headerHeight);
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

- (void)todoTableViewControllerDidReloadData {
    [self localizeStrings];
}
@end
