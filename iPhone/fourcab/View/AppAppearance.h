//
//  AppAppearance.h
//  fourcab
//
//  Created by Cameron Hendrix on 1/6/13.
//  Copyright (c) 2013 LeapTank. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppAppearance : NSObject

+ (void)setApplicationAppearance;
+ (NSDictionary*)labelAttributes;
+ (NSDictionary*)boldLabelAttributes;
+ (NSDictionary*)linkLabelAttributes;

+ (NSMutableAttributedString*) string:(NSString *)string withAttributes:(NSDictionary*)attributes;
+ (NSMutableAttributedString*) labelString:(NSString*)string;
+ (NSMutableAttributedString*) boldLabelString:(NSString*)string;
+ (NSMutableAttributedString*) titleLabelString:(NSString*)string;

@end
