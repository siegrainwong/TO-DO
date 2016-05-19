//
//  SGCommitButton.h
//  TO-DO
//
//  Created by Siegrain on 16/5/19.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SGCommitButton : UIControl
@property (nonatomic, readonly, strong) UIButton* button;
@property (nonatomic, readonly, strong) UIActivityIndicatorView* indicator;
@property (nonatomic, readwrite, copy) void (^commitButtonDidPress)();

+ (instancetype)commitButton;
@end
