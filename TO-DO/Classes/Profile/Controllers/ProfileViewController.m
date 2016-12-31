//
// Created by Siegrain on 16/12/12.
// Copyright (c) 2016 com.siegrain. All rights reserved.
//

#import "ProfileViewController.h"
#import "TodoTableViewController.h"

static CGFloat const kSegmentedControlHeight = 90;
static CGFloat const kParallaxHeaderMinimumHeight = 64;

@interface ProfileViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, TodoTableViewControllerDelegate>
@property(nonatomic, strong) TodoTableViewController *completedTableViewController;
@property(nonatomic, strong) TodoTableViewController *snoozedTableViewController;
@property(nonatomic, strong) TodoTableViewController *overdueTableViewController;

@property(nonatomic, assign) BOOL titleIsShowing;
@end

@implementation ProfileViewController

#pragma mark - accessors

- (CGFloat)headerHeight {
    return (CGFloat) (kScreenWidth * 0.75);
}

#pragma mark - initial

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self retrieveData];
}

- (void)setupViews {
    // segment view controllers
    _completedTableViewController = [TodoTableViewController new];
    [self addChildViewController:_completedTableViewController];
    _snoozedTableViewController = [TodoTableViewController new];
    [self addChildViewController:_snoozedTableViewController];
    _overdueTableViewController = [TodoTableViewController new];
    [self addChildViewController:_overdueTableViewController];
    
    _completedTableViewController.style = _snoozedTableViewController.style = _overdueTableViewController.style = TodoTableViewControllerStyleHome;
    _completedTableViewController.disableCellSwiping = _snoozedTableViewController.disableCellSwiping = _overdueTableViewController.disableCellSwiping = YES;
    _completedTableViewController.headerHeight = _snoozedTableViewController.headerHeight = _overdueTableViewController.headerHeight = self.headerHeight + kSegmentedControlHeight;
    
    self.views = @[_completedTableViewController.tableView, _snoozedTableViewController.tableView, _overdueTableViewController.tableView];
    self.titles = @[@"COMPLETED".attributedString, @"SNOOZED".attributedString, @"OVERDUE".attributedString];
    
    [super setupViews];
    
    //nav title label
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.text = self.cdUser.name;
    self.titleLabel.alpha = 0;
    
    __weak __typeof(self) weakSelf = self;
    //header
    self.headerView = [SGHeaderView headerViewWithAvatarPosition:HeaderAvatarPositionBottom titleAlignement:NSTextAlignmentCenter];
    self.headerView.titleLabel.text = self.cdUser.name;
    self.headerView.subtitleLabel.text = self.cdUser.email;
    [self.headerView.rightOperationButton setHidden:YES];
    [self.headerView.avatarButton sd_setImageWithURL:GetQiniuPictureUrl(super.lcUser.avatar) forState:UIControlStateNormal];
    [self.headerView setImage:[UIImage imageAtResourcePath:@"profile header bg"] style:HeaderMaskStyleMedium];
    [self.headerView setHeaderViewDidPressAvatarButton:^{[weakSelf avatarButtonDidPress];}];
    
    MXParallaxHeader *header = self.segmentedPager.parallaxHeader;
    header.view = self.headerView;
    header.height = self.headerHeight;
    header.minimumHeight = kParallaxHeaderMinimumHeight;
    header.mode = MXParallaxHeaderModeTopFill;
    
    //control
    HMSegmentedControl *control = self.segmentedPager.segmentedControl;
    control.type = HMSegmentedControlTypeImages;
}

- (void)retrieveData {
    [_completedTableViewController retrieveDataWithUser:self.cdUser date:nil status:nil isComplete:@YES keyword:nil];
    [_snoozedTableViewController retrieveDataWithUser:self.cdUser date:nil status:@(TodoStatusSnoozed) isComplete:@NO keyword:nil];
    [_overdueTableViewController retrieveDataWithUser:self.cdUser date:nil status:@(TodoStatusOverdue) isComplete:@NO keyword:nil];
}

#pragma mark <MXSegmentedPagerDelegate>

- (CGFloat)heightForSegmentedControlInSegmentedPager:(MXSegmentedPager *)segmentedPager {
    return kSegmentedControlHeight;
}

- (void)segmentedPager:(MXSegmentedPager *)segmentedPager didScrollWithParallaxHeader:(MXParallaxHeader *)parallaxHeader {
    //这里的progress估计是没有将minimumHeight纳入计算，这里要根据比例来得到近似值...还要纠正误差...
    CGFloat ratio = self.headerHeight / (kParallaxHeaderMinimumHeight + self.headerHeight);
    CGFloat alpha = fabsf(parallaxHeader.progress > 0 ? 0 : parallaxHeader.progress) / ratio;
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:ColorWithRGBA(0xFF3366, alpha)] forBarMetrics:UIBarMetricsDefault];
    
    //alpha大于xxx就显示title
    //这里由于progress值波动过大只能缩小显示阈值，且这里不要设置NavigationBar为不透明，太不稳定
    BOOL shouldDisplayTitle = alpha >= 0.6;
    if (shouldDisplayTitle && !_titleIsShowing) {
        _titleIsShowing = YES;
        [UIView animateWithDuration:.3 animations:^{self.titleLabel.alpha = 1;}];
    } else if (!shouldDisplayTitle && _titleIsShowing) {
        _titleIsShowing = NO;
        [UIView animateWithDuration:.3 animations:^{self.titleLabel.alpha = 0;}];
    }
}

- (UIImage *)segmentedPager:(MXSegmentedPager *)segmentedPager imageForSectionAtIndex:(NSInteger)index {
    return [self controlImageWithIndex:index];
}

- (UIImage *)segmentedPager:(MXSegmentedPager *)segmentedPager selectedImageForSectionAtIndex:(NSInteger)index {
    return [self controlImageWithIndex:index];
}

#pragma mark - draw image

- (UIImage *)controlImageWithIndex:(NSInteger)index {
    NSString *text = nil;
    NSInteger count = 0;
    UIColor *color = nil;
    if (index == 0) {
        text = @"COMPLETE";
        count = _completedTableViewController.dataCount;
        color = [SGHelper themeColorCyan];
    } else if (index == 1) {
        text = @"SNOOZED";
        count = _snoozedTableViewController.dataCount;
        color = [SGHelper themeColorYellow];
    } else if (index == 2) {
        text = @"OVERDUE";
        count = _overdueTableViewController.dataCount;
        color = [SGHelper themeColorPurple];
    }
    
    CGSize size = CGSizeMake(kScreenWidth / 3 - 8 * 2, kSegmentedControlHeight);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //draw count
    UIFont *countFont = [SGHelper themeFontWithSize:25];
    CGSize countSize = [self sizeWithString:@(count).stringValue font:countFont];
    [@(count).stringValue drawAtPoint:CGPointMake(size.width / 2 - countSize.width / 2, size.height * 0.1f) withAttributes:@{NSFontAttributeName: countFont, NSForegroundColorAttributeName: [UIColor blackColor]}];
    
    //draw text
    UIFont *textFont = [SGHelper themeFontWithSize:15];
    CGSize textSize = [self sizeWithString:text font:textFont];
    [text drawAtPoint:CGPointMake(size.width / 2 - textSize.width / 2, size.height * 0.2f + 25) withAttributes:@{NSFontAttributeName: textFont, NSForegroundColorAttributeName: [SGHelper subTextColor]}];
    
    //draw stripe
    CGSize stripeSize = CGSizeMake(28, 2.5);
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetLineWidth(context, stripeSize.height);
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextBeginPath(context);
    CGPoint stripeBeginPoint = CGPointMake(size.width / 2 - stripeSize.width / 2, size.height * 0.35f + 40);
    CGContextMoveToPoint(context, stripeBeginPoint.x, stripeBeginPoint.y);
    CGContextAddLineToPoint(context, stripeBeginPoint.x + stripeSize.width, stripeBeginPoint.y);
    CGContextStrokePath(context);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (CGSize)sizeWithString:(NSString *)string font:(UIFont *)font {
    UILabel *label = [UILabel new];
    label.text = string;
    label.font = font;
    [label sizeToFit];
    return label.frame.size;
}
@end