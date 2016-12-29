//
//  CDUser+CoreDataProperties.m
//  TO-DO
//
//  Created by Siegrain on 16/12/20.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "CDUser+CoreDataProperties.h"

@implementation CDUser (CoreDataProperties)

+ (NSFetchRequest<CDUser *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"User"];
}

@dynamic avatar;
@dynamic avatarData;
@dynamic createdAt;
@dynamic email;
@dynamic name;
@dynamic objectId;
@dynamic phoneIdentifier;
@dynamic updatedAt;
@dynamic username;
@dynamic enableAutoSync;
@dynamic enableAutoReminder;
@dynamic lastSyncTime;
@dynamic syncRecords;
@dynamic todos;

@end
