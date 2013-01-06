//
//  FoursquareViewController.m
//  fourcab
//
//  Created by Cameron Hendrix on 1/5/13.
//  Copyright (c) 2013 LeapTank. All rights reserved.
//

#import "FoursquareViewController.h"

@interface FoursquareViewController ()

@end

@implementation FoursquareViewController

@synthesize foursquare, request;
@synthesize meta, notifications, response;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    foursquare = [[BZFoursquare alloc] initWithClientID:kFoursquareClientId callbackURL:kFoursquareCallbackURL];
    [foursquare setAccessToken:[[NSUserDefaults standardUserDefaults] stringForKey:kFoursquareAccessToken]];
    
    foursquare.version = @"20111119";
    foursquare.locale = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
        
    [self getLastCheckin];
}

- (void)getLastCheckin {
    [self prepareForRequest];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:@"1", @"limit", @"newestfirst", @"sort", nil];
    self.request = [foursquare requestWithPath:@"users/self/checkins" HTTPMethod:@"GET" parameters:parameters delegate:self];
    
    [request start];

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

#pragma mark - BZFoursquareRequestDelegate

- (void)requestDidFinishLoading:(BZFoursquareRequest *)request
{
    self.meta = request.meta;
    self.notifications = request.notifications;
    self.response = request.response;
    self.request = nil;
    
    //NSLog(@"self.meta = %@",self.meta.description);
    //NSLog(@"self.notifications = %@",self.notifications.description);
    //NSLog(@"self.response = %@",self.response.description);

    //NSDictionary *dict = (NSDictionary*)[self.response objectForKey:@"checkins"];
    //NSLog(@"checkins = %@",dict.description);
   
    //NSArray *data = (NSArray*)[[self.response objectForKey:@"checkins"] objectForKey:@"items"];
    
    //NSDictionary *dict = (NSDictionary*)data[0];
    
   // NSString *lat = [[[dict objectForKey:@"venue"] objectForKey:@"location"] objectForKey:@"lat"];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)request:(BZFoursquareRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"%s: %@", __PRETTY_FUNCTION__, error);
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[[error userInfo] objectForKey:@"errorDetail"] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
    [alertView show];
    
    self.meta = request.meta;
    self.notifications = request.notifications;
    self.response = request.response;
    self.request = nil;
        
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

#pragma mark - Anonymous

- (void)cancelRequest {
    if (request) {
        request.delegate = nil;
        [request cancel];
        self.request = nil;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
}

- (void)prepareForRequest {
    [self cancelRequest];
    meta = nil;
    notifications = nil;
    response = nil;
}

@end
