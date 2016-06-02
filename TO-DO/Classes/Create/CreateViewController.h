//
//  CreateViewController.h
//  TO-DO
//
//  Created by Siegrain on 16/5/19.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "BaseViewController.h"
#import "HSDatePickerViewController.h"
#import "Localized.h"

@class CDTodo;

@interface CreateViewController : BaseViewController<Localized, HSDatePickerViewControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

/**
 *  用于回传刚提交成功的数据
 */
@property (nonatomic, readwrite, copy) void (^createViewControllerDidFinishCreate)(CDTodo* model);
/**
 *  在该控制器引发viewDidDisappear时引发
 */
@property (nonatomic, readwrite, copy) void (^createViewControllerDidDisappear)();
@end
