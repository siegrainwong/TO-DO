//
// Created by Siegrain on 16/11/9.
// Copyright (c) 2016 com.siegrain. All rights reserved.
//

#import "SGCoordinate.h"
#import "AMapCommonObj.h"
#import "AMapLocationKit.h"

@interface SGCoordinate ()
@property(nonatomic, strong) id regeocode;
@end

@implementation SGCoordinate
#pragma mark - accessors

- (NSString *)address {
    return [NSString stringWithFormat:@"%@%@", _generalAddress, _explicitAddress];
}

- (void)setRegeocode:(id)regeocode {
    _regeocode = regeocode;
    if (regeocode) {
        if ([regeocode isKindOfClass:[AMapReGeocode class]]) {
            AMapReGeocode *regeo = (AMapReGeocode *) regeocode;
            AMapAddressComponent *component = regeo.addressComponent;
            _generalAddress = [NSString stringWithFormat:@"%@%@%@%@", component.province, component.city, component.district, component.township];
            _explicitAddress = [regeo.formattedAddress stringByReplacingOccurrencesOfString:_generalAddress withString:@""];
        } else if ([regeocode isKindOfClass:[AMapLocationReGeocode class]]) {
            AMapLocationReGeocode *regeo = (AMapLocationReGeocode *) regeocode;
            _generalAddress = [NSString stringWithFormat:@"%@%@%@%@", regeo.province, regeo.city, regeo.district, regeo.township];
            _explicitAddress = [regeo.formattedAddress stringByReplacingOccurrencesOfString:_generalAddress withString:@""];
        }
    } else {
        _generalAddress = nil;
        _explicitAddress = nil;
    }
}

#pragma mark - initializers

- (instancetype)initWithLatitude:(double)latitude longitude:(double)longitude {
    self = [super init];
    if (self) {
        self.latitude = latitude;
        self.longitude = longitude;
    }
    
    return self;
}

+ (instancetype)coordinateWithLatitude:(double)latitude longitude:(double)longitude {
    return [[self alloc] initWithLatitude:latitude longitude:longitude];
}

@end