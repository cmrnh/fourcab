//
//  ConnectionManager.h
//  fourcab
//
//  Created by Cameron Hendrix on 1/5/13.
//  Copyright (c) 2013 LeapTank. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConnectionManager : NSObject
<NSURLConnectionDelegate>

@property (strong, nonatomic) NSMutableData *receivedData;
@property (strong, nonatomic) UIImageView *imageView;
- (id) initWithImageView:(UIImageView*)imageViewRef;

@end
