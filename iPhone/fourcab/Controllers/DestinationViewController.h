//
//  DestinationViewController.h
//  fourcab
//
//  Created by Cameron Hendrix on 1/5/13.
//  Copyright (c) 2013 LeapTank. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <AddressBookUI/AddressBookUI.h>
#import <QuartzCore/QuartzCore.h>

#import "FoursquareViewController.h"

#import "PeopleViewController.h"

@interface DestinationViewController : FoursquareViewController
<MKMapViewDelegate,
UIGestureRecognizerDelegate,
UISearchBarDelegate,
UITableViewDataSource,
UITableViewDelegate,
UIAlertViewDelegate,
NSURLConnectionDelegate>

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) UIAlertView *alertView;
@property (strong, nonatomic) UITableView *placesTable;
@property (strong, nonatomic) NSArray *placeResults;
@property (strong, nonatomic) CLPlacemark *selectedPlacemark;
@property (strong, nonatomic) CLGeocoder *geocoder;
@property (strong, nonatomic) UIImageView *venueImageView;
@property (strong, nonatomic) NSMutableData *venueImageData;
@property (strong, nonatomic) NSMutableData *receivedData;
@property (strong, nonatomic) NSDictionary *receivedDictionary;
@property (strong, nonatomic) PeopleViewController *vc;

- (NSArray*) getExistingDestinationAnnotations;

@end
