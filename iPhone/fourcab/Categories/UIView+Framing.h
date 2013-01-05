//
//  UIView+Framing.h
//  fourcab
//
//  Created by Cameron Hendrix on 1/5/13.
//  Copyright (c) 2013 LeapTank. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Framing)

- (void) setOrigin:(CGPoint)origin;
- (void) setX:(CGFloat)x;
- (void) setY:(CGFloat)y;
- (void) setSize:(CGSize)size;
- (void) setWidth:(CGFloat)width;
- (void) setHeight:(CGFloat)height;

@end
