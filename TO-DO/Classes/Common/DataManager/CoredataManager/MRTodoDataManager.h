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
- (BOOL)insertTodo:(CDTodo*)todo;
@end
