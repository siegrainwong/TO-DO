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

@class LCTodo;

@interface CreateViewController : BaseViewController<Localized, HSDatePickerViewControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

/**
 *  用于回传刚提交成功的数据
 */
@property (nonatomic, readwrite, copy) void (^createViewControllerDidFinishCreate)(LCTodo* model);
@end
