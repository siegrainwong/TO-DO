//
//  UISearchBar+Additions.m
//  GamePlatform
//
//  Created by Siegrain on 16/8/8.
//  Copyright © 2016年 com.lurenwang.gameplatform. All rights reserved.
//

#import "UISearchBar+Additions.h"

@implementation UISearchBar (Additions)
- (void)setBarBackgroundColor:(UIColor*)color
{
    UITextField* searchField = [self findSearchField];
    if ([self findSearchField]) searchField.backgroundColor = color;
}

- (void)setTextColor:(UIColor*)color
{
    UITextField* searchField = [self findSearchField];
    if ([self findSearchField]) searchField.textColor = color;
}

- (UITextField*)findSearchField
{
    for (UIView* subview in self.subviews) {
        for (UIView* subSubview in subview.subviews) {
            if ([subSubview isKindOfClass:[UITextField class]]) {
                UITextField* field = (UITextField*)subSubview;
                return field;
            }
        }
    }

    return nil;
}
@end
