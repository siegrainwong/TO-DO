//
// Created by Siegrain on 16/11/21.
// Copyright (c) 2016 com.siegrain. All rights reserved.
//

#import "SGSegmentedController.h"

@interface SGSegmentedController ()
@end

@implementation SGSegmentedController

#pragma mark - accessors

- (CGRect)pagerFrame {
    return CGRectMake(0, 0, kScreenWidth, self.pagerHeight);
}

- (CGFloat)pagerHeight {
    return kScreenHeight;
}

#pragma mark - initial

- (void)setupViews {
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    // segmented pager
    _segmentedPager = [[MXSegmentedPager alloc] initWithFrame:self.pagerFrame];
    _segmentedPager.delegate = self;
    _segmentedPager.dataSource = self;
    _segmentedPager.pager.gutterWidth = 0;
    
    //cover
    _segmentedPager.parallaxHeader.mode = MXParallaxHeaderModeFill;
    _segmentedPager.parallaxHeader.height = (CGFloat) (kScreenWidth * 0.65);
    
    // segmented control
    HMSegmentedControl *control = _segmentedPager.segmentedControl;
    control.type = HMSegmentedControlTypeText;
    control.selectionStyle = HMSegmentedControlSelectionStyleArrow;
    control.verticalDividerEnabled = NO;
    
    control.selectionIndicatorColor = [SGHelper themeColorLightGray];
    control.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    control.selectionIndicatorHeight = 10;
    control.selectionIndicatorEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 20);
    
    UIFont *fontForControl = [UIFont systemFontOfSize:kScreenWidth * 0.039];
    control.titleTextAttributes = @{NSForegroundColorAttributeName: [SGHelper themeColorLightGray], NSFontAttributeName: fontForControl};
    control.selectedTitleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: fontForControl};
    
    [self.view addSubview:_segmentedPager];
    
    [super setupViews];
}

- (void)bindConstraints {
}

- (void)viewWillLayoutSubviews {
    _segmentedPager.frame = CGRectMake(0, 0, kScreenWidth, self.pagerHeight);
    [super viewWillLayoutSubviews];
}

#pragma mark <MXSegmentedPagerDelegate>

- (CGFloat)heightForSegmentedControlInSegmentedPager:(MXSegmentedPager *)segmentedPager {
    return 20;
}

#pragma mark <MXSegmentedPagerDataSource>

- (NSInteger)numberOfPagesInSegmentedPager:(MXSegmentedPager *)segmentedPager {
    return _views.count;
}

- (NSAttributedString *)segmentedPager:(MXSegmentedPager *)segmentedPager attributedTitleForSectionAtIndex:(NSInteger)index {
    return _titles[index];
}

- (UIView *)segmentedPager:(MXSegmentedPager *)segmentedPager viewForPageAtIndex:(NSInteger)index {
    return _views[index];
}
@end
