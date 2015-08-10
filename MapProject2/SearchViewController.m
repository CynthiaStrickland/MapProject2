//
//  SearchViewController.m
//  MapProject2
//
//  Created by Cynthia Whitlatch on 7/29/15.
//  Copyright (c) 2015 Cynthia Whitlatch. All rights reserved.
//
#import "MapViewController.h"
#import "DataSource.h"
#import "MapKit/MapKit.h"
#import "SearchViewController.h"
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>
#import "DetailViewController.h"

@interface SearchViewController () <DataSourceDelegate, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) NSMutableArray *searchResultTitles;
@property (strong, nonatomic) NSMutableArray *searchResultURL;
@property (strong, nonatomic) NSMutableArray *searchResultDistances;
@property (strong, nonatomic) NSMutableArray *searchResultPhoneNumbers;
@property (strong, nonatomic) NSMutableArray *searchResultLatitudes;
@property (strong, nonatomic) NSMutableArray *searchResultLongitudes;
@property (strong, nonatomic) NSArray *resultDictionaries;
@property (nonatomic, strong) NSIndexPath *selection;
@property (nonatomic, strong) UILabel *categoryLabel;


@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Search";
    
}

- (void)performSearch:(CLLocation *)location{
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = self.searchBar.text;
    request.region = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(.015, .015));
    
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        
        for (MKMapItem *item in response.mapItems) {
            CLLocationDistance distance = [item.placemark.location distanceFromLocation:location] / 1609.34;
            SearchObject *resultAnnotation = [[SearchObject alloc]initWithCoordinate:item.placemark.coordinate andTitle:item.name distance:distance];
            [self.searchResultTitles addObject:resultAnnotation];
            [self.mapView addAnnotation:resultAnnotation];
            NSLog(@"%f",distance);
        }
        
        [self.searchResultTitles sortUsingSelector:@selector(compare:)];
        [self.tableView reloadData];
    }];
    
}
        // ***********  TABLE VIEW **************

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchResultTitles.count;
    
    }
    
- (UITableViewCell *)cell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        UITableView *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchedCell"];
    }
        return cell;
    }

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    
    // check to see if Location Services is enabled, there are two state possibilities:
    // 1) disabled for entire device, 2) disabled just for this app
    
    NSString *causeStr = nil;
    
    // check whether location services are enabled on the device
    if ([CLLocationManager locationServicesEnabled] == NO)
    {
        causeStr = @"device";
    }
    // check the application’s explicit authorization status:
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
    {
        causeStr = @"app";
    }
    else
    {
        // we are good to go, start the search
        [self startSearch:searchBar.text];
    }
    
    if (causeStr != nil)
    {
        NSString *alertMessage = [NSString stringWithFormat:@"You currently have location services disabled for this %@. Please refer to \"Settings\" app to turn on Location Services.", causeStr];
        
        UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled"
                                                                        message:alertMessage
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
        [servicesDisabledAlert show];
    }
}

- (void)startSearch:(NSString *)searchString {
    if (self.localSearch.searching)
    {
        [self.localSearch cancel];
    }
    
    // confine the map search area to the user's current location
    MKCoordinateRegion newRegion;
    newRegion.center.latitude = self.userLocation.location.coordinate.latitude;
    newRegion.center.longitude = self.userLocation.location.coordinate.longitude;
    
    // setup the area spanned by the map region:
    // we use the delta values to indicate the desired zoom level of the map,
    // smaller delta values corresponding to a higher zoom level
    
    newRegion.span.latitudeDelta = 0.112872;
    newRegion.span.longitudeDelta = 0.109863;
    
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    
    request.naturalLanguageQuery = searchString;
    request.region = newRegion;
    
    MKLocalSearchCompletionHandler completionHandler = ^(MKLocalSearchResponse *response, NSError *error)
    {
        if (error != nil)
        {
            NSString *errorStr = [[error userInfo] valueForKey:NSLocalizedDescriptionKey];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not find places"
                                                            message:errorStr
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        else
        {
 //           self.places = [response mapItems];

            [self.tableView reloadData];
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    };
    
    if (self.localSearch != nil)
    {
        self.localSearch = nil;
    }
    self.localSearch = [[MKLocalSearch alloc] initWithRequest:request];
    
    [self.localSearch startWithCompletionHandler:completionHandler];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void) finishedSearch:(NSArray *)resultsOfSearch {
    NSArray *results = resultsOfSearch;
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"distance" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedArray = [results sortedArrayUsingDescriptors:sortDescriptors];
    
    self.resultDictionaries = [NSMutableArray arrayWithArray:sortedArray];
    
    [self generateTitleArray];
    [self generateUrlStringArray];
    [self generateDistanceFromCurrentLocation];
    [self generatePhoneArray];
    [self generateCoordinateData];
    
    [self.tableView reloadData];
}

- (void) generateCoordinateData {
    NSMutableArray *longitudes = [[NSMutableArray alloc]init];
    NSMutableArray *latitudes = [[NSMutableArray alloc]init];
    
    for (NSDictionary *dict in self.resultDictionaries) {
        [longitudes addObject:[dict objectForKey:@"long"]];
        [latitudes addObject:[dict objectForKey:@"lat"]];
    }
    
    self.searchResultLongitudes = longitudes;
    self.searchResultLatitudes = latitudes;
}

- (void) generateTitleArray {
    NSMutableArray *titles = [[NSMutableArray alloc]init];
    
    for (NSDictionary *dict in self.resultDictionaries) {
        [titles addObject:[dict objectForKey:@"name"]];
    }
    
    self.searchResultTitles = titles;
}

- (void) generateUrlStringArray {
    NSMutableArray *URLs = [[NSMutableArray alloc]init];
    
    for (NSDictionary *dict in self.resultDictionaries) {
        [URLs addObject:[dict objectForKey:@"urlString"]];
    }
    
    self.searchResultURL = URLs;
}

- (void) generatePhoneArray {
    NSMutableArray *phone = [[NSMutableArray alloc]init];
    
    for (NSDictionary *dict in self.resultDictionaries) {
        [phone addObject:[dict objectForKey:@"phone"]];
    }
    
    self.searchResultPhoneNumbers = phone;
}

- (void) generateDistanceFromCurrentLocation {
    NSMutableArray *distanceArray = [[NSMutableArray alloc]init];
    
    for (NSDictionary *dict in self.resultDictionaries) {
        NSNumber *latitude = [dict objectForKey:@"lat"];
        NSNumber *longitude = [dict objectForKey:@"long"];
        
        double LatitudeD = [latitude doubleValue];
        double LongitudeD = [longitude doubleValue];
        
        CLLocation *location = [[CLLocation alloc]initWithLatitude:LatitudeD longitude:LongitudeD];
        
        CLLocation *currentLocation = [[CLLocation alloc]initWithLatitude:self.currentRegion.center.latitude longitude:self.currentRegion.center.longitude];
        
        CLLocationDistance distance = [location distanceFromLocation:currentLocation];
        
        int distanceInt = (int)distance;
        
        NSString *distanceString = [NSString stringWithFormat:@"%dm", distanceInt];
        
        [distanceArray addObject:distanceString];
        
    }
    self.searchResultDistances = distanceArray;
}


-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"searchDetailView"])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];

        DetailViewController *detailVC = segue.destinationViewController;

        NSString *titleText = [self.searchResultTitles objectAtIndex:indexPath.row];
        NSString *uRLText = [self.searchResultURL objectAtIndex:indexPath.row];
        NSString *phoneText = [self.searchResultPhoneNumbers objectAtIndex:indexPath.row];
        NSNumber *latitude = [self.searchResultLatitudes objectAtIndex:indexPath.row];
        NSNumber *longitude = [self.searchResultLongitudes objectAtIndex:indexPath.row];

        detailVC.titleTextLabelString = titleText;
        detailVC.uRLLabel = uRLText;
        detailVC.phoneTextLabel = phoneText;
        detailVC.detailLatitude = [latitude doubleValue];
        detailVC.detailLongitude = [longitude doubleValue];

    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
