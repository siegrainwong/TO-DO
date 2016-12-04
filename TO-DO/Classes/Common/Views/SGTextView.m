//
// Created by Siegrain on 16/11/22.
// Copyright (c) 2016 com.siegrain. All rights reserved.
//

#import "SGTextView.h"
#import "RNObserverManager.h"

@interface SGTextView ()
@end

@implementation SGTextView

#pragma mark - accessors

- (void)setText:(NSString *)text {
    [super setText:text];

//    [self updateTextViewHeight:self];
}

#pragma mark - release

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - initial

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupViews];
        [self bindConstraints];
    }
    
    return self;
}

- (void)setupViews {
    self.textContainer.lineBreakMode = NSLineBreakByCharWrapping;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
}

- (void)bindConstraints {
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self updateTextViewHeight:self];
}

#pragma mark - textview delegate

- (void)textViewDidChange:(UITextView *)textView {
    [self updateTextViewHeight:textView];
    
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

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
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

- (void)textChanged:(NSNotification *)notification {
    [self textViewDidChange:self];
}

#pragma mark - private methods

/**
 * 调整高度
 * @param textView
 */
- (void)updateTextViewHeight:(UITextView *)textView {
    CGSize textSize = [textView sizeThatFits:CGSizeMake(textView.width, CGFLOAT_MAX)];
    CGFloat lineHeight = textView.font.lineHeight;
    NSInteger lineCount = (NSInteger) (textSize.height / lineHeight);
    if (_maxLineCount && lineCount > _maxLineCount) return;
    
    CGFloat increase = (lineCount - 1) * lineHeight;
    _currentHeight = _containerInitialHeight + increase;
    if (_textViewDidUpdateHeight)_textViewDidUpdateHeight(_currentHeight);
    [_container mas_updateConstraints:^(MASConstraintMaker *make) {make.height.offset(_currentHeight);}];
}
@end