//
//  CreateViewController.h
//  TO-DO
//
//  Created by Siegrain on 16/5/19.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "SGBaseViewController.h"
#import "HSDatePickerViewController.h"
#import "Localized.h"

@class CDTodo;

@interface CreateViewController : SGBaseViewController<Localized, HSDatePickerViewControllerDelegate>

/**
 *  用于回传刚提交成功的数据
 */
@property (nonatomic, readwrite, copy) void (^createViewControllerDidFinishCreate)(CDTodo* model);

/**
 * 设置选择的时间
 * @param selectedDate
 */
- (void)setSelectedDate:(NSDate *)selectedDate;
@end
