//
//  UIScrollView+Extension.h
//  TO-DO
//
//  Created by Siegrain on 16/5/19.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (Extension)
/**
 *  忽略NavigationBar的64点高度，需要在viewDidLayoutSubviews中执行
 */
- (void)ignoreNavigationHeight;
@end
