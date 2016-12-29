//
//  MRUserDataManager.h
//  TO-DO
//
//  Created by Siegrain on 16/6/2.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "Localized.h"
#import <Foundation/Foundation.h>

@interface MRUserDataManager : NSObject<Localized>
- (CDUser *)createUserByLCUser:(LCUser*)lcUser;
@end
