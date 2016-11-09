//
// Created by Siegrain on 16/10/14.
// Copyright (c) 2016 com.lurenwang.gameplatform. All rights reserved.
//

#import "SGLocating.h"
#import "AMapSearchAPI.h"
#import "SGCoordinate.h"

@interface SGLocating () <AMapSearchDelegate>
@property(nonatomic, strong) AMapLocationManager *manager;

@end

@implementation SGLocating
- (AMapLocationManager *)manager {
    if (!_manager) {
        _manager = [AMapLocationManager new];
        _manager.locationTimeout = 10;
        _manager.reGeocodeTimeout = 10;
    }
    return _manager;
}

- (void)locatingWithAccuracy:(CLLocationAccuracy)accuracy succeed:(SGLocatingComplete)succeed {
    self.manager.desiredAccuracy = accuracy;
    [self.manager requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
            return succeed(NO, nil, nil);
        }
        
        SGCoordinate *coordinate = [SGCoordinate coordinateWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
        [coordinate setRegeocode:regeocode];
        
        succeed(YES, coordinate, regeocode);
    }];
}


@end