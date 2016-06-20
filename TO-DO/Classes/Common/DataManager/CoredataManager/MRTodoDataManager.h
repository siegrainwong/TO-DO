//
//  MRTodoDataManager.h
//  TO-DO
//
//  Created by Siegrain on 16/6/1.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "CDTodo.h"
#import "Localized.h"

@interface MRTodoDataManager : NSObject<Localized>
/* retrieve */
- (void)retrieveDataWithUser:(CDUser*)user date:(NSDate*)date complete:(void (^)(bool succeed, NSDictionary* dataDictionary, NSInteger dataCount))complete;
- (BOOL)hasDataWithDate:(NSDate*)date user:(CDUser*)user;

/* modify */
- (BOOL)isModifiedTodo:(CDTodo*)todo;
- (BOOL)isInsertedTodo:(CDTodo*)todo;
@end
