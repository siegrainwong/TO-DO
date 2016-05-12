//
//  UITextField+BottomBorder.m
//  TO-DO
//
//  Created by Siegrain on 16/5/7.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//
#import "UITextField+BottomBorder.h"

@implementation UITextField (BottomBorder)
- (void)attachBottomBorderWithColor:(UIColor *)borderColor {
  CALayer *border = [CALayer layer];
  CGFloat borderWidth = 1;
  border.borderColor = borderColor.CGColor;
  border.frame = CGRectMake(0, self.frame.size.height - borderWidth,
                            self.frame.size.width, self.frame.size.height);
  border.borderWidth = borderWidth;
  [self.layer addSublayer:border];
  self.layer.masksToBounds = YES;
}
@end
