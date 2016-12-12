//
// Created by Siegrain on 16/11/21.
// Copyright (c) 2016 com.siegrain. All rights reserved.
//

#import "SGSegmentedController.h"

@interface SGSegmentedController ()
@end

@implementation SGSegmentedController

#pragma mark - accessors

- (CGFloat)pagerHeight {
    return kScreenHeight;
}

#pragma mark - initial

- (void)setupViews {
    // segmented pager
    _segmentedPager = [[MXSegmentedPager alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, self.pagerHeight)];
    _segmentedPager.delegate = self;
    _segmentedPager.dataSource = self;
    _segmentedPager.pager.gutterWidth = 8;
    
    //cover
    _segmentedPager.parallaxHeader.mode = MXParallaxHeaderModeFill;
    _segmentedPager.parallaxHeader.height = (CGFloat) (kScreenWidth * 0.65);
    _segmentedPager.parallaxHeader.minimumHeight = 0;
    
    // segmented control
    HMSegmentedControl *control = _segmentedPager.segmentedControl;
    control.type = HMSegmentedControlTypeText;
    control.segmentedImageTextPosition = HMSegmentedControlImageTextPositionDefault;
    control.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;
    control.backgroundColor = [SGHelper themeColorGray];
    control.verticalDividerEnabled = NO;
    
    control.selectionIndicatorColor = [SGHelper themeColorRed];
    control.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    control.selectionIndicatorHeight = 2;
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
    [super viewWillLayoutSubviews];
    
    /* Mark: SGSegmentedPager: 这段代码是iOS 8的兼容性代码 */
    _segmentedPager.frame = CGRectMake(0, 0, kScreenWidth, self.pagerHeight);
}

#pragma mark <MXSegmentedPagerDelegate>

- (CGFloat)heightForSegmentedControlInSegmentedPager:(MXSegmentedPager *)segmentedPager {
    return 60;
}

#pragma mark <MXSegmentedPagerDataSource>

- (NSInteger)numberOfPagesInSegmentedPager:(MXSegmentedPager *)segmentedPager {
    return _viewControllers.count;
}

- (NSAttributedString *)segmentedPager:(MXSegmentedPager *)segmentedPager attributedTitleForSectionAtIndex:(NSInteger)index {
    return _titleArray[index];
}

- (UIView *)segmentedPager:(MXSegmentedPager *)segmentedPager viewForPageAtIndex:(NSInteger)index {
    return _viewControllers[index];
}
@end
