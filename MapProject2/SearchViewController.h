//
//  SearchViewController.h
//  MapProject2
//
//  Created by Cynthia Whitlatch on 7/29/15.
//  Copyright (c) 2015 Cynthia Whitlatch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "DataSource.h"




@interface SearchViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSString *searchString;
@property (nonatomic) MKCoordinateRegion currentRegion;
@property (nonatomic, strong) NSArray *cellTester;
@property (nonatomic, strong) MKLocalSearch *localSearch;
@property (nonatomic, strong) MKUserLocation *userLocation;
@property (nonatomic, strong) NSArray *places;


@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
