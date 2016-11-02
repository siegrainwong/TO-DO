//
// Created by Siegrain on 16/11/2.
// Copyright (c) 2016 com.siegrain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Masonry.h"
#import "UIView+Extension.h"

@protocol SGViews <NSObject>
- (void)setupView;
- (void)bindConstraints;
@end