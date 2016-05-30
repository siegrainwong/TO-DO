//
//  JVLeftDrawerTableViewController.m
//  JVFloatingDrawer
//
//  Created by Julian Villella on 2015-01-15.
//  Copyright (c) 2015 JVillella. All rights reserved.
//

#import "AppDelegate.h"
#import "CalendarViewController.h"
#import "DrawerTableViewCell.h"
#import "DrawerTableViewController.h"
#import "HomeViewController.h"
#import "JVFloatingDrawerViewController.h"

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

static CGFloat const kTableViewTopInset = 80.0;
static NSString* const kDrawerCellReuseIdentifier = @"Identifier";

@implementation DrawerTableViewController {
    NSArray<NSDictionary*>* dataArray;
}
#pragma mark - localization
- (void)localizeStrings
{
    dataArray = @[
        @{ kDataKeyTitle : NSLocalizedString(@"Home", nil),
            kDataKeyIcon : @"",
            kDataKeyClass : [HomeViewController class] },
        @{ kDataKeyTitle : NSLocalizedString(@"Calendar", nil),
            kDataKeyIcon : @"",
            kDataKeyClass : [CalendarViewController class] }
    ];
}
#pragma mark - initial
- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setup];
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
    self.tableView.contentInset = UIEdgeInsetsMake(kTableViewTopInset, 0.0, 0.0, 0.0);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = 30;
    [self.tableView registerClass:[DrawerTableViewCell class] forCellReuseIdentifier:kDrawerCellReuseIdentifier];
    self.clearsSelectionOnViewWillAppear = NO;
}

#pragma mark - tableview
- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataArray.count;
}
- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    DrawerTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kDrawerCellReuseIdentifier forIndexPath:indexPath];

    [self configureCell:cell atIndexPath:indexPath];

    return cell;
}
- (void)configureCell:(DrawerTableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    NSDictionary* data = dataArray[indexPath.row];
    [cell setTitle:data[kDataKeyTitle]];
    if ([data[kDataKeyIcon] isKindOfClass:[UIImage class]])
        [cell setIcon:data[kDataKeyIcon]];
}
- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    UIViewController* destinationViewController = [dataArray[indexPath.row][kDataKeyClass] new];

    [[AppDelegate globalDelegate] switchRootViewController:destinationViewController isNavigation:YES];
    [[AppDelegate globalDelegate] toggleDrawer:self animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
