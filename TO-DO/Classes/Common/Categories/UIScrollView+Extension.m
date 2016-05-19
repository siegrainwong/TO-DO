//
//  UIScrollView+Extension.m
//  TO-DO
//
//  Created by Siegrain on 16/5/19.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "UIScrollView+Extension.h"

@implementation UIScrollView (Extension)
- (void)ignoreNavigationHeight
{
    self.contentInset = UIEdgeInsetsZero;
}
@end
