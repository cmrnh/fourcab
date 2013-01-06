//
//  AppAppearance.m
//  fourcab
//
//  Created by Cameron Hendrix on 1/6/13.
//  Copyright (c) 2013 LeapTank. All rights reserved.
//

#import "AppAppearance.h"
#import "UIColor+fourcab.h"

@implementation AppAppearance

+ (void) setApplicationAppearance
{
    // UINavigationBar
    UIEdgeInsets navigationBarEdgeInsets = UIEdgeInsetsMake(0.f, 14.f, 0.f, 14.f);
    UIImage *navigationBarImage = [UIImage imageNamed:@"navigationBar.png"];
    [[UINavigationBar appearance] setBackgroundImage:[navigationBarImage resizableImageWithCapInsets:navigationBarEdgeInsets resizingMode:UIImageResizingModeStretch] forBarMetrics:UIBarMetricsDefault];
    
    /**
    NSDictionary *titleTextAttributes = @{
        UITextAttributeFont : [UIFont fontWithName:@"Avenir-Black" size:18.0f],
        UITextAttributeTextColor : [UIColor whiteColor],
        UITextAttributeTextShadowColor : [UIColor blackColor]
    };
    [[UINavigationBar appearance] setTitleTextAttributes:titleTextAttributes];
    **/
     
    [[UIToolbar appearance] setBackgroundImage:[navigationBarImage resizableImageWithCapInsets:navigationBarEdgeInsets resizingMode:UIImageResizingModeStretch] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    
    //[[UINavigationBar appearance] setTitleVerticalPositionAdjustment:1.0f forBarMetrics:UIBarMetricsDefault];
    
    // UIBarButtonItem
    UIEdgeInsets backButtonEdgeInsets = UIEdgeInsetsMake(0.f, 16.f, 0.f, 8.f);
    UIImage *backButtonNormalImage = [UIImage imageNamed:@"backButton-normal.png"];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:[backButtonNormalImage resizableImageWithCapInsets:backButtonEdgeInsets resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    UIImage *backButtonHighlightedImage = [UIImage imageNamed:@"backButton-highlighted.png"];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:[backButtonHighlightedImage resizableImageWithCapInsets:backButtonEdgeInsets resizingMode:UIImageResizingModeStretch] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    
    UIEdgeInsets barButtonItemEdgeInsets = UIEdgeInsetsMake(0.f, 8.f, 0.f, 8.f);
    UIImage *barButtonItemNormalImage = [UIImage imageNamed:@"barButtonItem-normal.png"];
    [[UIBarButtonItem appearance] setBackgroundImage:[barButtonItemNormalImage resizableImageWithCapInsets:barButtonItemEdgeInsets resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    UIImage *barButtonItemHighlightedImage = [UIImage imageNamed:@"barButtonItem-highlighted.png"];
    [[UIBarButtonItem appearance] setBackgroundImage:[barButtonItemHighlightedImage resizableImageWithCapInsets:barButtonItemEdgeInsets resizingMode:UIImageResizingModeStretch] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UIToolbar class], nil] setBackgroundImage:[barButtonItemNormalImage resizableImageWithCapInsets:barButtonItemEdgeInsets resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UIToolbar class], nil] setBackgroundImage:[barButtonItemHighlightedImage resizableImageWithCapInsets:barButtonItemEdgeInsets resizingMode:UIImageResizingModeStretch] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    
    NSDictionary *barButtonItemTextAttributes = @{
    UITextAttributeFont : [UIFont fontWithName:@"Avenir-Heavy" size:13.0f],
    UITextAttributeTextColor : [UIColor whiteColor],
    UITextAttributeTextShadowColor : [UIColor blackColor],
    };
    [[UIBarButtonItem appearance] setTitleTextAttributes:barButtonItemTextAttributes forState:UIControlStateNormal];
    [[UIBarButtonItem appearance] setTitleTextAttributes:barButtonItemTextAttributes forState:UIControlStateHighlighted];
    
    [[UIBarButtonItem appearance] setTitlePositionAdjustment:UIOffsetMake(0.f, 1.0f) forBarMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0.f, 1.0f) forBarMetrics:UIBarMetricsDefault];
    
    // Search Bar
    UIImage *searchBarImage = [UIImage imageNamed:@"searchBarBackground.png"];
    [[UISearchBar appearance] setBackgroundImage:[searchBarImage resizableImageWithCapInsets:UIEdgeInsetsMake(3, 0, 3, 0) resizingMode:UIImageResizingModeStretch]];
}

+ (NSDictionary*) labelAttributes
{
    NSDictionary *attributes = @{
        NSFontAttributeName : [UIFont fontWithName:@"Avenir-Book" size:13.0f],
        NSForegroundColorAttributeName : [UIColor darkGrayColor],
        NSBackgroundColorAttributeName : [UIColor clearColor],
    };
    return attributes;
}

+ (NSDictionary*) boldLabelAttributes
{
    NSDictionary *attributes = @{
        NSFontAttributeName : [UIFont fontWithName:@"Avenir-Heavy" size:13.0f],
        NSForegroundColorAttributeName : [UIColor blackColor],
        NSBackgroundColorAttributeName : [UIColor clearColor],
    };
    return attributes;
}

+ (NSDictionary*) linkLabelAttributes
{
    NSDictionary *attributes = @{
        NSFontAttributeName : [UIFont fontWithName:@"Avenir-Heavy" size:13.0f],
        NSForegroundColorAttributeName : [UIColor fourcabDarkBlueColor],
        NSBackgroundColorAttributeName : [UIColor clearColor],
    };
    return attributes;
}

+ (NSMutableAttributedString*) string:(NSString *)string withAttributes:(NSDictionary*)attributes
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string attributes:attributes];
    return attributedString;
}

+ (NSMutableAttributedString*) labelString:(NSString *)string
{
    return [AppAppearance string:string withAttributes:[AppAppearance labelAttributes]];
}

+ (NSMutableAttributedString*) boldLabelString:(NSString*)string
{
    return [AppAppearance string:string withAttributes:[AppAppearance boldLabelAttributes]];
}

+ (NSMutableAttributedString*) titleLabelString:(NSString*)string
{
    NSDictionary *attributes = @{
        NSFontAttributeName : [UIFont fontWithName:@"Avenir-Heavy" size:18.0f],
        NSForegroundColorAttributeName : [UIColor blackColor],
        NSBackgroundColorAttributeName : [UIColor clearColor],
    };
    return [AppAppearance string:string withAttributes:attributes];
}

@end
