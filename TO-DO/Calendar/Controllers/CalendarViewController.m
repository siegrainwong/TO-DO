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
#import "MRTodoDataManager.h"
#import "UIImage+Extension.h"

@interface
CalendarViewController ()
@property(nonatomic, strong) FSCalendar *calendar;
@property(nonatomic, strong) TodoTableViewController *todoTableViewController;
@property(nonatomic, strong) UIButton *menuButton;

@property(nonatomic, strong) MRTodoDataManager *dataManager;

@end

@implementation CalendarViewController
#pragma mark - accessors

- (CGFloat)headerHeight {
    return kScreenWidth * 0.85;
}

- (CGFloat)headerCollapseHeight {
    return self.headerHeight * 0.36;
}

#pragma mark - initial

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _dataManager = [MRTodoDataManager new];
    [self retrieveDataFromServer:[_calendar today]];
}

- (void)setupViews {
    [super setupViews];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.headerView = [SGHeaderView headerViewWithAvatarPosition:HeaderAvatarPositionCenter titleAlignement:HeaderTitleAlignmentCenter];
    [self.headerView.avatarButton setHidden:YES];
    [self.headerView.subtitleLabel setHidden:YES];
    self.headerView.subtitleLabel.text = [SGHelper localizedFormatDate:[NSDate date]];
    [self.headerView.rightOperationButton setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    self.headerView.backgroundImage = [UIImage imageAtResourcePath:@"calendar header bg"];
    __weak typeof(self) weakSelf = self;
    [self.headerView setHeaderViewDidPressRightOperationButton:^{
        CreateViewController *createViewController = [[CreateViewController alloc] init];
        [createViewController setCreateViewControllerDidFinishCreate:^(CDTodo *model) {
            model.photoImage = [model.photoImage imageAddCornerWithRadius:model.photoImage.size.width / 2 andSize:model.photoImage.size];
            [weakSelf.todoTableViewController insertTodo:model];
        }];
        [weakSelf.navigationController pushViewController:createViewController animated:YES];
    }];
    
    _calendar = [FSCalendar new];
    _calendar.delegate = self;
    _calendar.dataSource = self;
    _calendar.scrollDirection = FSCalendarScrollDirectionVertical;
    _calendar.headerHeight = 40;
    _calendar.appearance.adjustsFontSizeToFitContentSize = NO;
    _calendar.appearance.headerTitleColor = [UIColor whiteColor];
    _calendar.appearance.titleDefaultColor = [UIColor whiteColor];
    _calendar.appearance.weekdayTextColor = [UIColor whiteColor];
    _calendar.appearance.selectionColor = [UIColor whiteColor];
    _calendar.appearance.titleSelectionColor = [SGHelper themeColorRed];
    _calendar.appearance.todayColor = [SGHelper themeColorRed];
    _calendar.appearance.headerTitleFont = [SGHelper themeFontWithSize:17];
    _calendar.appearance.titleFont = [SGHelper themeFontWithSize:15];
    _calendar.appearance.weekdayFont = [SGHelper themeFontWithSize:15];
    [_calendar selectDate:[NSDate date]];
    [self.headerView addSubview:_calendar];
    
    _todoTableViewController = [TodoTableViewController todoTableViewControllerWithStyle:TodoTableViewControllerStyleCalendar];
    _todoTableViewController.delegate = self;
    _todoTableViewController.headerHeight = self.headerHeight;
    _todoTableViewController.tableView.tableHeaderView = self.headerView;
    [self addChildViewController:_todoTableViewController];
    [self.view addSubview:_todoTableViewController.tableView];
    
    self.headerView.parallaxScrollView = _todoTableViewController.tableView;
    self.headerView.parallaxHeight = self.headerHeight;
    self.headerView.parallaxMinimumHeight = self.headerCollapseHeight + 64;
    [self.headerView bringSubviewToFront:self.headerView.rightOperationButton];

//    _menuButton = [UIButton new];
//    [_menuButton setBackgroundImage:[UIImage imageNamed:@"menu-button2"] forState:UIControlStateNormal];
//    [_menuButton addTarget:self action:@selector(menuButtonDidPress) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:_menuButton];
}

- (void)bindConstraints {
    [super bindConstraints];
    
    [_todoTableViewController.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.right.left.offset(0);
    }];
    
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.offset(0);
        make.width.offset(kScreenWidth);
        make.height.offset(self.headerHeight);
    }];
    
    [_calendar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(10);
        make.right.offset(-10);
        make.top.offset(-44);
        make.height.offset(self.headerHeight);
    }];

//    [_menuButton mas_makeConstraints:^(MASConstraintMaker* make) {
//        make.bottom.offset(-10);
//        make.right.offset(-10);
//        make.width.height.offset(kScreenHeight * 0.08);
//    }];
}

#pragma mark - retrieve data

- (void)retrieveDataFromServer:(NSDate *)date {
    [_todoTableViewController retrieveDataWithUser:self.cdUser date:date];
}

#pragma mark - calendar delegate

- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date {
    [self retrieveDataFromServer:date];
}

#pragma mark - calendar appearance

/* 在包含待办事项的日期上加上灰色圈儿 */
- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance borderDefaultColorForDate:(NSDate *)date {
    if ([_dataManager hasDataWithDate:date user:self.cdUser] && [date compare:_calendar.today] != NSOrderedSame) return ColorWithRGB(0xBBBBBB);
    
    return nil;
}

#pragma mark - todo tableview controller delegate

/* 滚动时切换日历状态 */
- (void)todoTableViewDidScrollToY:(CGFloat)y {
    [self toggleCalendarWithOffsetY:y];
    [self setNavItemAlphaWithOffsetY:y];
}

- (void)setNavItemAlphaWithOffsetY:(CGFloat)y {
    CGFloat collapseTriggerDistance = self.headerCollapseHeight + 64;
    float offsetY = y + 64;
    float alpha = offsetY > 0 ? offsetY >= collapseTriggerDistance ? 0 : 1 - offsetY / collapseTriggerDistance : 1;
    self.leftNavigationButton.alpha = alpha;
    self.rightNavigationButton.alpha = alpha;
}

- (void)toggleCalendarWithOffsetY:(CGFloat)y {
    CGFloat collapseTriggerDistance = self.headerCollapseHeight + 64;
    if ((y > collapseTriggerDistance && _calendar.scope == FSCalendarScopeWeek) || (y < collapseTriggerDistance && _calendar.scope == FSCalendarScopeMonth)) return;
    BOOL isCollapsed = y > collapseTriggerDistance;
    
    [_calendar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.offset(isCollapsed ? self.headerHeight - self.headerCollapseHeight - 44 : -44);
        make.height.offset(isCollapsed ? self.headerCollapseHeight : self.headerHeight);
    }];
    
    _calendar.alpha = 0;
    [UIView animateWithDuration:.3 animations:^{
        [_calendar layoutIfNeeded];
        _calendar.alpha = 1;
    } completion:^(BOOL complete) {
        [_calendar setScope:isCollapsed ? FSCalendarScopeWeek : FSCalendarScopeMonth animated:NO];
    }];
}

#pragma mark - menu button

- (void)menuButtonDidPress {
}
@end
