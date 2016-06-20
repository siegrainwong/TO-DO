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
#import "MRTodoDataManager.h"
#import "NSDate+Extension.h"
#import "UIImage+Extension.h"

@interface
CalendarViewController ()
@property (nonatomic, readwrite, strong) FSCalendar* calendar;
@property (nonatomic, readwrite, strong) TodoTableViewController* todoTableViewController;
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
- (void)setupView
{
    [super setupView];

    _dataManager = [MRTodoDataManager new];

    self.view.backgroundColor = [UIColor whiteColor];

    _todoTableViewController = [TodoTableViewController todoTableViewControllerWithStyle:TodoTableViewControllerStyleWithoutSection];
    _todoTableViewController.delegate = self;
    [self addChildViewController:_todoTableViewController];
    [self.view addSubview:_todoTableViewController.tableView];

    self.headerView = [HeaderView headerViewWithAvatarPosition:HeaderAvatarPositionCenter titleAlignement:HeaderTitleAlignementCenter];
    [self.headerView.avatarButton setHidden:YES];
    [self.headerView.subtitleLabel setHidden:YES];
    self.headerView.subtitleLabel.text = [TodoHelper localizedFormatDate:[NSDate date]];
    [self.headerView.rightOperationButton setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    self.headerView.backgroundImageView.image = [UIImage imageAtResourcePath:@"calendar header bg"];
    __weak typeof(self) weakSelf = self;
    [self.headerView setHeaderViewDidPressRightOperationButton:^{
        weakSelf.releaseWhileDisappear = NO;
        CreateViewController* createViewController = [[CreateViewController alloc] init];
        [createViewController setCreateViewControllerDidFinishCreate:^(CDTodo* model) {
            model.photoImage = [model.photoImage imageAddCornerWithRadius:model.photoImage.size.width / 2 andSize:model.photoImage.size];
            [weakSelf.todoTableViewController insertTodo:model];
        }];
        [createViewController setCreateViewControllerDidDisappear:^{
            weakSelf.releaseWhileDisappear = YES;
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
    _calendar.appearance.headerTitleFont = [TodoHelper themeFontWithSize:17];
    _calendar.appearance.titleFont = [TodoHelper themeFontWithSize:15];
    _calendar.appearance.weekdayFont = [TodoHelper themeFontWithSize:15];
    _calendar.appearance.selectionColor = [UIColor whiteColor];
    _calendar.appearance.titleSelectionColor = [TodoHelper themeColorNormal];
    _calendar.appearance.todayColor = [TodoHelper themeColorNormal];
    [_calendar selectDate:[NSDate date]];
    [self.headerView addSubview:_calendar];

    [self.headerView bringSubviewToFront:self.headerView.rightOperationButton];
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
    if ((y > 64 && _calendar.scope == FSCalendarScopeWeek) || (y < 64 && _calendar.scope == FSCalendarScopeMonth)) return;
    BOOL isCollapsed = y > 64;

    [self.headerView mas_updateConstraints:^(MASConstraintMaker* make) { make.height.offset(kScreenHeight * (isCollapsed ? 0.25 : 0.6)); }];
    [UIView animateWithDuration:0.3 animations:^{
        self.leftNavigationButton.alpha = !isCollapsed;
        self.rightNavigationButton.alpha = !isCollapsed;
        self.headerView.rightOperationButton.alpha = !isCollapsed;
        _calendar.alpha = 0;
        [self.view layoutIfNeeded];
    }
    completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{ _calendar.alpha = 1; }];
        [_calendar setScope:y > 64 ? FSCalendarScopeWeek : FSCalendarScopeMonth animated:NO];
    }];
}
@end
