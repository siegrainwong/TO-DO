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
SGTextField ()<UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UILabel* label;
@property (strong, nonatomic) IBOutlet UITextField* textField;
@end

@implementation SGTextField
#pragma mark - initial
+ (instancetype)textField
{
    SGTextField* sgTextField = [[[NSBundle mainBundle] loadNibNamed:@"SGTextField" owner:nil options:nil] lastObject];
    sgTextField.textField.delegate = sgTextField;
    return sgTextField;
}

#pragma mark - accessors
- (NSString*)text
{
    return _textField.text;
}
- (void)setTitle:(NSString*)title
{
    _label.text = title;
}
- (void)setSecureTextEntry:(BOOL)secureTextEntry
{
    _textField.secureTextEntry = secureTextEntry;
}
- (void)setReturnKeyType:(UIReturnKeyType)returnKeyType
{
    _textField.returnKeyType = returnKeyType;
}
#pragma mark - rewrite
- (void)layoutSubviews
{
    [super layoutSubviews];

    [self attachBottomBorder];
}

- (BOOL)becomeFirstResponder
{
    [super becomeFirstResponder];
    [_textField becomeFirstResponder];

    return YES;
}

#pragma mark - helper
- (void)attachBottomBorder
{
    CALayer* border = [CALayer layer];
    CGFloat borderWidth = 1;
    border.frame = CGRectMake(0, self.frame.size.height - borderWidth, self.frame.size.width, 1);
    border.borderColor = ColorWithRGB(0xDDDDDD).CGColor;
    border.borderWidth = borderWidth;
    [self.layer addSublayer:border];
    self.layer.masksToBounds = YES;
}

#pragma mark - textField delegate
- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    if (_textFieldShouldReturn) _textFieldShouldReturn(self);

    return YES;
}
@end
