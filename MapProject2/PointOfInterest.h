//
//  PointOfInterest.h
//  MapProject2
//
//  Created by Cynthia Whitlatch on 7/29/15.
//  Copyright (c) 2015 Cynthia Whitlatch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "AppDelegate.h"

@class CategoryViewController;

@interface PointOfInterest : NSManagedObject

@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * note;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSNumber * visited;
@property (nonatomic, retain) CategoryViewController *relationship;

@end
