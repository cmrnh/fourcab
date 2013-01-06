//
//  SignInViewController.m
//  fourcab
//
//  Created by Cameron Hendrix on 1/5/13.
//  Copyright (c) 2013 LeapTank. All rights reserved.
//

#import "SignInViewController.h"

#import "UIColor+fourcab.h"
#import "UIView+Framing.h"

@interface SignInViewController ()

@end

@implementation SignInViewController

@synthesize signInView, webView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    webView.delegate = self;
    signInView.backgroundColor = [UIColor fourcabBackgroundColor];
}


- (IBAction)connectAction:(id)sender
{
    NSString *authenticateURLString = [NSString stringWithFormat:@"https://foursquare.com/oauth2/authenticate?client_id=%@&response_type=token&redirect_uri=%@", kFoursquareClientId, kFoursquareCallbackURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:authenticateURLString]];
    [webView loadRequest:request];
    
    [UIView transitionFromView:signInView toView:webView duration:1.0 options:UIViewAnimationOptionTransitionFlipFromRight completion:^(BOOL finished) {
        if (finished) {
            // Do something
        }
    }];
}

#pragma mark - <UIWebViewDelegate>

- (BOOL)webView:(UIWebView *)wv shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"shouldStartLoadWithRequest");
    NSLog(@"request.URL = %@",request.URL);
    
    if ([request.URL.scheme isEqualToString:@"itms-apps"]) {
        NSLog(@"request.URL.scheme isEqualToString:@'itms-apps'");
        [[UIApplication sharedApplication] openURL:request.URL];
        return NO;
    }
    
    NSString *URLString = [[request URL] absoluteString];
    if ([URLString rangeOfString:@"access_token="].location != NSNotFound) {
        NSString *accessToken = [[URLString componentsSeparatedByString:@"="] lastObject];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:accessToken forKey:kFoursquareAccessToken];
        [defaults synchronize];
        NSLog(@"accessToken = %@",accessToken);
        [self performSegueWithIdentifier:kSignInSegueId sender:self];
        return NO;
    }
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)wv
{
    NSLog(@"webViewDidFinishLoad");
    NSString *URLString = [[wv.request URL] absoluteString];
    NSLog(@"--> %@", URLString);
    if ([URLString rangeOfString:@"access_token="].location != NSNotFound) {
        NSString *accessToken = [[URLString componentsSeparatedByString:@"="] lastObject];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:accessToken forKey:kFoursquareAccessToken];
        [defaults synchronize];
        NSLog(@"accessToken = %@",accessToken);
        [self dismissViewControllerAnimated:YES completion:^{
            [self performSegueWithIdentifier:kSignInSegueId sender:self];
        }];
    }
}

@end
