//
//  SGBaseMapViewController.m
//  TO-DO
//
//  Created by Siegrain on 16/5/14.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "SGBaseMapViewController.h"
#import "SGLocating.h"
#import "SGCoordinate.h"
#import "UIImage+Extension.h"

//TODO: 图钉的图标需要修改

@interface SGBaseMapViewController ()
@property(nonatomic, strong) MAMapView *mapView;
@property(nonatomic, strong) MAPointAnnotation *annotation;
@property(nonatomic, strong) AMapSearchAPI *searchAPI;
@property(nonatomic, strong) SGLocating *locating;
@end

@implementation SGBaseMapViewController

#pragma mark - initial

- (void)viewDidLoad {
    self.locating = [SGLocating new];
    self.isNativeNavigationItems = YES;
    
    [super viewDidLoad];
}

- (void)setupViews {
    [super setupViews];
    
    self.title = Localized(@"Choose location");
    
    self.mapView = [MAMapView new];
    self.mapView.mapType = MAMapTypeStandard;
    self.mapView.delegate = self;
    self.mapView.userInteractionEnabled = self.isEditing;
    [self.view addSubview:self.mapView];
    
    self.searchAPI = [AMapSearchAPI new];
    self.searchAPI.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.mapView setZoomLevel:12 animated:NO];
    [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(30.663468, 104.072218) animated:YES];
    
    if (self.coordinate) {
        [self pinAnnotationAtCoordinate:self.coordinate];
    } else if (self.isEditing) {
        __weak __typeof(self) weakSelf = self;
        [_locating locatingWithAccuracy:kCLLocationAccuracyHundredMeters succeed:^(BOOL succeed, SGCoordinate *coordinate, AMapLocationReGeocode *regeocode) {
            if (!succeed) {
                [SGHelper alertWithMessage:Localized(@"Locate failed")];
                return;
            }
            if (weakSelf.coordinate) return;
            weakSelf.coordinate = coordinate;
            [weakSelf.coordinate setRegeocode:regeocode];
            
            [weakSelf.mapView setZoomLevel:17 animated:NO];
            [weakSelf pinAnnotationAtCoordinate:coordinate];
        }];
    }
}

- (void)bindConstraints {
    [super bindConstraints];
    
    [self.mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.offset(0);
    }];
}

- (void)rightNavButtonDidPress {
    if (!self.coordinate.generalAddress) return [SGHelper errorAlertWithMessage:@"请先获取正确的位置。"];
    if (self.block) {
        self.block(self.coordinate);
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)leftNavButtonDidPress {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - map methods

- (void)pinAnnotationAtCoordinate:(SGCoordinate *)coordinate {
    if (!coordinate) return;
    [self.mapView removeAnnotation:self.annotation];
    self.annotation = [[MAPointAnnotation alloc] init];
    self.annotation.coordinate = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude);
    self.annotation.title = coordinate.explicitAddress ?: @"正在查询...";
    
    [self.mapView addAnnotation:self.annotation];
    [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude) animated:YES];
    [self.mapView selectAnnotation:self.annotation animated:YES];
    if (!self.isEditing)[self.mapView setZoomLevel:15 animated:YES];
}

- (void)locationWithCoordinate:(SGCoordinate *)coordinate {
    AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];
    regeo.location = [AMapGeoPoint locationWithLatitude:(CGFloat) coordinate.latitude longitude:(CGFloat) coordinate.longitude];
    regeo.requireExtension = YES;
    [self.searchAPI AMapReGoecodeSearch:regeo];
}

#pragma mark - amap delegate

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation {
    if ([annotation isKindOfClass:[MAPointAnnotation class]] && self.isEditing) {
        static NSString *pointReuseIdentifier = @"pointReuseIdentifier";
        MAPinAnnotationView *annotationView = (MAPinAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIdentifier];
        if (!annotationView) annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIdentifier];
        annotationView.animatesDrop = YES;
        annotationView.canShowCallout = YES;
        return annotationView;
    }
    return nil;
}


- (void)mapView:(MAMapView *)mapView didSingleTappedAtCoordinate:(CLLocationCoordinate2D)coordinate {
    SGCoordinate *coordinate1 = [SGCoordinate coordinateWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    self.coordinate = coordinate1;
    [self.coordinate setRegeocode:nil];
    
    [self pinAnnotationAtCoordinate:coordinate1];
    [self locationWithCoordinate:coordinate1];
}

#pragma mark - amap search delegate

/* 逆地理编码回调 */
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response {
    if (!response.regeocode) {
        [SGHelper alertWithMessage:@"查询坐标信息失败！"];
        self.annotation.title = @"查询失败";
    }
    
    [self.coordinate setRegeocode:response.regeocode];
    
    self.annotation.title = self.coordinate.explicitAddress;
    [self.mapView selectAnnotation:self.annotation animated:YES];
}

- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error {
    [SGHelper alertWithMessage:@"查询坐标信息失败！"];
    self.annotation.title = @"查询失败";
}
@end