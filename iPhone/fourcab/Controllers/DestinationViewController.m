//
//  DestinationViewController.m
//  fourcab
//
//  Created by Cameron Hendrix on 1/5/13.
//  Copyright (c) 2013 LeapTank. All rights reserved.
//

#import "DestinationViewController.h"

#import "OriginMKPointAnnotation.h"
#import "DestinationMKPointAnnotation.h"

#import "PeopleViewController.h"

#import "UIColor+fourcab.h"
#import "UIView+Framing.h"
#import "NSDictionary+JSONCategories.h"

static NSString *kDestinationAnnotId = @"destinationId";
static NSString *kOriginAnnotId = @"originId";
static NSString *kPlacemarkCellId = @"placemarkCellId";

const double bufferMeters = 4000; //Approx 2.5 mile radius

@interface DestinationViewController () {
    BOOL userDidInteractWithMap;
    double venueLatitude;
    double venueLongitude;
    double destinationLatitude;
    double destinationLongitude;
}

@end

@implementation DestinationViewController

@synthesize mapView, geocoder;
@synthesize searchBar;
@synthesize alertView, placeResults, placesTable;
@synthesize venueImageView, venueImageData;
@synthesize receivedData, receivedDictionary, vc;

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    mapView.delegate = self;
    mapView.showsUserLocation = NO;
    mapView.userInteractionEnabled = YES;

    UITapGestureRecognizer *gR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDropDestination:)];
    
    [mapView addGestureRecognizer:gR];
}

- (void) confirmDestination:(id)sender
{
    NSLog(@"Hello World");
    DestinationMKPointAnnotation *destination = (DestinationMKPointAnnotation*)[self getExistingDestinationAnnotations][0];
    OriginMKPointAnnotation *origin = [self getOriginAnnotation];
    
    //NSString *jsonRequest = [NSString stringWithFormat:@"{\"foursquareOauthToken\":\"%@\",\"pickup\":\"{\"%f\"}",self.foursquare.accessToken,origin.coordinate.latitude];
    //NSLog(@"Request: %@", jsonRequest);
    
    NSMutableDictionary *toPOST = [NSMutableDictionary dictionary];
    [toPOST setObject:self.foursquare.accessToken forKey:@"foursquareOauthToken"];
    
    NSDictionary *pickup = [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithDouble:venueLatitude],@"lat",
                            [NSNumber numberWithDouble:venueLongitude],@"lng",
                            nil];
    
    NSLog(@"pickup = %@",pickup);
    [toPOST setObject:pickup forKey:@"pickup"];
    
    NSDictionary *dropoff = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithDouble:destinationLatitude],@"lat",
                             [NSNumber numberWithDouble:destinationLongitude],@"lng",
                             nil];
    
    [toPOST setObject:dropoff forKey:@"dropoff"];
    
    NSLog(@"toPOST = %@",toPOST.description);
        
    NSURL *url = [NSURL URLWithString:@"http://fourcab.grumpypanda.net/api/checkin/"];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    NSData *requestData = [toPOST toJSON];
    
    NSLog(@"requestData = %@",[requestData description]);
    
    NSError *myError = nil;
    NSDictionary *res = [NSJSONSerialization JSONObjectWithData:requestData options:NSJSONReadingMutableLeaves error:&myError];
    NSLog(@"res description = %@",res.description);
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%d", [requestData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:requestData];
    
    //NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    
    // Create the request.
    //NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.apple.com/"]
    //                                          cachePolicy:NSURLRequestUseProtocolCachePolicy
    //                                      timeoutInterval:60.0];
    // create the connection with the request
    // and start loading the data
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (theConnection) {
        NSLog(@"Connected");
        // Create the NSMutableData to hold the received data.
        // receivedData is an instance variable declared elsewhere.
        receivedData = [NSMutableData data];
    } else {
        NSLog(@"Connection Failed");
        // Inform the user that the connection failed.
    }

    [self performSegueWithIdentifier:kShowPeopleSegueId sender:self];
}

#pragma mark - Gesture Recognizer Events

- (void) handleDropDestination:(UIGestureRecognizer*)sender
{
    userDidInteractWithMap = YES;
    
    //if (sender.state != UIGestureRecognizerStateBegan)
    //    return;
    
    //Remove other annotations added by the user, since there can only be one "lost" or "found" location
    [self.mapView removeAnnotations:[self getExistingDestinationAnnotations]];
    
    CGPoint touchPoint = [sender locationInView:self.mapView];
    CLLocationCoordinate2D touchMapCoordinate = [mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    
    DestinationMKPointAnnotation *annotation = [[DestinationMKPointAnnotation alloc] init];
    annotation.title = @"Destination";
    annotation.coordinate = touchMapCoordinate;
    
    destinationLatitude = touchMapCoordinate.latitude;
    destinationLongitude = touchMapCoordinate.longitude;
    
    [mapView addAnnotation:annotation];
    [mapView selectAnnotation:annotation animated:YES];
}

#pragma mark - <UIGestureRecognizerDelegate>

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}
                                   
#pragma mark - <MKMapViewDelegate>

- (void)mapView:(MKMapView *)mv didUpdateUserLocation:(MKUserLocation *)userLocation
{
    // if (userDidInteractWithMap) return;
    
    // [mv setRegion:MKCoordinateRegionMakeWithDistance(userLocation.coordinate, bufferMeters, bufferMeters) animated:YES];
}

- (MKAnnotationView *)mapView:(MKMapView *)mv viewForAnnotation:(id < MKAnnotation >)annotation
{
    if ([annotation isKindOfClass:[DestinationMKPointAnnotation class]])
    {
        MKPinAnnotationView *annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                                                              reuseIdentifier:kDestinationAnnotId];
        annotationView.pinColor = MKPinAnnotationColorRed;
        annotationView.draggable = YES;
        annotationView.animatesDrop = YES;
        [annotationView setCanShowCallout:YES];
        
        UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        //[confirmButton setTitle:@"Confirm" forState:UIControlStateNormal];
        [confirmButton addTarget:self action:@selector(confirmDestination:) forControlEvents:UIControlEventTouchUpInside];
        annotationView.rightCalloutAccessoryView = confirmButton;

        return annotationView;
    } else if ([annotation isKindOfClass:[OriginMKPointAnnotation class]]) {
        MKPinAnnotationView *annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                                                              reuseIdentifier:kOriginAnnotId];
        annotationView.pinColor = MKPinAnnotationColorGreen;
        annotationView.draggable = NO;
        annotationView.animatesDrop = YES;
        [annotationView setCanShowCallout:YES];
        
        return annotationView;
    }
    
    return nil;
}

#pragma mark - <NSURLConnectionDataDelegate>

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // As chuncks of the image are received, we build our data file
    NSLog(@"received a bit of data");
    [receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // All data has been downloaded, now we can set the image in the header image view
    //[venueImageView setContentMode:UIViewContentModeScaleAspectFit];
    //venueImageView.image = [UIImage imageWithData:venueImageData];
    NSLog(@"finished receiving data");
    
    NSError *myError = nil;
    receivedDictionary = [NSJSONSerialization JSONObjectWithData:receivedData options:NSJSONReadingMutableLeaves error:&myError];
    NSLog(@"res description = %@",receivedDictionary.description);
    
    if (vc) {
        vc.dictionary = receivedDictionary;
        [vc processDictionary];
        [vc.collectionView reloadData];
    }

    //NSLog([NSJSONSerialization isValidJSONObject:receivedData] ? @"VALID" : @"NOT VALID");
}

#pragma mark - <UISearchBarDelegate>

- (void)searchBarSearchButtonClicked:(UISearchBar *)sB
{
    if ([geocoder isGeocoding]) return;
    
    [sB resignFirstResponder];
    if (!geocoder) geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:sB.text inRegion:nil completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!error)
        {
            [self choosePlaceFromPlacemarks:placemarks];
        } else {
            NSString *message;
            switch ([error code])
            {
                case kCLErrorGeocodeFoundNoResult:
                    message = @"kCLErrorGeocodeFoundNoResult";
                    break;
                case kCLErrorGeocodeCanceled:
                    return;
                case kCLErrorGeocodeFoundPartialResult:
                    message = @"kCLErrorGeocodeFoundNoResult";
                    break;
                default:
                    message = [error description];
                    break;
            }
            
            alertView =  [[UIAlertView alloc] initWithTitle:@"An error occurred."
                                                message:message
                                               delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
            [alertView show];
        }
    }];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)sB
{
    if ([geocoder isGeocoding]) [geocoder cancelGeocode];
    if ([sB isFirstResponder]) [sB resignFirstResponder];
}

#pragma mark - <UITextFieldDelegate>

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    if ([geocoder isGeocoding]) [geocoder cancelGeocode];
    if ([searchBar isFirstResponder]) [searchBar resignFirstResponder];
    return YES;
}

#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [mapView removeAnnotations:[self getExistingDestinationAnnotations]];
    
    DestinationMKPointAnnotation *annotation = [[DestinationMKPointAnnotation alloc] init];
    CLPlacemark *placemark = (CLPlacemark*)[placeResults objectAtIndex:indexPath.row];
    annotation.coordinate = CLLocationCoordinate2DMake(placemark.location.coordinate.latitude, placemark.location.coordinate.longitude);
    [self.mapView addAnnotation:annotation];
    
    [mapView setRegion:MKCoordinateRegionMakeWithDistance(annotation.coordinate, bufferMeters, bufferMeters) animated:YES];
    
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

#pragma mark - <UITableViewDataSource>

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kPlacemarkCellId];
    
    if (cell == nil) {
        // Create the cell and add the labels
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:kPlacemarkCellId];
    }
    
    CLPlacemark *placemark = (CLPlacemark*)[placeResults objectAtIndex:indexPath.row];
        
    cell.textLabel.text = ABCreateStringWithAddressDictionary(placemark.addressDictionary, NO);
    cell.textLabel.font = [UIFont systemFontOfSize:13.0f];
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return placeResults.count;
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"segue identifer = %@",segue.identifier);
    
    if (segue.identifier == @"showPeople") {
        NSLog(@"hello");
    }
    
    PeopleViewController *peopleViewController = (PeopleViewController*)[segue destinationViewController];
    
    vc = peopleViewController;
}

#pragma mark - Helper

- (NSArray*) getExistingDestinationAnnotations
{
    if (mapView.annotations == nil)
        return nil;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.class.description == 'DestinationMKPointAnnotation'"];
    return [mapView.annotations filteredArrayUsingPredicate:predicate];
}

- (OriginMKPointAnnotation*) getOriginAnnotation
{
    if (mapView.annotations == nil)
        return nil;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.class.description == 'OriginMKPointAnnotation'"];
    return [mapView.annotations filteredArrayUsingPredicate:predicate][0];
}

- (void)choosePlaceFromPlacemarks:(NSArray*)placemarks
{
    placeResults = placemarks;
    placesTable = [[UITableView alloc] initWithFrame:CGRectMake(10, 45, 264, 130) style:UITableViewStylePlain];
    placesTable.delegate = self;
    placesTable.dataSource = self;
    
    alertView = [[UIAlertView alloc] initWithTitle:@"Did you mean... " message:@"\n\n\n\n\n\n" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
    [alertView addSubview:placesTable];
    [alertView show];
}

#pragma mark - BZFoursquareRequestDelegate

- (void)requestDidFinishLoading:(BZFoursquareRequest *)request
{
    [super requestDidFinishLoading:request];
    
    NSArray *checkinsItems = (NSArray*)[[self.response objectForKey:@"checkins"] objectForKey:@"items"];
    NSDictionary *mostRecentItem = (NSDictionary*)checkinsItems[0];
    
    venueLatitude = [[[[mostRecentItem objectForKey:@"venue"] objectForKey:@"location"] objectForKey:@"lat"] doubleValue];
    venueLongitude = [[[[mostRecentItem objectForKey:@"venue"] objectForKey:@"location"] objectForKey:@"lng"] doubleValue];
        
    NSString *venueName = [[mostRecentItem objectForKey:@"venue"] objectForKey:@"name"];
    
    OriginMKPointAnnotation *originAnnotation = [[OriginMKPointAnnotation alloc] init];
    originAnnotation.title = venueName;
    originAnnotation.subtitle = @"Last Checkin";
    originAnnotation.coordinate = CLLocationCoordinate2DMake(venueLatitude, venueLongitude);
    [mapView addAnnotation:originAnnotation];
    [mapView setRegion:MKCoordinateRegionMakeWithDistance(originAnnotation.coordinate, bufferMeters, bufferMeters) animated:NO];
    [mapView selectAnnotation:originAnnotation animated:NO];
}

@end
