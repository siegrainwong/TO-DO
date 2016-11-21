//
//  DZMInputView.m
//  OC自动增高TextView简单使用
//
//  Created by 邓泽淼 on 16/5/4.
//  Copyright © 2016年 DZM. All rights reserved.
//

#import "DZMInputView.h"
@interface DZMInputView()
/**
 *   用来临时记录的动画时间 方便继承后可以使用
 */
@property (nonatomic,assign) float TempDuration;

/**
 *   原来的高度
 */
@property (nonatomic,assign) CGFloat OriginH;

/**
 *   是否是初始化第一次
 */
@property (nonatomic,assign) BOOL IsInit;

/**
 *   textView默认四周的间距
 */
@property (nonatomic,assign) CGFloat TextViewSpace;

@end
@implementation DZMInputView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initSetup];
    }
    return self;
}

- (void)awakeFromNib {
    
     [self initSetup];
}

/**
 *  初始化设置
 */
- (void)initSetup {
    
    self.inset = UIEdgeInsetsMake(5, 5, 5, 5);
    self.animationDuration = 0.25;
    self.TextViewSpace = 5;
    self.IsInit = YES;
    
    [self creatUI];
}

- (void)creatUI {
    
    // 输入框
    UITextView *textView = [[UITextView alloc] init];
    textView.backgroundColor = [UIColor greenColor];
    textView.bounces = NO;
    textView.scrollEnabled = NO;
    textView.font = [UIFont systemFontOfSize:13];
    textView.textContainerInset = UIEdgeInsetsMake(8, 5, 8, 5);
    [self addSubview:textView];
    textView.layer.borderColor = [UIColor grayColor].CGColor;
    textView.layer.borderWidth = 1;
    textView.layer.cornerRadius = 3;
    textView.layer.masksToBounds = YES;
    self.textView = textView;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // 设置动画时间
    self.TempDuration = self.animationDuration;
    
    CGFloat w = self.frame.size.width;
    CGFloat h = self.frame.size.height;
    CGFloat textViewW = w - self.inset.right - self.inset.left;
    CGFloat textViewH = h - self.inset.top - self.inset.bottom;
    
    if (self.IsInit) {
        self.IsInit = NO;
        self.TempDuration = 0;
    }
    
    __weak DZMInputView *weakSelf = self;
    [UIView animateWithDuration:self.TempDuration animations:^{
        weakSelf.textView.frame = CGRectMake(weakSelf.inset.left, weakSelf.inset.top, textViewW, textViewH);
    }];
}

/**
 *  获取当前view的高度 没有字的时候获取默认高度
 */
- (CGFloat)height {
    
    // 计算text  假如有需要输入的是attributedText 计算attributedText则把这里的text 换成 attributedText
    NSString *textStr = self.textView.text;
    
    if (textStr.length <= 0) {
        textStr = @"1";
    }
    
    CGFloat maxW = self.textView.frame.size.width - self.textView.textContainerInset.left - self.textView.textContainerInset.right - 2*self.TextViewSpace;
    
    CGSize textViewSize = [textStr boundingRectWithSize:CGSizeMake(maxW, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.textView.font} context:nil].size;
    
    CGFloat h = textViewSize.height + self.textView.textContainerInset.top + self.textView.textContainerInset.bottom + self.inset.top + self.inset.bottom;
    
    if (self.OriginH > 0) {
        self.changeH = h - self.OriginH;
    }else{
        self.changeH = 0;
    }
    
    self.OriginH = h;
    
    return h;

}

@end
