//
//  DataSource.h
//  MapProject2
//
//  Created by Cynthia Whitlatch on 7/29/15.
//  Copyright (c) 2015 Cynthia Whitlatch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "SearchViewController.h"

@protocol DataSourceDelegate <NSObject>

@optional

-(void)finishedSearch:(NSArray *)resultsOfSearch;

@end

@interface DataSource : NSObject

-(instancetype) initWithSearchString:(NSString*)searchString Region:(MKCoordinateRegion)region Delegate:(id<DataSourceDelegate>)delegate;

@property (nonatomic, strong) NSString *searchingString;
@property (nonatomic) MKCoordinateRegion searchingRegion;
@property (nonatomic, weak) id<DataSourceDelegate> delegate;

-(void) performSearchForText;


@end
