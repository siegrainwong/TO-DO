//
//  JVLeftDrawerTableViewController.m
//  JVFloatingDrawer
//
//  Created by Julian Villella on 2015-01-15.
//  Copyright (c) 2015 JVillella. All rights reserved.
//

#import "AppDelegate.h"
#import "CalendarViewController.h"
#import "DGActivityIndicatorView.h"
#import "DrawerTableViewCell.h"
#import "DrawerTableViewController.h"
#import "HomeViewController.h"
#import "JVFloatingDrawerView.h"
#import "LoginViewController.h"
#import "Masonry.h"
#import "SyncDataManager.h"

typedef NS_ENUM(NSInteger, DrawerItem) {
    DrawerItemHome,
    DrawerItemCalendar,
    DrawerItemOverview,
    DrawerItemProfile,
    DrawerItemTimeline
};

static NSString* const kDataKeyTitle = @"title";
static NSString* const kDataKeyIcon = @"icon";
static NSString* const kDataKeyClass = @"class";

static NSString* const kDrawerCellReuseIdentifier = @"Identifier";
static NSInteger const kRowHeight = 40;
static NSInteger const kbottomViewHeight = 70;
static CGFloat const kSyncIndicatorSize = 15;

@interface
DrawerTableViewController ()
@property (nonatomic, readwrite, strong) SyncDataManager* dataManager;
@property (nonatomic, readwrite, strong) NSArray<NSDictionary*>* dataArray;

@property (nonatomic, readwrite, strong) UIView* bottomView;
@property (nonatomic, readwrite, strong) DGActivityIndicatorView* indicatorView;
@property (nonatomic, readwrite, strong) UIButton* leftBottomButton;
@property (nonatomic, readwrite, strong) UIButton* centerBottomButton;
@property (nonatomic, readwrite, strong) UIButton* rightBottomButton;
@end

@implementation DrawerTableViewController
#pragma mark - localization
- (void)localizeStrings
{
    _dataArray = @[
        @{ kDataKeyTitle : NSLocalizedString(@"Home", nil),
            kDataKeyIcon : @"",
            kDataKeyClass : [HomeViewController class] },
        @{ kDataKeyTitle : NSLocalizedString(@"Calendar", nil),
            kDataKeyIcon : @"",
            kDataKeyClass : [CalendarViewController class] }
    ];

    [_leftBottomButton setTitle:NSLocalizedString(@"SYNC", nil) forState:UIControlStateNormal];
    [_leftBottomButton setTitle:NSLocalizedString(@"SYNCING", nil) forState:UIControlStateDisabled];
    [_centerBottomButton setTitle:NSLocalizedString(@"SETTINGS", nil) forState:UIControlStateNormal];
    [_rightBottomButton setTitle:NSLocalizedString(@"LOGOUT", nil) forState:UIControlStateNormal];
}
#pragma mark - accessors
- (CGFloat)tableviewInsetTop
{
    return kScreenHeight * 0.18;
}
#pragma mark - initial
- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setup];
    [self bindConstraints];
    [self localizeStrings];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForItem:DrawerItemHome inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
}
- (void)setup
{
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.contentInset = UIEdgeInsetsMake([self tableviewInsetTop], 0.0, 0.0, 0.0);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.bounces = NO;
    self.tableView.clipsToBounds = NO;
    self.tableView.rowHeight = kRowHeight;
    [self.tableView registerClass:[DrawerTableViewCell class] forCellReuseIdentifier:kDrawerCellReuseIdentifier];
    self.clearsSelectionOnViewWillAppear = NO;

    _dataManager = [SyncDataManager dataManager];

    __weak UIImageView* bottomContainerView = [AppDelegate globalDelegate].drawerViewController.drawerView.backgroundImageView;
    [bottomContainerView setUserInteractionEnabled:YES];

    _bottomView = [UIView new];
    [bottomContainerView addSubview:_bottomView];

    UIColor* bottomItemColor = ColorWithRGB(0x999999);
    UIFont* bottomItemFont = [TodoHelper themeFontWithSize:13];

    _indicatorView = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeRotatingTrigons tintColor:bottomItemColor size:kSyncIndicatorSize];
    [_bottomView addSubview:_indicatorView];

    _leftBottomButton = [UIButton new];
    _leftBottomButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _leftBottomButton.titleLabel.font = bottomItemFont;
    [_leftBottomButton setTitleColor:bottomItemColor forState:UIControlStateNormal];
    [_leftBottomButton addTarget:self action:@selector(syncButtonDidPress) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_leftBottomButton];

    _centerBottomButton = [UIButton new];
    _centerBottomButton.titleLabel.font = bottomItemFont;
    [_centerBottomButton setTitleColor:bottomItemColor forState:UIControlStateNormal];
    [_centerBottomButton addTarget:self action:@selector(showSettings) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_centerBottomButton];

    _rightBottomButton = [UIButton new];
    _rightBottomButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    _rightBottomButton.titleLabel.font = bottomItemFont;
    [_rightBottomButton setTitleColor:bottomItemColor forState:UIControlStateNormal];
    [_rightBottomButton addTarget:self action:@selector(logOut) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_rightBottomButton];

    [bottomContainerView bringSubviewToFront:_bottomView];
}
- (void)bindConstraints
{
    __weak typeof(self) weakSelf = self;
    [_bottomView mas_makeConstraints:^(MASConstraintMaker* make) {
        make.left.offset(0);
        make.top.offset(kScreenHeight - kbottomViewHeight);
        make.height.offset(kbottomViewHeight);
        make.width.offset(kScreenWidth);
    }];

    CGFloat spaceFromView = [DrawerTableViewCell leftSpaceFromView];
    [_leftBottomButton mas_makeConstraints:^(MASConstraintMaker* make) {
        make.left.offset(spaceFromView);
        make.centerY.offset(0);
        make.width.offset(70);
        make.height.offset(30);
    }];

    // Mark: 这个菊花有时候位置不正常
    [_indicatorView mas_makeConstraints:^(MASConstraintMaker* make) {
        make.right.equalTo(weakSelf.leftBottomButton.mas_left).offset(-2);
        make.centerY.equalTo(weakSelf.leftBottomButton);
        make.height.width.offset(kSyncIndicatorSize);
    }];

    [_centerBottomButton mas_makeConstraints:^(MASConstraintMaker* make) {
        make.centerX.offset(0);
        make.baseline.equalTo(weakSelf.leftBottomButton);
        make.baseline.equalTo(weakSelf.leftBottomButton);
        make.width.height.equalTo(weakSelf.leftBottomButton);
    }];

    [_rightBottomButton mas_makeConstraints:^(MASConstraintMaker* make) {
        make.right.offset(-spaceFromView);
        make.baseline.equalTo(weakSelf.leftBottomButton);
        make.width.height.equalTo(weakSelf.leftBottomButton);
    }];
}
#pragma mark - sync button
- (void)syncButtonDidPress
{
    [self synchronize:SyncTypeManually];
}
#pragma mark - synchronize
- (void)synchronize:(SyncType)syncType
{
    dispatch_queue_t serialQueue = dispatch_queue_create("todoSynchronizeLock", DISPATCH_QUEUE_SERIAL);
    dispatch_sync(serialQueue, ^{
        [_indicatorView startAnimating];
        __weak typeof(self) weakSelf = self;
        [_dataManager synchronize:syncType complete:^(bool succeed) {
            [weakSelf.indicatorView stopAnimating];
        }];
    });
}
- (void)showSettings
{
    DDLogDebug(@"%s", __func__);
}
- (void)logOut
{
    [LCUser logOut];
    [[AppDelegate globalDelegate] toggleDrawer:self animated:YES];
    LoginViewController* loginViewController = [LoginViewController new];
    [[AppDelegate globalDelegate] switchRootViewController:loginViewController isNavigation:NO];
}
#pragma mark - tableview
- (NSInteger)tableView:(UITableView*)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}
- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    DrawerTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kDrawerCellReuseIdentifier forIndexPath:indexPath];

    [self configureCell:cell atIndexPath:indexPath];

    return cell;
}
- (void)configureCell:(DrawerTableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    NSDictionary* data = _dataArray[indexPath.row];
    [cell setTitle:data[kDataKeyTitle]];
    if ([data[kDataKeyIcon] isKindOfClass:[UIImage class]])
        [cell setIcon:data[kDataKeyIcon]];
}
- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    UIViewController* destinationViewController = [_dataArray[indexPath.row][kDataKeyClass] new];

    [[AppDelegate globalDelegate] switchRootViewController:destinationViewController isNavigation:YES];
    [[AppDelegate globalDelegate] toggleDrawer:self animated:YES];
}
@end