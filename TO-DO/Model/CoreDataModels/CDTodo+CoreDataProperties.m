//
//  CDTodo+CoreDataProperties.m
//  TO-DO
//
//  Created by Siegrain on 16/11/10.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "CDTodo+CoreDataProperties.h"

@implementation CDTodo (CoreDataProperties)

+ (NSFetchRequest<CDTodo *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Todo"];
}

@dynamic createdAt;
@dynamic deadline;
@dynamic explicitAddress;
@dynamic generalAddress;
@dynamic identifier;
@dynamic isCompleted;
@dynamic isHidden;
@dynamic latitude;
@dynamic longitude;
@dynamic objectId;
@dynamic photoUrl;
@dynamic sgDescription;
@dynamic status;
@dynamic syncStatus;
@dynamic syncVersion;
@dynamic title;
@dynamic updatedAt;
@dynamic photoPath;
@dynamic user;

@end
