//
//  SGTextField2.m
//  TO-DO
//
//  Created by Siegrain on 16/5/8.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "Macros.h"
#import "SGTextField.h"

@implementation SGTextField {
    CALayer* underline;
}
#pragma mark - initial
+ (instancetype)textField
{
    SGTextField* sgTextField = [[[NSBundle mainBundle] loadNibNamed:@"SGTextField" owner:nil options:nil] lastObject];
    sgTextField.field.delegate = sgTextField;
    return sgTextField;
}

#pragma mark - rewrite UIControl methods & accessors
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
    if (!underline) {
        underline = [CALayer layer];
        [self.layer addSublayer:underline];
    }

    CGFloat lineWidth = 1;
    underline.frame = CGRectMake(0, self.frame.size.height - lineWidth, self.frame.size.width, lineWidth);
    underline.borderColor = ColorWithRGB(0xDDDDDD).CGColor;
    underline.borderWidth = lineWidth;
    self.layer.masksToBounds = YES;
}

#pragma mark - textField delegate
- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    if (_textFieldShouldReturn) _textFieldShouldReturn(self);

    return YES;
}
@end
