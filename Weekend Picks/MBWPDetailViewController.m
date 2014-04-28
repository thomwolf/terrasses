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
#import "HorizontalTableView.h"

@interface MBWPDetailViewController ()

//@property (strong, nonatomic) NSDictionary *terrasseDescription;
//@property (nonatomic, retain) NSArray *weather;
@property (strong, nonatomic) NSNumber *first_time;
@property (strong, nonatomic) NSNumber * max_time;
@property (strong, nonatomic) NSDictionary * terr_info;
@property (strong, nonatomic) NSArray * terr_time_table;
//@property (nonatomic, retain) IBOutlet HorizontalTableView *tableView;
//@property (nonatomic, retain) IBOutlet UIView *columnView;
//@property (strong, nonatomic) UIImageView *myImageView;
//@property (strong, nonatomic) NSString *detailTitle;
//@property (strong, nonatomic) NSString *detailDescription;

@end

@implementation MBWPDetailViewController

static NSString * const BaseURLString = @"http://terrasses.alwaysdata.net/";
static NSString * const MarkerURLString = @"http://terrasses.alwaysdata.net/images/leaf-sun.png";

//@synthesize columnView;
//@synthesize tableView;
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
        NSDictionary * terrasseDescription = (NSDictionary *)responseObject;
        NSLog(@"Youhou");
        NSLog(terrasseDescription.description);
        self.terr_info = [terrasseDescription terr_info];
        self.first_time = [terrasseDescription first_time];
        self.max_time = [terrasseDescription max_time];
        self.terr_info = [terrasseDescription terr_info];
        self.terr_time_table = [terrasseDescription terr_time_table];
        [self setupAll];
        
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


- (void)setupAll{
    
    self.title = [self.terr_info placename_ter];
    
    NSString *tintColorHexString = [self.navigationController.navigationBar.tintColor hexStringFromColor];
    
    CGRect  viewRect1 = self.view.bounds;
    viewRect1.origin.y = 400;
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:viewRect1];
    
    webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    webView.delegate = self;
    
    [self.view addSubview:webView];
    
    NSMutableString *contentString = [NSMutableString string];
    
    [contentString appendString:@"<style type='text/css'>"];
    [contentString appendString:[NSString stringWithFormat:@"a:link { color: #%@; text-decoration: none; }", tintColorHexString]];
    [contentString appendString:@"body { font-family: Helvetica, Arial, Verdana, sans-serif; }"];
    [contentString appendString:@"</style>"];
    
    [contentString appendString:[NSMutableString stringWithFormat:@"<h3>%@</h3>", self.terr_info.description]];
    //    [contentString appendString:[NSString stringWithFormat:@"<div>%@</div>", self.detailDescription]];
    
    [webView loadHTMLString:contentString baseURL:nil];
    
    UIImageView * myImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 352, 300.0)];
    
    myImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    //        myImageView.delegate = self;
    
    [self.view addSubview:myImageView];
    
    //NSString *markerURL = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)MarkerURLString, NULL, (__bridge CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ", CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)));
    
    NSString *markerURL = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)MarkerURLString, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8));
    
    
    //NSString * markerURL = [MarkerURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    double lat = [[self.terr_info latitude] doubleValue];
    double lng = [[self.terr_info longitude] doubleValue];
    
    NSString * terimg = [NSString stringWithFormat:@"http://api.tiles.mapbox.com/v3/thomwolf.hkfl24gn/url-%@(%f,%f)/%f,%f,18/352x300.png",markerURL,lng,lat,lng,lat];
    
    //NSString * terimg = [NSString stringWithFormat:@"http://api.tiles.mapbox.com/v3/thomwolf.hkfl24gn/%f,%f,18/300x100.png",[[self.terrasseDescription terr_longitude] doubleValue],[[self.terrasseDescription terr_latitude] doubleValue]];
    
    NSLog(terimg.description);
    
    [myImageView setImageWithURL:[NSURL URLWithString:terimg]];
    
    
    HorizontalTableView *tableView = [[HorizontalTableView alloc] initWithFrame:CGRectMake(0.0, 300.0, 352, 100.0)];
    
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    tableView.delegate = self;
    
    NSLog(tableView.debugDescription);
    
    //        CALayer *layer = [tableView layer];
    //        [layer setCornerRadius:15.0f];
    [self.view addSubview:tableView];
    
    
/*    NSMutableArray *colorArray = [[NSMutableArray alloc] init];
    NSInteger step = 20;
    for (NSInteger i = 0; i < 255; i += step) {
        CGFloat f = (float)i/255.0f;
        UIColor *clr = [UIColor colorWithRed:f green:f blue:f alpha:1.0f];
        [colorArray addObject:clr];
    }
    self.weather = colorArray;
    NSLog([NSString stringWithFormat:@"%ld", self.weather.count]);*/
    //         [tableView refreshData];
    [tableView performSelector:@selector(refreshData) withObject:nil afterDelay:0.3f];
}

#pragma mark -
#pragma mark HorizontalTableViewDelegate methods

- (NSInteger)numberOfColumnsForTableView:(HorizontalTableView *)tableView {
    NSLog([NSString stringWithFormat:@"%ld", (unsigned long)self.terr_time_table.count]);
    return [self.terr_time_table count];
}

- (UIView *)tableView:(HorizontalTableView *)aTableView viewForIndex:(NSInteger)index {
    
    UIView *vw = [aTableView dequeueColumnView];
    if (!vw) {
        //       NSLog(@"Constructing new view");
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 40, 40)];
        [label setText:@"8"];
        label.textAlignment = NSTextAlignmentCenter;
        label.tag=1234;
        
        UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 50, 40, 40)];
        img.tag=4321;
        
        UIView *mView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 100)];
        
        [mView addSubview:label];
        [mView addSubview:img];
        
        vw = mView;
    }
    [vw setBackgroundColor: [UIColor whiteColor]];
    //    NSLog(vw.debugDescription);
    
    
    UILabel *lbl = (UILabel *)[vw viewWithTag:1234];
    int timeS = index + [self.first_time intValue];
    
    lbl.text = [NSString stringWithFormat:@"%d", timeS];

 //   [lbl setCenter:CGPointMake(vw.frame.size.width / 2, 10.0)];
    
    UIImageView *imagg = (UIImageView *)[vw viewWithTag:4321];
    double nbrtot = [[self.terr_info nombretot] intValue];
    int quarter = (int) floor([[[self.terr_time_table objectAtIndex:index] nombresoleil] doubleValue]/nbrtot)*4;
    NSLog(@"nbrtot: %f, nombresoleil: %f",nbrtot, [[[self.terr_time_table objectAtIndex:index] nombresoleil] doubleValue]);
    NSString * name = [NSString stringWithFormat:@"sun%d.png",quarter];
    NSLog(name);
    imagg.image = [UIImage imageNamed: name];
    
	return vw;
}

- (CGFloat)columnWidthForTableView:(HorizontalTableView *)tableView {
    return 40.0f;
}

#pragma mark -

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeLinkClicked)
        [[UIApplication sharedApplication] openURL:request.URL];
    
    return [[request.URL scheme] isEqualToString:@"about"];
}

@end