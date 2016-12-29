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
        [[GCDQueue globalQueueWithLevel:DISPATCH_QUEUE_PRIORITY_DEFAULT] async:^{
            UIImage *image = [UIImage imageWithContentsOfFile:path];
            if (image) {    //清空缓存之后，这个就是空的
                [[GCDQueue mainQueue] async:^{
                    [self shouldDisplayImage:image onCell:cell atIndexPath:indexPath];
                }];
                return;
            }
        }];
    }
    
    UIImage *image = _imageDictionary[url];
    if (!image) {
        __weak __typeof(self) weakSelf = self;
        [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:url] options:SDWebImageRefreshCached progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            if (cacheType == SDImageCacheTypeMemory) [weakSelf shouldResetModelStateAtIndexPath:indexPath];
            [weakSelf shouldDisplayImage:image onCell:cell atIndexPath:indexPath];
            _imageDictionary[url] = image;
        }];
    } else {
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

- (void)shouldResetModelStateAtIndexPath:(NSIndexPath *)indexPath {
}

@end
