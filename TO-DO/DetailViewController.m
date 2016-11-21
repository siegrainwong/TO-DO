//
// Created by Siegrain on 16/11/21.
// Copyright (c) 2016 com.siegrain. All rights reserved.
//

#import "DetailViewController.h"
#import "AutoLinearLayoutView.h"
#import "SGTextField.h"
#import "DZMInputView.h"
#import "BEMCheckBox.h"

@interface DetailViewController ()
@property(nonatomic, strong) CDTodo *model;

@property(nonatomic, strong) BEMCheckBox *checkBox;
@property(nonatomic, strong) DZMInputView *titleTextView;
@property(nonatomic, strong) UIImageView *photoImageView;
@end

@implementation DetailViewController

#pragma mark - accessors
- (void)setModel:(CDTodo *)model {
    _model = model;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)setupViews {
    [super setupViews];
    
    
}

- (void)bindConstraints {
    [super bindConstraints];
}
@end