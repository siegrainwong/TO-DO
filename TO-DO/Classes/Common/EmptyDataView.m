//
// Created by Siegrain on 16/11/2.
// Copyright (c) 2016 com.siegrain. All rights reserved.
//

#import "EmptyDataView.h"

@interface EmptyDataView ()
@property(nonatomic, strong) UILabel *label;
@end

@implementation EmptyDataView
- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupViews];
        [self bindConstraints];
    }
    return self;
}

- (void)setupViews {
    self.backgroundColor = [SGHelper themeColorLightGray];
    
    self.label = [UILabel new];
    self.label.text = Localized(@"Your task list is empty...");
    self.label.textColor = [SGHelper themeColorGray];
    self.label.font = [SGHelper themeFontDefault];
    self.label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.label];
}

- (void)bindConstraints {
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.offset(20);
        make.left.right.offset(0);
        make.centerY.offset(0);
    }];
}
@end