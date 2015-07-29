//
//  MapViewController.m
//  MapProject2
//
//  Created by Cynthia Whitlatch on 7/29/15.
//  Copyright (c) 2015 Cynthia Whitlatch. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "MapViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface MapViewController () <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _mapView.showsUserLocation = YES;
    
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    }
    
    [self.locationManager startUpdatingLocation];
    
    [[self locationManager] setDesiredAccuracy:kCLLocationAccuracyBest];
    [[self locationManager] startUpdatingLocation];
    
    [_mapView setMapType:MKMapTypeStandard];
    [_mapView setZoomEnabled:YES];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
