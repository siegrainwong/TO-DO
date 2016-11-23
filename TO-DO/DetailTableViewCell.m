//
// Created by Siegrain on 16/11/21.
// Copyright (c) 2016 com.siegrain. All rights reserved.
//

#import "DetailTableViewCell.h"
#import "CDTodo.h"
#import "HSDatePickerViewController+Configure.h"
#import "HSDatePickerViewController.h"
#import "SGTextView.h"
#import "SGBaseMapViewController.h"

@interface DetailTableViewCell ()
@property(nonatomic, strong) CDTodo *model;

@property(nonatomic, strong) UIImageView *iconView;
@property(nonatomic, strong) UILabel *contentLabel;
@property(nonatomic, strong) UIImageView *photoView;
@property(nonatomic, strong) SGBaseMapViewController *mapViewController;
@end

@implementation DetailTableViewCell
- (void)setModel:(CDTodo *)model {
    _model = model;
}

- (void)setupViews {
    
}

- (void)bindConstraints {
    
}

@end