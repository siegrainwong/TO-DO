//
//  TodoTableViewController.h
//  TO-DO
//
//  Created by Siegrain on 16/5/31.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "SGBaseTableViewController.h"

@interface SGBaseTableViewController ()
@end

@implementation SGBaseTableViewController

#pragma mark - initial & life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupViews];
    [self bindConstraints];
}

- (void)setupViews {
    self.tableView.tableFooterView = [UIView new];
}

- (void)bindConstraints {
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end
