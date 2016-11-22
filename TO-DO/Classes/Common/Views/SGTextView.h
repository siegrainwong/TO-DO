//
// Created by Siegrain on 16/11/22.
// Copyright (c) 2016 com.siegrain. All rights reserved.
//


#import "SGViews.h"

/**
 * 使用该控件时，在添加到视图上之前必须先设置代理（若有）
 */
@interface SGTextView : UITextView<SGViews>
/* 需要调整高度的容器 */
@property(nonatomic, weak) UIView *container;
/* 该容器的初始高度 */
@property(nonatomic, assign) CGFloat containerInitialHeight;

/* 最大字数 */
@property(nonatomic, assign) NSUInteger maxLength;
/* 最大显示行数 */
@property(nonatomic, assign) NSUInteger maxLineCount;
/* 当前高度 */
@property(nonatomic, assign) CGFloat height;
@end