//
// Created by Siegrain on 16/11/21.
// Copyright (c) 2016 com.siegrain. All rights reserved.
//

#import "SGBaseTableViewController.h"

typedef void (^SGTextEditorSavedBlock)(NSString *value);

@interface SGTextEditorViewController : SGBaseTableViewController
@property(nonatomic, strong) NSString *value;
@property(nonatomic, copy) SGTextEditorSavedBlock editorDidSave;
@property(nonatomic, assign) NSUInteger maxLength;
@property(nonatomic, assign) BOOL nullable;
@end
