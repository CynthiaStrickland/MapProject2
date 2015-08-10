//
//  PointOfInterest.m
//  MapProject2
//
//  Created by Cynthia Whitlatch on 7/29/15.
//  Copyright (c) 2015 Cynthia Whitlatch. All rights reserved.
//

#import "PointOfInterest.h"
#import "CategoryViewController.h"

@interface PointOfInterest ()

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation PointOfInterest

@dynamic latitude;
@dynamic longitude;
@dynamic name;
@dynamic note;
@dynamic url;
@dynamic phone;
@dynamic visited;
@dynamic relationship;


-(void)PointOfInterestData {
 //   NSEntityDescription *pointOfInterest = [[NSEntityDescription entityForName:@"name" inManagedObjectContext:self.managedObjectContext];
                                            
}



@end
