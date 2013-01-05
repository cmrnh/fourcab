//
//  UIView+Framing.m
//  fourcab
//
//  Created by Cameron Hendrix on 1/5/13.
//  Copyright (c) 2013 LeapTank. All rights reserved.
//

#import "UIView+Framing.h"

@implementation UIView (Framing)

- (void) setOrigin:(CGPoint)origin
{
    CGRect targetFrame = self.frame;
    targetFrame.origin = origin;
    self.frame = targetFrame;
}

- (void) setX:(CGFloat)x
{
    CGRect targetFrame = self.frame;
    targetFrame.origin.x = x;
    self.frame = targetFrame;
}

- (void) setY:(CGFloat)y
{
    CGRect targetFrame = self.frame;
    targetFrame.origin.y = y;
    self.frame = targetFrame;
}

- (void) setSize:(CGSize)size
{
    CGRect targetFrame = self.frame;
    targetFrame.size = size;
    self.frame = targetFrame;
}

- (void) setWidth:(CGFloat)width
{
    CGRect targetFrame = self.frame;
    targetFrame.size.width = width;
    self.frame = targetFrame;
}

- (void) setHeight:(CGFloat)height
{
    CGRect targetFrame = self.frame;
    targetFrame.size.height = height;
    self.frame = targetFrame;
}

@end
