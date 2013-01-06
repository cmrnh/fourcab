//
//  FloatingActivityIndicatorView.m
//  fourcab
//
//  Created by Cameron Hendrix on 1/6/13.
//  Copyright (c) 2013 LeapTank. All rights reserved.
//

#import "FloatingActivityIndicatorView.h"

@implementation FloatingActivityIndicatorView

@synthesize spinner;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void) initialize
{
    self.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.75f];//[UIColor colorWithWhite:0.0f alpha:0.5f];
    self.layer.cornerRadius = 8.0f;
    
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    
    self.alpha = 0.0f;
    spinner.alpha = 0.0f;
    
    [self addSubview:spinner];
}

- (void) startAnimating
{
    [spinner startAnimating];
    [UIView animateWithDuration:0.5f animations:^{
        self.alpha = 1.0f;
        spinner.alpha = 1.0f;
    }];
    [self setHidden:NO];
}

- (void) stopAnimating
{
    [spinner stopAnimating];
    [UIView animateWithDuration:0.5f animations:^{
        self.alpha = 0.0f;
        spinner.alpha = 0.0f;
    }];
    [self setHidden:YES];
}

@end
