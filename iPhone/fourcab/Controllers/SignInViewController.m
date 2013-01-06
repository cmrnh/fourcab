//
//  SignInViewController.m
//  fourcab
//
//  Created by Cameron Hendrix on 1/5/13.
//  Copyright (c) 2013 LeapTank. All rights reserved.
//

#import "SignInViewController.h"

#import "FloatingActivityIndicatorView.h"

#import "UIColor+fourcab.h"
#import "UIView+Framing.h"

@implementation SignInViewController

@synthesize signInView, webView, logoImageView, signInButton, floatingSpinner;
@synthesize webViewDidLoadOnce;

- (void)viewDidLoad
{
    [super viewDidLoad];
     signInView.backgroundColor = [UIColor clearColor];
    webView.backgroundColor = [UIColor clearColor];
        
    // Button
    signInButton.hidden = YES;
    
    // Image View
    logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon.png"]];
    logoImageView.clipsToBounds = NO;
    [logoImageView setSize:CGSizeMake(150,150)];
    [logoImageView setCenter:CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2)];
    logoImageView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    logoImageView.layer.shadowOffset = CGSizeMake(0,0);
    logoImageView.layer.shadowOpacity = 0.8;
    logoImageView.layer.shadowRadius = 3.0f;
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRoundedRect:logoImageView.bounds cornerRadius:24.f];
    logoImageView.layer.shadowPath = shadowPath.CGPath;
    [signInView addSubview:logoImageView];
    
    // Webview
    webView.delegate = self;
}

- (void) viewDidLayoutSubviews
{
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = signInView.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor fourcabBackgroundColor] CGColor], (id)[[UIColor fourcabDarkBlueColor] CGColor], nil];
    [signInView.layer insertSublayer:gradient atIndex:0];
}

- (void) viewDidAppear:(BOOL)animated
{
    if ([self checkForAccessToken]) {
        [self performSegueWithIdentifier:kSignInSegueId sender:self];
    }
}

- (void) viewWillDisappear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

- (BOOL) checkForAccessToken
{
    //NSLog(![[NSUserDefaults standardUserDefaults] stringForKey:kFoursquareAccessToken] ? @"YES" : @"NO");
    //NSLog(@"kFoursquareAccessToken entry = %@",[[NSUserDefaults standardUserDefaults] stringForKey:kFoursquareAccessToken]);

    if (![[NSUserDefaults standardUserDefaults] stringForKey:kFoursquareAccessToken]) {        
        [signInButton setCenter:CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2)];
        //[signInButton setY:signInButton.center.y + signInButton.frame.size.height];
        
        // There is no access token stored, so show connect button
        [UIView animateWithDuration:1.0f animations:^{
            [logoImageView setCenter:CGPointMake(logoImageView.center.x,self.view.frame.size.height / 4)];
            //[logoImageView setY:logoImageView.center.y - logoImageView.frame.size.height - (signInButton.frame.size.height / 2)];
        } completion:^(BOOL finished) {
            signInButton.hidden = NO;
        }];
        return NO;
    } else {
        return YES;
    }
}

- (IBAction)connectAction:(id)sender
{
    if (webViewDidLoadOnce) {
        [UIView transitionFromView:signInView toView:webView duration:1.0 options:UIViewAnimationOptionTransitionFlipFromRight completion:^(BOOL finished) {}];
    } else {
        floatingSpinner = [[FloatingActivityIndicatorView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 50,
                                                                                          self.view.frame.size.height / 2 - 50,
                                                                                          100, 100)];
        [self.view insertSubview:floatingSpinner atIndex:[self.view subviews].count];
        [floatingSpinner startAnimating];
        
        NSString *authenticateURLString = [NSString stringWithFormat:@"https://foursquare.com/oauth2/authenticate?client_id=%@&response_type=token&redirect_uri=%@", kFoursquareClientId, kFoursquareCallbackURL];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:authenticateURLString]];
        [webView loadRequest:request];
    }
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
    [floatingSpinner stopAnimating];
    [UIView transitionFromView:signInView toView:webView duration:1.0 options:UIViewAnimationOptionTransitionFlipFromRight completion:^(BOOL finished) {}];
    
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
