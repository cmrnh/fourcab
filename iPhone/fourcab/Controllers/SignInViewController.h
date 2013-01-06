//
//  SignInViewController.h
//  fourcab
//
//  Created by Cameron Hendrix on 1/5/13.
//  Copyright (c) 2013 LeapTank. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class FloatingActivityIndicatorView;

@interface SignInViewController : UIViewController
<UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *signInView;
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UIButton *signInButton;
@property (strong, nonatomic) UIImageView *logoImageView;
@property (nonatomic) BOOL webViewDidLoadOnce;
@property (strong, nonatomic) FloatingActivityIndicatorView *floatingSpinner;

- (IBAction)connectAction:(id)sender;

@end
