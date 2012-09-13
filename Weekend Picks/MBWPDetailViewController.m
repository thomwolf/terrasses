//
//  MBWPDetailViewController.m
//  Weekend Picks
//
//  Created by Justin Miller on 6/15/12.
//  Copyright (c) 2012 MapBox / Development Seed. All rights reserved.
//

#import "MBWPDetailViewController.h"

#import "UIColor+MBWPExtensions.h"

@implementation MBWPDetailViewController

@synthesize detailTitle;
@synthesize detailDescription;

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Event Detail";
    
    NSString *tintColorHexString = [self.navigationController.navigationBar.tintColor hexStringFromColor];
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    
    webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

    webView.delegate = self;
    
    [self.view addSubview:webView];
    
    NSMutableString *contentString = [NSMutableString string];
    
    [contentString appendString:@"<style type='text/css'>"];
    [contentString appendString:[NSString stringWithFormat:@"a:link { color: #%@; text-decoration: none; }", tintColorHexString]];
    [contentString appendString:@"body { font-family: Helvetica, Arial, Verdana, sans-serif; }"];
    [contentString appendString:@"</style>"];
    
    [contentString appendString:[NSMutableString stringWithFormat:@"<h3>%@</h3>", self.detailTitle]];
    [contentString appendString:[NSString stringWithFormat:@"<div>%@</div>", self.detailDescription]];

    [webView loadHTMLString:contentString baseURL:nil];
}

#pragma mark -

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeLinkClicked)
        [[UIApplication sharedApplication] openURL:request.URL];
        
    return [[request.URL scheme] isEqualToString:@"about"];
}

@end