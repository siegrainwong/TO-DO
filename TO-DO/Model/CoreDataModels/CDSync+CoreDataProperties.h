//
//  CDSync+CoreDataProperties.h
//  TO-DO
//
//  Created by Siegrain on 16/6/2.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "CDSync.h"

NS_ASSUME_NONNULL_BEGIN

@interface CDSync (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *syncStatus;
@property (nullable, nonatomic, retain) NSNumber *syncVersion;

@end

NS_ASSUME_NONNULL_END
