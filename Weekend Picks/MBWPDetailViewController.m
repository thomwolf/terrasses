//
//  MBWPDetailViewController.m
//  Weekend Picks
//
//  Created by Justin Miller on 6/15/12.
//  Copyright (c) 2012 MapBox / Development Seed. All rights reserved.
//

#import "MBWPDetailViewController.h"

#import "NSDictionary+terrasses.h"
#import "NSDictionary+terrasses_package.h"
#import "UIColor+MBWPExtensions.h"
#import "UIKit+AFNetworking.h"

@interface MBWPDetailViewController ()

@property (strong, nonatomic) NSDictionary *terrasseDescription;
//@property (strong, nonatomic) UIImageView *myImageView;
//@property (strong, nonatomic) NSString *detailTitle;
//@property (strong, nonatomic) NSString *detailDescription;

@end

@implementation MBWPDetailViewController

static NSString * const BaseURLString = @"http://terrasses.alwaysdata.net/";
static NSString * const MarkerURLString = @"http://terrasses.alwaysdata.net/images/leaf-sun.png";

//@synthesize terrasseNumber;
//@synthesize terrasseDescription;
//@synthesize myImageView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];

    // 1
    NSString *string = [NSString stringWithFormat:@"%@position2.php", BaseURLString];
    
    NSDictionary *parameters = @{@"type": @"marker",
                                 @"num": [self.terrasseNumber stringValue]
                                 };

    NSURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET" URLString:string parameters:parameters error:nil];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    NSLog([request debugDescription]);
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // 3
        self.terrasseDescription = (NSDictionary *)responseObject;
        NSLog(@"Youhou");
        NSLog(self.terrasseDescription.description);
        
//        NSNumber * first_time = [self.terrasseDescription first_time];
//        NSLog(first_time.description);
        //NSNumber * nexttime = first_time;
        
        self.title = @"Event Detail";
        
        NSString *tintColorHexString = [self.navigationController.navigationBar.tintColor hexStringFromColor];
        
        CGRect  viewRect1 = self.view.bounds;
        viewRect1.origin.y = 300;
        
        UIWebView *webView = [[UIWebView alloc] initWithFrame:viewRect1];
        
        webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        webView.delegate = self;
        
        [self.view addSubview:webView];
        
        NSMutableString *contentString = [NSMutableString string];
        
        [contentString appendString:@"<style type='text/css'>"];
        [contentString appendString:[NSString stringWithFormat:@"a:link { color: #%@; text-decoration: none; }", tintColorHexString]];
        [contentString appendString:@"body { font-family: Helvetica, Arial, Verdana, sans-serif; }"];
        [contentString appendString:@"</style>"];
        
        [contentString appendString:[NSMutableString stringWithFormat:@"<h3>%@</h3>", self.terrasseDescription.description]];
        //    [contentString appendString:[NSString stringWithFormat:@"<div>%@</div>", self.detailDescription]];
        
        [webView loadHTMLString:contentString baseURL:nil];
        
        UIImageView * myImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 300, 300.0)];
        
        myImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        //        myImageView.delegate = self;
        
        [self.view addSubview:myImageView];
        
        //NSString *markerURL = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)MarkerURLString, NULL, (__bridge CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ", CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)));

        NSString *markerURL = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)MarkerURLString, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8));

        
        //NSString * markerURL = [MarkerURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

        NSString * terimg = [NSString stringWithFormat:@"http://api.tiles.mapbox.com/v3/thomwolf.hkfl24gn/url-%@(%f,%f)/%f,%f,18/300x300.png",markerURL,[[self.terrasseDescription terr_longitude] doubleValue],[[self.terrasseDescription terr_latitude] doubleValue],[[self.terrasseDescription terr_longitude] doubleValue],[[self.terrasseDescription terr_latitude] doubleValue]];
        
        //NSString * terimg = [NSString stringWithFormat:@"http://api.tiles.mapbox.com/v3/thomwolf.hkfl24gn/%f,%f,18/300x100.png",[[self.terrasseDescription terr_longitude] doubleValue],[[self.terrasseDescription terr_latitude] doubleValue]];
        
        NSLog(terimg.description);
        
        [myImageView setImageWithURL:[NSURL URLWithString:terimg]];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        // 4
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Retrieving Weather"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
    }];
    
    // 5
    [operation start];
    
}

#pragma mark -

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeLinkClicked)
        [[UIApplication sharedApplication] openURL:request.URL];
        
    return [[request.URL scheme] isEqualToString:@"about"];
}

@end