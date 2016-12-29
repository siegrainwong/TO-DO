//
//  SGBaseMapViewController.h
//  TO-DO
//
//  Created by Siegrain on 16/5/14.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import <AMap2DMap/MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import "SGBaseViewController.h"

@class SGCoordinate;

typedef void (^SGLocatingFinishedBlock)(SGCoordinate * coordinate);

@interface SGBaseMapViewController : SGBaseViewController<MAMapViewDelegate, AMapSearchDelegate>
@property(nonatomic, strong) SGCoordinate *coordinate;
@property(nonatomic, copy) SGLocatingFinishedBlock block;
@end