//
//  TodoHeaderCell.m
//  TO-DO
//
//  Created by Siegrain on 16/5/25.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "DateUtil.h"
#import "SGSectionHeader.h"
#import "SGHelper.h"
#import "UIView+SDAutoLayout.h"

@interface SGSectionHeader ()
@property(nonatomic, strong) UILabel *label;
@end

@implementation SGSectionHeader

- (instancetype)init {
    if (self = [super init]) {
        [self setupViews];
        [self bindConstraints];
    }
    return self;
}

- (void)setText:(NSString *)text {
    _text = text;
    _label.text = _text;
}

- (void)setupViews {
    self.backgroundColor = [UIColor whiteColor];
    
    _label = [UILabel new];
    _label.font = [SGHelper themeFontWithSize:13];
    _label.textColor = [SGHelper subTextColor];
    _label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_label];
}

- (void)bindConstraints {
    [_label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.centerY.offset(0);
        make.height.offset(13);
    }];
}

@end
