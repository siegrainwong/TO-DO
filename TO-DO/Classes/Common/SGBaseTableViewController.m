//
//  SGFilterTableViewController.m
//  GamePlatform
//
//  Created by Siegrain on 16/8/19.
//  Copyright © 2016年 com.lurenwang.gameplatform. All rights reserved.
//

#import "SGBaseTableViewController.h"

@interface
SGBaseTableViewController ()
@end

@implementation SGBaseTableViewController

#pragma mark - initial & life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)setupViews {
    [super setupViews];
    
    _tableView = [UITableView new];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [UIView new];
    [self.view addSubview:_tableView];
}

- (void)bindConstraints {
    [super bindConstraints];
}

#pragma mark - tableview

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [UITableViewCell new];
}

- (NSString *)identifierAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end
