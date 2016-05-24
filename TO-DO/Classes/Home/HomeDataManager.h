//
//  HomeDataManager.h
//  TO-DO
//
//  Created by Siegrain on 16/5/24.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LCUser;

@interface HomeDataManager : UITableViewCell
- (void)retrieveDataWithUser:(LCUser*)user complete:(void (^)(bool succeed, NSDictionary* dataDictionary, NSArray* dateArray))complete;
@end
