//
//  TodoTableViewController.h
//  TO-DO
//
//  Created by Siegrain on 16/5/31.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "SGBaseTableViewController.h"

@interface SGBaseTableViewController ()

/* Cell image loading queue */
@property(nonatomic, strong) NSMutableDictionary *imageDictionary;
@property(nonatomic, strong) NSMutableDictionary *operationDictionary;
@property(nonatomic, strong) NSOperationQueue *queue;
@end

@implementation SGBaseTableViewController

#pragma mark - initial & life cycle

- (void)viewDidLoad {
    _imageDictionary = [NSMutableDictionary new];
    _operationDictionary = [NSMutableDictionary new];
    _queue = [NSOperationQueue new];
    
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *path = [self imagePathAtIndexPath:indexPath];
    NSString *url = [self imageUrlAtIndexPath:indexPath];
    if (!url && !path) return;
    
    //加载本地图片
    if (path) {
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        if (image) {    //如果清空缓存的话，这个可能为空
            [self shouldDisplayImage:image onCell:cell atIndexPath:indexPath];
            return;
        }
    }
    
    //加载网络图片
    UIImage *image = _imageDictionary[url];
    if (!image) {                   //没有下载该图片
        NSOperation *operation = _operationDictionary[url];
        if (!operation) {           //没有当前图片的任务，就添加队列进行图片下载
            operation = [NSBlockOperation blockOperationWithBlock:^{
                ApplicationNetworkIndicatorVisible(YES);
                NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
                UIImage *imageFromData = [UIImage imageWithData:imageData];
                ApplicationNetworkIndicatorVisible(NO);
                
                _imageDictionary[url] = imageFromData;
                _operationDictionary[url] = nil;
                
                [[GCDQueue mainQueue] async:^{[self shouldDisplayImage:image onCell:cell atIndexPath:indexPath];}];
            }];
            [_queue addOperation:operation];
            _operationDictionary[url] = operation;
        } else {                    //正在下载中
            DDLogInfo(@"downloading");
        }
    } else {    //已有该图片
        [self shouldDisplayImage:image onCell:cell atIndexPath:indexPath];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [UITableViewCell new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - scroll view

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([_delegate respondsToSelector:@selector(tableViewDidScrollToY:)]) [_delegate tableViewDidScrollToY:scrollView.contentOffset.y];
}

#pragma mark - image loader

- (NSString *)imageUrlAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (NSString *)imagePathAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (void)shouldDisplayImage:(UIImage *)image onCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
}

@end
