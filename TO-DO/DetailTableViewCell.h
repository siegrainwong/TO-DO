//
// Created by Siegrain on 16/11/21.
// Copyright (c) 2016 com.siegrain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SGViews.h"

@class CDTodo;

typedef NS_ENUM(NSInteger, DetailCellStyle){
    DetailCellStyleText,
    DetailCellStyleMultiLineText,
    DetailCellStyleMap,
    DetailCellStylePhoto
};

@interface DetailTableViewCell : UITableViewCell<SGViews>
- (void)setModel:(CDTodo *)model;
@end