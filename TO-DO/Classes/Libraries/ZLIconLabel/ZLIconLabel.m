//
//  ZLIconLabel.m
//  ZLIconLabel
//
//  Created by apple on 16/4/11.
//  Copyright © 2016年 ANGELEN. All rights reserved.
//

#import "ZLIconLabel.h"

@interface ZLIconLabel() {
    UIImageView *_iconView;
}

@end

@implementation ZLIconLabel

- (void)viewDidLoad {
    NSLog(@"viewDidLoad..");
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    if (self.numberOfLines != 1 || _icon == nil) {
        [super drawTextInRect:rect];
        return;
    }
    
    if (_icon != nil) {
        [_iconView removeFromSuperview];
        _iconView = [[UIImageView alloc] initWithImage:_icon];
        
        CGRect newRect = CGRectZero;
        CGSize size = self.frame.size;
        
        size = [self.text boundingRectWithSize:CGSizeMake(self.frame.size.width, self.frame.size.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObject:self.font forKey:NSFontAttributeName] context:nil].size;
        
        if (_iconView != nil) {
            
            if (_iconPosition == ZLIconLabelPositionLeft) {
                
                if (self.textAlignment == NSTextAlignmentLeft) {
                    _iconView.frame = CGRectOffset(_iconView.frame, 0, (self.height - _iconView.height) / 2);
                    newRect = CGRectMake(_iconView.width + _iconPadding, 0, self.width - (_iconView.width + _iconPadding), self.height);
                } else if (self.textAlignment == NSTextAlignmentRight) {
                    _iconView.frame = CGRectOffset(_iconView.frame, self.width - size.width - _iconView.width - _iconPadding, (self.height - _iconView.height) / 2);
                    newRect = CGRectMake(self.width - size.width - _iconPadding, 0, size.width + _iconPadding, self.height);
                } else if (self.textAlignment == NSTextAlignmentCenter) {
                    _iconView.frame = CGRectOffset(_iconView.frame, (self.width - size.width) / 2 - _iconPadding - _iconView.width, (self.height - _iconView.height) / 2);
                    newRect = CGRectMake((self.width - size.width) / 2, 0, size.width + _iconPadding, self.height);
                }
                
            } else if (_iconPosition == ZLIconLabelPositionRight) {
                
                if (self.textAlignment == NSTextAlignmentLeft) {
                    _iconView.frame = CGRectOffset(_iconView.frame, size.width + _iconPadding, (self.height - _iconView.height) / 2);
                    newRect = CGRectMake(0, 0, self.width - self.width, self.height);
                } else if (self.textAlignment == NSTextAlignmentRight) {
                    _iconView.frame = CGRectOffset(_iconView.frame, self.width - _iconView.width, (self.height - _iconView.height) / 2);
                    newRect = CGRectMake(self.width - size.width - _iconView.width - _iconPadding, 0, size.width, self.height);
                } else if (self.textAlignment == NSTextAlignmentCenter) {
                    _iconView.frame = CGRectOffset(_iconView.frame, self.width / 2 + size.width / 2 + _iconPadding, (self.height - _iconView.self.height) / 2);
                    newRect = CGRectMake((self.width - size.width) / 2, 0, size.width, self.height);
                }
                
            }
            [self addSubview:_iconView];
            [super drawTextInRect:newRect];
        }
    }
    
}

@end
