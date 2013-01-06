//
//  PeopleViewController.h
//  fourcab
//
//  Created by Cameron Hendrix on 1/5/13.
//  Copyright (c) 2013 LeapTank. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FoursquareViewController.h"

@interface PeopleViewController : FoursquareViewController
<UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout,
NSURLConnectionDelegate>

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *peopleArray;
@property (strong, nonatomic) NSDictionary *dictionary;
@property (strong, nonatomic) NSMutableData *receivedData;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelButton;

- (IBAction)cancelAction:(id)sender;
- (void) processDictionary;

@end
