//
// Created by Siegrain on 16/11/2.
// Copyright (c) 2016 com.siegrain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Masonry.h"
#import "UIView+Extension.h"

@protocol SGViews <NSObject>
- (void)setupViews;

- (void)bindConstraints;
@end

@protocol SGTableViews <SGViews>
@optional
- (NSString *)identifierAtIndexPath:(NSIndexPath *)indexPath;
- (NSObject *)modelAtIndexPath:(NSIndexPath *)indexPath;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end