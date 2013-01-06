//
//  FoursquareViewController.h
//  fourcab
//
//  Created by Cameron Hendrix on 1/5/13.
//  Copyright (c) 2013 LeapTank. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BZFoursquare.h"

@interface FoursquareViewController : UIViewController
<BZFoursquareRequestDelegate>

@property (strong, nonatomic) BZFoursquare *foursquare;
@property (strong, nonatomic) BZFoursquareRequest *request;
@property (strong, nonatomic) NSDictionary *meta;
@property (strong, nonatomic) NSArray *notifications;
@property (strong, nonatomic) NSDictionary *response;

@end
