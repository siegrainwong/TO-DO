//
//  UITableView+Extension.h
//  TO-DO
//
//  Created by Siegrain on 16/5/19.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (Extension)
/**
 *  由于 tableHeaderView 不认约束，设置约束后需要在这里重设 tableHeaderView 的尺寸，在 viewDidLayoutSubviews 中调用
 */
- (void)resizeTableHeaderView;
@end
