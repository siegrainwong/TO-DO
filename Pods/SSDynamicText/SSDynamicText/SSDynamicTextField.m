//
//  SSDynamicTextField.m
//  SSDynamicText
//
//  Created by Jonathan Hersh on 10/6/13.
//  Copyright (c) 2013 Splinesoft. All rights reserved.
//

#import "SSDynamicTextField.h"
#import "SSDynamicTextSizeChanger.h"

@interface SSDynamicTextField ()

@property (nonatomic, strong) SSDynamicTextSizeChanger *textSizeChanger;

@end

@implementation SSDynamicTextField

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self startObservingTextSizeChanges];
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];

    [self setupDefaultFontDescriptorBasedOnFont:self.font];
    [self startObservingTextSizeChanges];
}

+ (instancetype)textFieldWithFont:(NSString *)fontName baseSize:(CGFloat)size {
    UIFontDescriptor *fontDescriptor = [UIFontDescriptor fontDescriptorWithName:fontName size:size];
    
    return [self textFieldWithFontDescriptor:fontDescriptor];
}

+ (instancetype)textFieldWithFontDescriptor:(UIFontDescriptor *)descriptor {
    SSDynamicTextField *textField = [self new];
    textField.defaultFontDescriptor = descriptor;
    
    return textField;
}

- (void)dealloc {
    [self ss_stopObservingTextSizeChanges];
}

#pragma mark - Accessors

- (void)setDefaultFontDescriptor:(UIFontDescriptor *)defaultFontDescriptor {
    self.textSizeChanger.defaultFontDescriptor = defaultFontDescriptor;
    super.defaultFontDescriptor = defaultFontDescriptor;
}

- (void)setFont:(UIFont *)font {
    [super setFont:font];
    [self setupDefaultFontDescriptorBasedOnFont:self.font];
}

#pragma mark - Private Methods

- (SSDynamicTextSizeChanger *)textSizeChanger {
    if (_textSizeChanger == nil) {
        _textSizeChanger = [self createTextChanger];
    }
    return _textSizeChanger;
}

- (SSDynamicTextSizeChanger *)createTextChanger {
    SSDynamicTextSizeChanger *changer = [[SSDynamicTextSizeChanger alloc] init];
    __weak typeof(self) weakSelf = self;

    changer.fontChangeBlock = ^(UIFont *font) {
        [super setFont:font];
    };

    changer.attributedTextChangeBlock = ^(NSAttributedString *attributedText) {
        weakSelf.attributedText = attributedText;
    };
    return changer;
}

- (void)startObservingTextSizeChanges {
    [self ss_startObservingTextSizeChangesWithBlock:self.textSizeChanger.changeHandler];
}

#pragma mark - SSDynamicAttributedTextSizable

- (NSAttributedString *)dynamicAttributedText {
    return self.textSizeChanger.dynamicAttributedText;
}

- (void)setDynamicAttributedText:(NSAttributedString *)attributedText {
    self.textSizeChanger.dynamicAttributedText = attributedText;
}

@end
