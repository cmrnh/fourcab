//
//  ConnectionManager.m
//  fourcab
//
//  Created by Cameron Hendrix on 1/5/13.
//  Copyright (c) 2013 LeapTank. All rights reserved.
//

#import "ConnectionManager.h"

@implementation ConnectionManager

@synthesize receivedData, imageView;

- (id) initWithImageView:(UIImageView*)imageViewRef
{
    self = [super init];
    imageView = imageViewRef;
    return self;
}

#pragma mark - <NSURLConnectionDataDelegate>

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // As chuncks of the image are received, we build our data file
    NSLog(@"received a bit of data");
    if (!receivedData) receivedData = [NSMutableData data];
    [receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"finished receiving data");
    imageView.image = [UIImage imageWithData:receivedData];
}

@end
