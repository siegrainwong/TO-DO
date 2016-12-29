//
//  SGTextField2.h
//  TO-DO
//
//  Created by Siegrain on 16/5/8.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  文本框
 */
@interface SGTextField : UIControl<UITextFieldDelegate>
/**
 *  位于文本框上方的 Label
 */
@property (strong, readwrite, nonatomic) IBOutlet UILabel* label;
/**
 *  文本框
 */
@property (strong, readwrite, nonatomic) IBOutlet UITextField* field;
/**
 *  是否隐藏下划线
 */
@property (nonatomic, readwrite, assign) BOOL isUnderlineHidden;

/**
 *  文本框的 Return 事件
 */
@property (nonatomic, readwrite, copy) void (^textFieldShouldReturn)(SGTextField* field);

+ (instancetype)textField;
@end
