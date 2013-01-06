//
//  FloatingActivityIndicatorView.h
//  fourcab
//
//  Created by Cameron Hendrix on 1/6/13.
//  Copyright (c) 2013 LeapTank. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface FloatingActivityIndicatorView : UIView

@property (strong, nonatomic) UIActivityIndicatorView *spinner;

- (void) initialize;
- (void) startAnimating;
- (void) stopAnimating;

@end
