//
//  CalendarViewController.m
//  TO-DO
//
//  Created by Siegrain on 16/5/30.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "CalendarViewController.h"
#import "CreateViewController.h"
#import "DateUtil.h"
#import "HSDatePickerViewController+Configure.h"
#import "HomeDataManager.h"
#import "HomeViewController.h"
#import "LCTodo.h"
#import "Macros.h"
#import "NSDate+Extension.h"
#import "TodoHeaderCell.h"
#import "TodoTableViewCell.h"
#import "UIButton+WebCache.h"
#import "UIImage+Extension.h"
#import "UIImage+Qiniu.h"
#import "UINavigationController+Transparent.h"
#import "UIScrollView+Extension.h"
#import "UITableView+Extension.h"
#import "UITableView+SDAutoTableViewCellHeight.h"

@interface
CalendarViewController ()
@property (nonatomic, readwrite, strong) UITableView* tableView;
@property (nonatomic, readwrite, strong) FSCalendar* calendar;
@end

@implementation CalendarViewController
#pragma mark - initial
- (void)viewDidLoad
{
    [super viewDidLoad];

    //	dataDictionary = [NSMutableDictionary new];
    //	dateArray = [NSMutableArray new];
    //	_dataManager = [HomeDataManager new];

    //    [self localizeStrings];
    //	[self retrieveDataFromServer];
}
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    [_tableView ignoreNavigationHeight];
}
- (void)setupView
{
    [super setupView];

    self.view.backgroundColor = [UIColor whiteColor];

    _tableView = [UITableView new];
    _tableView.bounces = NO;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.sectionHeaderHeight = 15;
    [_tableView registerClass:[TodoTableViewCell class] forCellReuseIdentifier:kTodoIdentifierArray[TodoIdentifierNormal]];
    _tableView.separatorInset = UIEdgeInsetsMake(0, kScreenHeight * kCellHorizontalInsetsMuiltipledByHeight, 0, kScreenHeight * kCellHorizontalInsetsMuiltipledByHeight);
    [self.view addSubview:_tableView];

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
        [createViewController setCreateViewControllerDidDisappear:^{
            weakSelf.releaseWhileDisappear = YES;
        }];
        [weakSelf.navigationController pushViewController:createViewController animated:YES];
    }];
    //    _tableView.tableHeaderView = self.headerView;
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
    _calendar.appearance.titleFont = [TodoHelper themeFontWithSize:14];
    _calendar.appearance.weekdayFont = [TodoHelper themeFontWithSize:14];

    _calendar.appearance.selectionColor = [UIColor whiteColor];
    _calendar.appearance.titleSelectionColor = [TodoHelper themeColorNormal];

    _calendar.appearance.todayColor = [TodoHelper themeColorNormal];
    [self.headerView addSubview:_calendar];

    [self.headerView bringSubviewToFront:self.headerView.rightOperationButton];
}
- (void)bindConstraints
{
    [super bindConstraints];

    [self.headerView mas_makeConstraints:^(MASConstraintMaker* make) {
        make.top.left.offset(0);
        make.width.offset(kScreenWidth);
        make.height.offset(kScreenHeight * 0.7);
    }];

    [_calendar mas_makeConstraints:^(MASConstraintMaker* make) {
        make.left.offset(10);
        make.right.offset(-10);
        make.top.offset(20);
        make.height.offset(kScreenHeight * 0.57);
    }];

    [_tableView mas_makeConstraints:^(MASConstraintMaker* make) {
        make.top.equalTo(self.headerView.mas_bottom);
        make.bottom.right.left.offset(0);
    }];
}
#pragma mark - tableview
#pragma mark - tableview datasource
- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}
- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return [UITableViewCell new];
}
#pragma mark -
- (UIColor*)calendar:(FSCalendar*)calendar appearance:(FSCalendarAppearance*)appearance borderDefaultColorForDate:(NSDate*)date
{
    if ([date.stringInYearMonthDay isEqualToString:@"2016-05-30"])
        return ColorWithRGB(0xBBBBBB);

    return nil;
}
@end
