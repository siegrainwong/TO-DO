//
// Created by Siegrain on 16/11/2.
// Copyright (c) 2016 com.siegrain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Masonry.h"
#import "UIView+Extension.h"
#import <SDWebImage/UIButton+WebCache.h>
#import "UIImage+Extension.h"
#import "NSString+EMAdditions.h"

@protocol SGViews <NSObject>
- (void)setupViews;

- (void)bindConstraints;
@end

@protocol SGTableViews <SGViews>
@optional
- (NSString *)identifierAtIndexPath:(NSIndexPath *)indexPath;

- (NSObject *)modelAtIndexPath:(NSIndexPath *)indexPath;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

/*返回对应IndexPath下的图片URL*/
- (NSString *)imageUrlAtIndexPath:(NSIndexPath *)indexPath;

/*返回对应IndexPath下的图片Path*/
- (NSString *)imagePathAtIndexPath:(NSIndexPath *)indexPath;

/*加载完图片后调用*/
- (void)shouldDisplayImage:(UIImage *)image onCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

/*加载图片失败后调用*/
- (void)shouldDisplayPlaceholder:(UIImage *)placeholder onCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

/*当清空缓存后，MagicalRecord的瞬态字段还在内存中，要在这个方法中把模型中的图片字段给清空*/
- (void)shouldResetModelStateAtIndexPath:(NSIndexPath *)indexPath;
@end