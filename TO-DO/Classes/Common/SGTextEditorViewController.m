//
// Created by Siegrain on 16/11/21.
// Copyright (c) 2016 com.siegrain. All rights reserved.
//

#import "ACEExpandableTextCell.h"
#import "SGTextEditorViewController.h"
#import "UIViewController+SGConfigure.h"

@interface
SGTextEditorViewController () <ACEExpandableTableViewDelegate, SGNavigationBar>
@property(nonatomic, readwrite, assign) CGFloat cellHeight;
@property(nonatomic, readwrite, strong) ACEExpandableTextCell *cell;
@end

@implementation SGTextEditorViewController
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setupNavigationBar];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.cell.textView becomeFirstResponder];
}

- (void)setupViews {
    [super setupViews];
    
    self.navigationItem.rightBarButtonItem.title = Localized(@"Save");
    self.tableView.backgroundColor = ColorWithRGB(0xEEEEEE);
    [self setSeparatorInsetZeroWithTableView:self.tableView];
}

- (void)bindConstraints {
    [super bindConstraints];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.right.offset(0);
    }];
}

#pragma mark - events

- (void)rightNavButtonDidPress {
    if (self.editorDidSave) self.editorDidSave(self.value);
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)leftNavButtonDidPress {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - tableview

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [UIView new];
}

- (void)tableView:(UITableView *)tableView updatedText:(NSString *)text atIndexPath:(NSIndexPath *)indexPath {
    self.value = text;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    self.cell = [tableView expandableTextCellWithId:@"cellId"];
    self.cell.text = self.value;
    self.cell.backgroundColor = ColorWithRGB(0xFAFAFA);
    self.cell.textView.placeholder = self.title;
    return self.cell;
}

#pragma mark - cell delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return MAX(50.0, self.cellHeight);
}

- (void)tableView:(UITableView *)tableView updatedHeight:(CGFloat)height atIndexPath:(NSIndexPath *)indexPath {
    self.cellHeight = height;
}

- (BOOL)tableView:(UITableView *)tableView textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [self.view endEditing:YES];
        return NO;
    }
    return YES;
}
@end
