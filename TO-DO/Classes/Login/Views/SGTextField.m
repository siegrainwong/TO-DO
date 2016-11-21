//
//  SGTextField2.m
//  TO-DO
//
//  Created by Siegrain on 16/5/8.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "Macros.h"
#import "SGTextField.h"

@interface
SGTextField ()
@property (nonatomic, readwrite, strong) CALayer* underline;
@end

@implementation SGTextField
#pragma mark - initial
+ (instancetype)textField
{
    SGTextField* sgTextField = [[[NSBundle mainBundle] loadNibNamed:@"SGTextField" owner:nil options:nil] lastObject];
    sgTextField.field.delegate = sgTextField;
    return sgTextField;
}

#pragma mark - overwrite
- (void)layoutSubviews
{
    [super layoutSubviews];

    [self attachUnderline];
}

- (BOOL)becomeFirstResponder
{
    [_field becomeFirstResponder];

    return YES;
}
- (BOOL)resignFirstResponder
{
    [_field resignFirstResponder];

    return NO;
}
- (void)setEnabled:(BOOL)enabled
{
    _field.enabled = enabled;
}

#pragma mark - helper
- (void)attachUnderline
{
    if (_isUnderlineHidden) return;

    // Mark: 在控件完成布局后添加下划线，由于控件可能会布局多次，所以要确保只添加了一次下划线
    if (!_underline) {
        _underline = [CALayer layer];
        [self.layer addSublayer:_underline];
    }

    CGFloat lineWidth = 1;
    _underline.frame = CGRectMake(0, self.frame.size.height - lineWidth, self.frame.size.width, lineWidth);
    _underline.borderColor = ColorWithRGB(0xDDDDDD).CGColor;
    _underline.borderWidth = lineWidth;
    self.layer.masksToBounds = YES;
}

#pragma mark - textField delegate
- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    if (_textFieldShouldReturn) _textFieldShouldReturn(self);

    return YES;
}
@end
