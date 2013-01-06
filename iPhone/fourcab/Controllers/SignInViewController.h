//
//  SignInViewController.h
//  fourcab
//
//  Created by Cameron Hendrix on 1/5/13.
//  Copyright (c) 2013 LeapTank. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignInViewController : UIViewController
<UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *signInView;
@property (strong, nonatomic) IBOutlet UIWebView *webView;

- (IBAction)connectAction:(id)sender;

@end
