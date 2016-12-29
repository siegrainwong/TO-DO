//
// Created by Siegrain on 16/11/21.
// Copyright (c) 2016 com.siegrain. All rights reserved.
//

#import <SDAutoLayout/UITableView+SDAutoTableViewCellHeight.h>
#import "SGBaseSearchViewController.h"
#import "SGSearchBar.h"
#import "CDTodo.h"
#import "TodoTableViewCell.h"

@interface SGBaseSearchViewController ()
@property(nonatomic, strong) SGSearchBar *searchBar;
@property(strong, nonatomic) NSMutableArray<NSNumber *> *filteredResultIndexes;

@property(nonatomic, strong) Class cellClass;
@property(nonatomic, copy) NSArray<CDTodo *> *dataArray;
@property(nonatomic, copy) NSArray<NSString *> *keyPathsArray;
@end

@implementation SGBaseSearchViewController
#pragma mark - tableview

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.searchBar becomeFirstResponder];
}

- (void)setupViews {
    [super setupViews];
    
    self.navigationItem.rightBarButtonItem = nil;
    
    self.searchBar = [SGSearchBar searchBar];
    self.searchBar.delegate = self;
    self.tableView.tableHeaderView = self.searchBar;
    
    [self.dataSource registerClassForSearchTableView:self.tableView];
    self.cellClass = [self.dataSource cellClassForSearchTableView:self.tableView];
    self.dataArray = [self.dataSource dataArrayForSearchTableView];
    self.keyPathsArray = [self.dataSource searchKeyPathsForSearchTableView];
    self.filteredResultIndexes = [NSMutableArray new];
}

- (void)bindConstraints {
    [super bindConstraints];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.offset(0);
    }];
}

#pragma mark - tableview

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CDTodo * model = (CDTodo * )[self modelAtIndexPath:indexPath];
    if (!model.rowHeight) model.rowHeight = [tableView cellHeightForIndexPath:indexPath model:model keyPath:@"model" cellClass:self.cellClass contentViewWidth:kScreenWidth];
    return model.rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TodoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[self identifierAtIndexPath:indexPath] forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (NSString *)identifierAtIndexPath:(NSIndexPath *)indexPath {
    return [self.dataSource identifierAtIndexPath:indexPath forSearchTableView:self.tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredResultIndexes.count;
}

- (void)configureCell:(TodoTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.model = [self modelAtIndexPath:indexPath];
}

- (CDTodo *)modelAtIndexPath:(NSIndexPath *)indexPath {
    return self.dataArray[self.filteredResultIndexes[indexPath.row].unsignedIntegerValue];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - searchbar

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self.filteredResultIndexes removeAllObjects];
    if (!searchText.length) return [self.tableView reloadData];
    
    for (int i = 0; i < self.dataArray.count; i++) {
        for (NSString *keywordPath in self.keyPathsArray) {
            NSString *keyword = [self.dataArray[i] valueForKey:keywordPath];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@", searchText];
            if (![predicate evaluateWithObject:keyword]) continue;
            [self.filteredResultIndexes addObject:@(i)];
            break;  //有一个关键字符合就break，避免加入重复数据
        }
    }
    [self.tableView reloadData];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
    //Mark: 修改取消按钮文字
    UIButton *btn = [searchBar valueForKey:@"_cancelButton"];
    [btn setTitle:@"取消" forState:UIControlStateNormal];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.view endEditing:YES];
    [searchBar setShowsCancelButton:NO animated:YES];
}

@end