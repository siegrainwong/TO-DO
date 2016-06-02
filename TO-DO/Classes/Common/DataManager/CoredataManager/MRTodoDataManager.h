//
//  MRTodoDataManager.h
//  TO-DO
//
//  Created by Siegrain on 16/6/1.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "CDTodo.h"
#import "Localized.h"
#import "MRDataManager.h"

@interface MRTodoDataManager : MRDataManager<Localized>
- (void)insertTodo:(CDTodo*)todo complete:(void (^)(bool succeed))complete;
- (void)retrieveDataWithUser:(CDUser*)user date:(NSDate*)date complete:(void (^)(bool succeed, NSDictionary* dataDictionary, NSInteger dataCount))complete;
@end
