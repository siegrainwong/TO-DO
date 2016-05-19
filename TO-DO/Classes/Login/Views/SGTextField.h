//
//  SGTextField2.h
//  TO-DO
//
//  Created by Siegrain on 16/5/8.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SGTextField : UIControl
@property (nonatomic, readwrite, strong) NSString* text;
@property (nonatomic, readwrite, strong) NSString* title;
@property (nonatomic, readwrite, assign) BOOL secureTextEntry;
@property (nonatomic, readwrite, assign) UIReturnKeyType returnKeyType;

@property (nonatomic, readwrite, copy) void (^textFieldShouldReturn)(SGTextField* textField);

+ (instancetype)textField;

@end
