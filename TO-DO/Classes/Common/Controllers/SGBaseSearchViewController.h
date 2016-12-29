//
// Created by Siegrain on 16/11/21.
// Copyright (c) 2016 com.siegrain. All rights reserved.
//

#import "SGBaseTableViewController.h"

@protocol SGBaseSearchViewControllerDataSource <NSObject>
/* 在该方法中对tableView调用registerClass:forReuseIdentifier方法进行注册 */
- (void)registerClassForSearchTableView:(UITableView *)tableView;
/* 该tableView中使用的cell的Class */
- (Class)cellClassForSearchTableView:(UITableView *)tableView;
/**
 * 重用标示
 * @param indexPath
 * @param tableView
 * @return
 */
- (NSString *)identifierAtIndexPath:(NSIndexPath *)indexPath forSearchTableView:(UITableView *)tableView;
/**
 * 要检索的数据源
 * @return
 */
- (NSArray<CDTodo *> *)dataArrayForSearchTableView;
/**
 * 要检索的数据模型的keyPath
 * @return
 */
- (NSArray<NSString *> *)searchKeyPathsForSearchTableView;
@end

@interface SGBaseSearchViewController : SGBaseTableViewController<UISearchBarDelegate>
@property(nonatomic, weak) id <SGBaseSearchViewControllerDataSource> dataSource;
@end