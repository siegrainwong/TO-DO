//
// Created by Siegrain on 16/10/14.
// Copyright (c) 2016 com.lurenwang.gameplatform. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AMapLocation/AMapLocationKit/AMapLocationKit.h>

@class SGCoordinate;

typedef void (^SGLocatingComplete)(BOOL succeed, SGCoordinate* coordinate, AMapLocationReGeocode* location);

@interface SGLocating : NSObject
- (void)locatingWithAccuracy:(CLLocationAccuracy)accuracy succeed:(SGLocatingComplete)succeed;
@end