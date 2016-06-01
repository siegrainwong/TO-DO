//
//  Todo.h
//  TO-DO
//
//  Created by Siegrain on 16/6/1.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, CDTodoStatus) {
    /* 普通 */
    CDTodoStatusNormal,
    /* 延迟 */
    CDTodoStatusSnoozed,
    /* 过期 */
    CDTodoStatusOverdue
};

@interface Todo : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

@end

NS_ASSUME_NONNULL_END

#import "Todo+CoreDataProperties.h"
