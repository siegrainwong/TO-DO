//
// Created by Siegrain on 16/11/9.
// Copyright (c) 2016 com.siegrain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MJExtension.h"

@class AMapReGeocode;

@interface SGCoordinate : NSObject
/*纬度*/
@property(nonatomic, assign) double latitude;
/*经度*/
@property(nonatomic, assign) double longitude;

/*地址全名*/
@property(nonatomic, strong, readonly) NSString *address;
/*大概地址*/
@property(nonatomic, strong) NSString *generalAddress;
/*详细地址*/
@property(nonatomic, strong) NSString *explicitAddress;

- (void)setRegeocode:(id)regeocode;

#pragma mark -

+ (instancetype)coordinateWithLatitude:(double)latitude longitude:(double)longitude;

@end