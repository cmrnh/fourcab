//
//  PersonViewController.m
//  fourcab
//
//  Created by Cameron Hendrix on 1/6/13.
//  Copyright (c) 2013 LeapTank. All rights reserved.
//

#import "PersonViewController.h"

#import "AppAppearance.h"

#import "UIColor+fourcab.h"
#import "UIView+Framing.h"
#import "NSDictionary+JSONCategories.h"

@implementation PersonViewController

@synthesize name, personImageView, personLabel,image;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void) viewDidLayoutSubviews
{
    if (name) self.personLabel.text = name;
    
    self.view.backgroundColor = [UIColor fourcabBackgroundColor];
    
    personImageView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    personImageView.layer.shadowRadius = 1.5f;
    personImageView.layer.shadowOpacity = 0.8f;
    personImageView.layer.shadowOffset = CGSizeMake(0,0);
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:personImageView.bounds];
    personImageView.layer.shadowPath = shadowPath.CGPath;
    
    personImageView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    personImageView.contentMode = UIViewContentModeScaleAspectFill;
    [personImageView setImage:image];
    
    /**
    [rideWithButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
    UIImage *normalButtonImage = [UIImage imageNamed:@"button-normal.png"];
    UIImage *highlightedButtonImage = [UIImage imageNamed:@"button-highlighted.png"];

    [rideWithButton setBackgroundImage:normalButtonImage forState:UIControlStateNormal];
    [rideWithButton setBackgroundImage:highlightedButtonImage forState:UIControlStateHighlighted];
    [rideWithButton.titleLabel setFont:[UIFont fontWithName:@"Noteworthy-Bold" size:17.0f]];
    [rideWithButton setTitle:@"I'd share a cab with this dude" forState:UIControlStateNormal];
    [rideWithButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
     **/
}

- (IBAction)cancelAction:(id)sender
{
    NSDictionary *dictionaryToPOST = [NSDictionary dictionaryWithObject:[[NSUserDefaults standardUserDefaults] stringForKey:kFoursquareAccessToken] forKey:@"foursquareOauthToken"];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/cancel/",fourcabAPIBaseURL]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    NSData *requestData = [dictionaryToPOST toJSON];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%d", [requestData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:requestData];
    
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (theConnection) {
        NSLog(@"connnected");
    } else {
        NSLog(@"not connected");
    }
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - <NSURLConnectionDataDelegate>

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSLog(@"received a bit of data");
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"finished receiving data");
}

@end
