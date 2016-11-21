//
//  DZMInputView.h
//  OC自动增高TextView简单使用
//
//  Created by 邓泽淼 on 16/5/4.
//  Copyright © 2016年 DZM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DZMInputView : UIView
/**
 *  输入框的周边间距 default: UIEdgeInsetsMake(5, 5, 5, 5)
 */
@property (nonatomic,assign) UIEdgeInsets inset;

/**
 *  高度变动之后的间距差
 */
@property (nonatomic,assign) CGFloat changeH;

/**
 *  动画时间 default: 0.25
 */
@property (nonatomic,assign) float animationDuration;

/**
 *  textView
 */
@property (nonatomic,weak) UITextView *textView;

/**
 *  获取当前view的高度 没有字的时候获取默认高度
 */
- (CGFloat)height;
@end
