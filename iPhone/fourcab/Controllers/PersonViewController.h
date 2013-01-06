//
//  PersonViewController.h
//  fourcab
//
//  Created by Cameron Hendrix on 1/6/13.
//  Copyright (c) 2013 LeapTank. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface PersonViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIImageView *personImageView;
@property (strong, nonatomic) IBOutlet UIButton *rideWithButton;
@property (strong, nonatomic) IBOutlet UILabel *personLabel;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) UIImage *image;

- (IBAction)rideWithAction:(id)sender;

@end
