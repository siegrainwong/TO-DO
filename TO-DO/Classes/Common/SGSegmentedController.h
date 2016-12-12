//
// Created by Siegrain on 16/11/21.
// Copyright (c) 2016 com.siegrain. All rights reserved.
//

#import "MXSegmentedPager.h"
#import "SGBaseViewController.h"

@interface SGSegmentedController : SGBaseViewController <MXSegmentedPagerDelegate, MXSegmentedPagerDataSource>
@property(nonatomic, strong) MXSegmentedPager *segmentedPager;

@property(nonatomic, copy) NSArray<UIViewController *> *viewControllers;
@property(nonatomic, copy) NSArray<NSAttributedString *> *titleArray;

- (CGFloat)pagerHeight;
@end
