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

static CGFloat const kCalendarOffset = 20;

@interface
CalendarViewController ()
@property(nonatomic, strong) UIView *calendarContainer;
@property(nonatomic, strong) FSCalendar *calendar;
@property(nonatomic, strong) TodoTableViewController *todoTableViewController;

@property(nonatomic, strong) MRTodoDataManager *dataManager;
@property(nonatomic, assign) BOOL isCalendarCollapsed;
@end

@implementation CalendarViewController
#pragma mark - release

- (void)dealloc {
    //Mark: 由于释放顺序的原因，导致TableView释放后KVO还没有移除，只有先移除HeaderView
    [_todoTableViewController.tableView.tableHeaderView removeFromSuperview];
    self.headerView = nil;
    DDLogWarn(@"%s", __func__);
}

#pragma mark - accessors

- (CGFloat)headerHeight {
    return kScreenWidth * 1.1f;
}

- (CGFloat)headerCollapseHeight {
    return self.headerHeight * 0.5f;
}

- (CGFloat)calendarHeight {
    return self.headerHeight - 64;
}

- (CGFloat)calendarCollapseHeight {
    return self.headerCollapseHeight - 64;
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
    
    self.headerView = [SGHeaderView headerViewWithAvatarPosition:HeaderAvatarPositionCenter titleAlignement:NSTextAlignmentCenter];
    [self.headerView.avatarButton setHidden:YES];
    [self.headerView.subtitleLabel setHidden:YES];
    self.headerView.subtitleLabel.text = [SGHelper localizedFormatDate:[NSDate date]];
    [self.headerView setImage:[UIImage imageAtResourcePath:@"calendar header bg"] style:HeaderMaskStyleDark];
    __weak typeof(self) weakSelf = self;
    [self.headerView setHeaderViewDidPressRightOperationButton:^{
        CreateViewController *createViewController = [[CreateViewController alloc] init];
        NSDate *selectedDate = [weakSelf.calendar.selectedDate compare:weakSelf.calendar.today] == NSOrderedSame ? [[NSDate date] dateByAddingTimeInterval:60 * 10] : weakSelf.calendar.selectedDate;
        [createViewController setSelectedDate:selectedDate];
        [createViewController setCreateViewControllerDidFinishCreate:^(CDTodo *model) {
            model.photoImage = [model.photoImage imageAddCornerWithRadius:model.photoImage.size.width / 2 andSize:model.photoImage.size];
            [weakSelf.calendar reloadData];
        }];
        [weakSelf.navigationController pushViewController:createViewController animated:YES];
    }];
    
    _calendarContainer = [UIView new];
    _calendarContainer.clipsToBounds = YES;
    [self.headerView addSubview:_calendarContainer];
    
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
    _calendar.appearance.headerTitleFont = [SGHelper themeFontNavBar];
    _calendar.appearance.titleFont = [SGHelper themeFontWithSize:15];
    _calendar.appearance.weekdayFont = [SGHelper themeFontWithSize:15];
    [_calendar selectDate:[NSDate date]];
    [_calendarContainer addSubview:_calendar];
    
    _todoTableViewController = [TodoTableViewController new];
    _todoTableViewController.style = TodoTableViewControllerStyleCalendar;
    _todoTableViewController.delegate = self;
    _todoTableViewController.headerHeight = self.headerHeight;
    _todoTableViewController.tableView.tableHeaderView = self.headerView;
    [self addChildViewController:_todoTableViewController];
    [self.view addSubview:_todoTableViewController.tableView];
    
    self.headerView.parallaxScrollView = _todoTableViewController.tableView;
    self.headerView.parallaxHeight = self.headerHeight;
    self.headerView.parallaxMinimumHeight = self.headerCollapseHeight;
    [self.headerView bringSubviewToFront:self.headerView.rightOperationButton];
}

- (void)bindConstraints {
    [super bindConstraints];
    
    [_todoTableViewController.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(-64);
        make.bottom.right.left.offset(0);
    }];
    
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.offset(CGFLOAT_MIN);
        make.width.offset(kScreenWidth);
        make.height.offset(self.headerHeight);
    }];
    
    [_calendarContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(5);
        make.right.offset(-5);
        make.top.offset(kCalendarOffset);
        make.height.offset(self.calendarHeight);
    }];
    
    [_calendar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.offset(0);
        make.height.offset(self.calendarHeight);
    }];
}

#pragma mark - retrieve data

- (void)retrieveDataFromServer:(NSDate *)date {
    [_todoTableViewController retrieveDataWithUser:self.cdUser date:date status:nil isComplete:nil keyword:nil];
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

#pragma mark - todo tableView controller delegate

- (void)tableViewDidScrollToY:(CGFloat)y {
    CGFloat offset = y + 64;
    [self setNavItemAlphaWithOffsetY:offset];
    [self setCalendarWithOffsetY:offset];
}

- (void)todoTableViewControllerDidReloadData {
    // 重新加载数据后，日历的位置在某些情况下需要修正
    [self tableViewDidScrollToY:-64];
}

- (void)todoTableViewControllerDidUpdateTodo {
    [_calendar reloadData];
}

#pragma mark - private methods

- (void)setNavItemAlphaWithOffsetY:(CGFloat)y {
    float alpha = y > 0 ? y >= self.headerCollapseHeight ? 0 : 1 - y / self.headerCollapseHeight : 1;
    self.leftNavigationButton.alpha = alpha;
    self.rightNavigationButton.alpha = alpha;
}

- (void)setCalendarWithOffsetY:(CGFloat)y {
    CGFloat collapseOffset = self.headerHeight - self.headerCollapseHeight;
    BOOL needsToCollapse = y >= collapseOffset;
    if (needsToCollapse && !_isCalendarCollapsed) {
        [_calendarContainer mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.offset(kCalendarOffset + collapseOffset);
            make.height.offset(self.calendarCollapseHeight);
        }];
        
        _isCalendarCollapsed = YES;
        [self setCalendarCollapsed:YES];
    } else if (!needsToCollapse) {
        if (_isCalendarCollapsed) {
            _isCalendarCollapsed = NO;
            [self setCalendarCollapsed:NO];
        }
        
        [_calendarContainer mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.offset(kCalendarOffset + y);
            make.height.offset(self.calendarHeight - y);
        }];
    }
}

- (void)setCalendarCollapsed:(BOOL)collapsed {
    [UIView animateWithDuration:.15 animations:^{
        [_calendar setScope:collapsed ? FSCalendarScopeWeek : FSCalendarScopeMonth animated:NO];
        _calendarContainer.alpha = 0;
    } completion:^(BOOL complete) {
        [UIView animateWithDuration:.15 animations:^{
            _calendarContainer.alpha = 1;
        } completion:^(BOOL complete) {
            [_calendar selectDate:_calendar.selectedDate scrollToDate:YES];
        }];
    }];
    //Mark: 为了让SectionHeader能够正确浮动在HeaderView下方，需要设置contentInset
    _todoTableViewController.tableView.contentInset = UIEdgeInsetsMake(collapsed ? self.headerCollapseHeight + 64 : 64, 0, 0, 0);
}
@end
