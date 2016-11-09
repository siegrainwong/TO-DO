//
//  CalendarViewController.m
//  TO-DO
//
//  Created by Siegrain on 16/5/30.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "CDTodo.h"
#import "CalendarViewController.h"
#import "CreateViewController.h"
#import "DateUtil.h"
#import "GCDQueue.h"
#import "MRTodoDataManager.h"
#import "NSDate+Extension.h"
#import "UIImage+Extension.h"

@interface
CalendarViewController ()
@property (nonatomic, readwrite, strong) FSCalendar* calendar;
@property (nonatomic, readwrite, strong) TodoTableViewController* todoTableViewController;
@property (nonatomic, readwrite, strong) UIButton* menuButton;

@property (nonatomic, readwrite, strong) MRTodoDataManager* dataManager;
@property (nonatomic, readwrite, assign) BOOL isCalendarCollapsed;

@end

// TODO:日历收缩

@implementation CalendarViewController
#pragma mark - initial
- (void)viewDidLoad
{
    [super viewDidLoad];

    [self retrieveDataFromServer:[_calendar today]];
}
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}
- (void)setupViews
{
    [super setupViews];

    _dataManager = [MRTodoDataManager new];

    self.view.backgroundColor = [UIColor whiteColor];

    _todoTableViewController = [TodoTableViewController todoTableViewControllerWithStyle:TodoTableViewControllerStyleWithoutSection];
    _todoTableViewController.delegate = self;
    [self addChildViewController:_todoTableViewController];
    [self.view addSubview:_todoTableViewController.tableView];

    self.headerView = [HeaderView headerViewWithAvatarPosition:HeaderAvatarPositionCenter titleAlignement:HeaderTitleAlignmentCenter];
    [self.headerView.avatarButton setHidden:YES];
    [self.headerView.subtitleLabel setHidden:YES];
    self.headerView.subtitleLabel.text = [SGHelper localizedFormatDate:[NSDate date]];
    [self.headerView.rightOperationButton setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    self.headerView.backgroundImage = [UIImage imageAtResourcePath:@"calendar header bg"];
    __weak typeof(self) weakSelf = self;
    [self.headerView setHeaderViewDidPressRightOperationButton:^{
        CreateViewController* createViewController = [[CreateViewController alloc] init];
        [createViewController setCreateViewControllerDidFinishCreate:^(CDTodo* model) {
            model.photoImage = [model.photoImage imageAddCornerWithRadius:model.photoImage.size.width / 2 andSize:model.photoImage.size];
            [weakSelf.todoTableViewController insertTodo:model];
        }];
        [createViewController setCreateViewControllerDidDisappear:^{
        }];
        [weakSelf.navigationController pushViewController:createViewController animated:YES];
    }];
    [self.view addSubview:self.headerView];

    _calendar = [FSCalendar new];
    _calendar.delegate = self;
    _calendar.dataSource = self;
    _calendar.scrollDirection = FSCalendarScrollDirectionVertical;
    _calendar.headerHeight = 40;
    [_calendar.bottomBorder setHidden:YES];
    _calendar.appearance.adjustsFontSizeToFitContentSize = NO;
    _calendar.appearance.headerTitleColor = [UIColor whiteColor];
    _calendar.appearance.titleDefaultColor = [UIColor whiteColor];
    _calendar.appearance.weekdayTextColor = [UIColor whiteColor];
    _calendar.appearance.headerTitleFont = [SGHelper themeFontWithSize:17];
    _calendar.appearance.titleFont = [SGHelper themeFontWithSize:15];
    _calendar.appearance.weekdayFont = [SGHelper themeFontWithSize:15];
    _calendar.appearance.selectionColor = [UIColor whiteColor];
    _calendar.appearance.titleSelectionColor = [SGHelper themeColorRed];
    _calendar.appearance.todayColor = [SGHelper themeColorRed];
    [_calendar selectDate:[NSDate date]];
    [self.headerView addSubview:_calendar];

    [self.headerView bringSubviewToFront:self.headerView.rightOperationButton];

    _menuButton = [UIButton new];
    [_menuButton setBackgroundImage:[UIImage imageNamed:@"menu-button2"] forState:UIControlStateNormal];
    [_menuButton addTarget:self action:@selector(menuButtonDidPress) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_menuButton];
}
- (void)bindConstraints
{
    [super bindConstraints];

    [self.headerView mas_makeConstraints:^(MASConstraintMaker* make) {
        make.top.left.offset(0);
        make.width.offset(kScreenWidth);
        make.height.offset(kScreenHeight * 0.6);
    }];

    [_calendar mas_makeConstraints:^(MASConstraintMaker* make) {
        make.left.offset(10);
        make.right.offset(-10);
        make.top.offset(20);
        make.height.offset(kScreenHeight * 0.47);
    }];

    [_todoTableViewController.tableView mas_makeConstraints:^(MASConstraintMaker* make) {
        make.top.equalTo(self.headerView.mas_bottom);
        make.bottom.right.left.offset(0);
    }];

    [_menuButton mas_makeConstraints:^(MASConstraintMaker* make) {
        make.bottom.offset(-10);
        make.right.offset(-10);
        make.width.height.offset(kScreenHeight * 0.08);
    }];
}
#pragma mark - retrieve data
- (void)retrieveDataFromServer:(NSDate*)date
{
    [_todoTableViewController retrieveDataWithUser:self.cdUser date:date];
}
#pragma mark - calendar delegate
- (void)calendar:(FSCalendar*)calendar didSelectDate:(NSDate*)date
{
    [self retrieveDataFromServer:date];
}
#pragma mark - calendar appearance
/* 在包含待办事项的日期上加上灰色圈儿 */
- (UIColor*)calendar:(FSCalendar*)calendar appearance:(FSCalendarAppearance*)appearance borderDefaultColorForDate:(NSDate*)date
{
    if ([_dataManager hasDataWithDate:date user:self.cdUser] && [date compare:_calendar.today] != NSOrderedSame) return ColorWithRGB(0xBBBBBB);

    return nil;
}
#pragma mark - todo tableview controller delegate
/* 滚动时切换日历状态 */
- (void)todoTableViewDidScrollToY:(CGFloat)y
{
    CGFloat collapseTriggerDistance = kScreenHeight * 0.8;
    if ((y > collapseTriggerDistance && _calendar.scope == FSCalendarScopeWeek) || (y < collapseTriggerDistance && _calendar.scope == FSCalendarScopeMonth)) return;
    BOOL isCollapsed = y > collapseTriggerDistance;

    [self.headerView mas_updateConstraints:^(MASConstraintMaker* make) { make.height.offset(kScreenHeight * (isCollapsed ? 0.25 : 0.6)); }];
    [UIView animateWithDuration:0.3 animations:^{
        self.leftNavigationButton.alpha = !isCollapsed;
        self.rightNavigationButton.alpha = !isCollapsed;
        self.headerView.rightOperationButton.alpha = !isCollapsed;
        _calendar.alpha = 0;
        [self.view layoutIfNeeded];
    }
    completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{ _calendar.alpha = 1; } completion:^(BOOL finished) {
            [_calendar setScope:isCollapsed ? FSCalendarScopeWeek : FSCalendarScopeMonth animated:NO];
        }];
        //		[UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveLinear animations:^{
        //			//TODO: 添加弹跳动画...
        //		}
        //						 completion:nil];
    }];
}
#pragma mark - menu button
- (void)menuButtonDidPress
{
}
@end
