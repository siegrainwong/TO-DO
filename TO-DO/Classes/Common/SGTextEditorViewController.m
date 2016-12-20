//
// Created by Siegrain on 16/11/21.
// Copyright (c) 2016 com.siegrain. All rights reserved.
//

#import "ACEExpandableTextCell.h"
#import "SGTextEditorViewController.h"
#import "UIViewController+SGConfigure.h"
#import "NSString+Extension.h"

static CGFloat const kLengthLabelHeight = 20;

@interface
SGTextEditorViewController () <ACEExpandableTableViewDelegate, SGNavigationBar>
@property(nonatomic, readwrite, assign) CGFloat cellHeight;
@property(nonatomic, readwrite, strong) ACEExpandableTextCell *cell;
@property(nonatomic, assign) NSUInteger currentLength;

@property(nonatomic, strong) UILabel *lengthLabel;
@end

@implementation SGTextEditorViewController

#pragma mark - accessors

- (void)setCurrentLength:(NSUInteger)currentLength {
    _currentLength = currentLength;
    
    if(_maxLength) _lengthLabel.text = [NSString stringWithFormat:@"%u / %u ", currentLength, _maxLength];
}

- (void)setValue:(NSString *)value {
    _value = value;
    
    self.currentLength = value.length;
}

#pragma mark - initial

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setupNavigationBar];
    [self setSeparatorInsetZeroWithTableView:self.tableView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.cell.textView becomeFirstResponder];
}

- (void)setupViews {
    [super setupViews];
    
    _lengthLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kLengthLabelHeight)];
    _lengthLabel.textColor = [SGHelper themeColorGray];
    _lengthLabel.font = [UIFont systemFontOfSize:14];
    _lengthLabel.textAlignment = NSTextAlignmentRight;
    
    self.navigationItem.rightBarButtonItem.title = Localized(@"Save");
    self.tableView.backgroundColor = ColorWithRGB(0xEEEEEE);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
}

#pragma mark - events

- (void)rightNavButtonDidPress {
    if (_editorDidSave) _editorDidSave(_value);
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)leftNavButtonDidPress {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - tableview

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return !section ?: kLengthLabelHeight;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section) return 0;
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (!section) return nil;
    
    //这个必须在SectionHeader才能正常显示，在Footer会掉到最下面
    return _lengthLabel;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    self.cell = [tableView expandableTextCellWithId:@"cellId"];
    self.cell.text = self.value;
    self.cell.backgroundColor = ColorWithRGB(0xFAFAFA);
    self.cell.textView.placeholder = self.title;
    return self.cell;
}

#pragma mark - cell delegate

- (void)tableView:(UITableView *)tableView updatedText:(NSString *)text atIndexPath:(NSIndexPath *)indexPath {
    self.value = [text stringByRemovingUnnecessaryWhitespaces];
}

- (void)tableView:(UITableView *)tableView updatedHeight:(CGFloat)height atIndexPath:(NSIndexPath *)indexPath {
    self.cellHeight = height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return MAX(50.0, self.cellHeight);
}

- (BOOL)tableView:(UITableView *)tableView textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [self.view endEditing:YES];
        return NO;
    }
    
    if (!_maxLength) return YES;
    //避免超过最大字符数限制
    UITextRange *markedRange = [textView markedTextRange];
    UITextPosition *position = [textView positionFromPosition:markedRange.start offset:0];
    if (markedRange && position) {
        NSInteger startOffset = [textView offsetFromPosition:textView.beginningOfDocument toPosition:markedRange.start];
        NSInteger endOffset = [textView offsetFromPosition:textView.beginningOfDocument toPosition:markedRange.end];
        NSRange offsetRange = NSMakeRange(startOffset, endOffset - startOffset);
        return offsetRange.location < _maxLength;
    }
    
    NSString *replacedString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    NSInteger restOfLength = _maxLength - replacedString.length;
    
    if (restOfLength < 0) {
        NSInteger fullLength = text.length + restOfLength;
        NSRange replacingRange = {0, MAX(fullLength, 0)};
        
        if (replacingRange.length > 0) {
            NSString *s = [text substringWithRange:replacingRange];
            [textView setText:[textView.text stringByReplacingCharactersInRange:range withString:s]];
        }
        return NO;
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView textViewDidChange:(UITextView *)textView {
    if (!_maxLength) return;
    
    //避免超过最大字符数限制
    UITextRange *markedRange = [textView markedTextRange];
    UITextPosition *position = [textView positionFromPosition:markedRange.start offset:0];
    if (markedRange && position) return;
    
    NSString *text = textView.text;
    
    if (textView.text.length > _maxLength) {
        text = [text substringToIndex:_maxLength];
        [textView setText:text];
    }
}

- (void)textChanged:(NSNotification *)notification {
    [self tableView:self.tableView textViewDidChange:_cell.textView];
}
@end
