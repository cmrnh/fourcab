//
//  PersonCollectionViewCell.m
//  fourcab
//
//  Created by Cameron Hendrix on 1/5/13.
//  Copyright (c) 2013 LeapTank. All rights reserved.
//

#import "PersonCollectionViewCell.h"

#import "UIColor+fourcab.h"
#import "UIView+Framing.h"

@implementation PersonCollectionViewCell

@synthesize imageView, spinner;

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
    self.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    self.layer.shadowRadius = 1.5f;
    self.layer.shadowOpacity = 0.8f;
    self.layer.shadowOffset = CGSizeMake(0,0);
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.bounds];
    self.layer.shadowPath = shadowPath.CGPath;
    
    imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    imageView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:imageView];
    
    //spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    //spinner.hidesWhenStopped = YES;
    //[spinner setCenter:CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2)];
    //[spinner startAnimating];
}

- (void)setImage:(UIImage*)image
{
    //[spinner stopAnimating];
    imageView.image = image;
}

@end
