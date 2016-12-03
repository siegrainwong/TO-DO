//
//  TodoHeaderCell.h
//  TO-DO
//
//  Created by Siegrain on 16/5/25.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TodoHeaderCell : UIView
@property (nonatomic, strong) NSString* text;

+ (instancetype)headerCell;
@end
