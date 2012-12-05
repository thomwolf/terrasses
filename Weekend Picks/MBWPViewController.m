//
//  MBWPViewController.m
//  Weekend Picks
//
//  Created by Justin Miller on 6/15/12.
//  Copyright (c) 2012 MapBox / Development Seed. All rights reserved.
//

#import "MBWPViewController.h"

#import "MBWPSearchViewController.h"
#import "MBWPDetailViewController.h"

#import "UIColor+MBWPExtensions.h"

#define kNormalMapID  @"examples.map-yr0njcqy"
#define kRetinaMapID  @"examples.map-sjm2w6i9"
#define kTintColorHex @"#AA0000"

@interface MBWPViewController ()

@property (strong) IBOutlet RMMapView *mapView;
@property (strong) NSArray *activeFilterTypes;

@end

#pragma mark -

@implementation MBWPViewController

@synthesize mapView;
@synthesize activeFilterTypes;

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationController.navigationBar.tintColor = [UIColor colorWithHexString:kTintColorHex];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch 
                                                                                           target:self 
                                                                                           action:@selector(presentSearch:)];
    
    self.navigationItem.leftBarButtonItem = [[RMUserTrackingBarButtonItem alloc] initWithMapView:self.mapView];
    self.navigationItem.leftBarButtonItem.tintColor = self.navigationController.navigationBar.tintColor;

    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Map" style:UIBarButtonItemStyleBordered target:nil action:nil];

    // this auto-enables annotations based on simplestyle data for this map (see http://mapbox.com/developers/simplestyle/ for more info)
    //
    self.mapView.tileSource = [[RMMapBoxSource alloc] initWithMapID:([[UIScreen mainScreen] scale] > 1.0 ? kRetinaMapID : kNormalMapID)
                                              enablingDataOnMapView:self.mapView];
    
    self.mapView.zoom = 2;
    
    [self.mapView setConstraintsSouthWest:[self.mapView.tileSource latitudeLongitudeBoundingBox].southWest 
                                northEast:[self.mapView.tileSource latitudeLongitudeBoundingBox].northEast];
    
    self.mapView.showsUserLocation = YES;
    
    self.title = [self.mapView.tileSource shortName];

    // zoom in to markers after launch
    //
    __weak RMMapView *weakMap = self.mapView; // avoid block-based memory leak

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC), dispatch_get_main_queue(), ^(void)
    {
        float degreeRadius = 9000.f / 110000.f; // (9000m / 110km per degree latitude)
        
        CLLocationCoordinate2D centerCoordinate = [((RMMapBoxSource *)self.mapView.tileSource) centerCoordinate];
        
        RMSphericalTrapezium zoomBounds = {
            .southWest = {
                .latitude  = centerCoordinate.latitude  - degreeRadius,
                .longitude = centerCoordinate.longitude - degreeRadius
            },
            .northEast = {
                .latitude  = centerCoordinate.latitude  + degreeRadius,
                .longitude = centerCoordinate.longitude + degreeRadius
            }
        };
        
        [weakMap zoomWithLatitudeLongitudeBoundsSouthWest:zoomBounds.southWest
                                                northEast:zoomBounds.northEast 
                                                 animated:YES];
    });
}

#pragma mark -

- (void)presentSearch:(id)sender
{
    NSMutableArray *filterTypes = [NSMutableArray array];
    
    for (RMAnnotation *annotation in self.mapView.annotations)
    {
        if (annotation.userInfo && [annotation.userInfo objectForKey:@"marker-symbol"] && ! [[filterTypes valueForKeyPath:@"marker-symbol"] containsObject:[annotation.userInfo objectForKey:@"marker-symbol"]])
        {
            BOOL selected = ( ! self.activeFilterTypes || [self.activeFilterTypes containsObject:[annotation.userInfo objectForKey:@"marker-symbol"]]);
            
            [filterTypes addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       [annotation.userInfo objectForKey:@"marker-symbol"], @"marker-symbol",
                                       [UIImage imageWithCGImage:(CGImageRef)[self mapView:self.mapView layerForAnnotation:annotation].contents], @"image",
                                       [NSNumber numberWithBool:selected], @"selected",
                                       nil]];
        }
    }
    
    MBWPSearchViewController *searchController = [[MBWPSearchViewController alloc] initWithNibName:nil bundle:nil];
    
    searchController.delegate = self;
    searchController.filterTypes = [NSArray arrayWithArray:filterTypes];
    
    UINavigationController *wrapper = [[UINavigationController alloc] initWithRootViewController:searchController];
    
    wrapper.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
    wrapper.topViewController.title = @"Search";
    
    [self presentModalViewController:wrapper animated:YES];
}

#pragma mark -

- (RMMapLayer *)mapView:(RMMapView *)mapView layerForAnnotation:(RMAnnotation *)annotation
{
    if (annotation.isUserLocationAnnotation)
        return nil;

    RMMarker *marker = [[RMMarker alloc] initWithMapBoxMarkerImage:[annotation.userInfo objectForKey:@"marker-symbol"]
                                                      tintColorHex:[annotation.userInfo objectForKey:@"marker-color"]
                                                        sizeString:[annotation.userInfo objectForKey:@"marker-size"]];

    marker.canShowCallout = YES;

    marker.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];

    if (self.activeFilterTypes)
        marker.hidden = ! [self.activeFilterTypes containsObject:[annotation.userInfo objectForKey:@"marker-symbol"]];
    
    return marker;
}

- (void)tapOnCalloutAccessoryControl:(UIControl *)control forAnnotation:(RMAnnotation *)annotation onMap:(RMMapView *)map
{
    MBWPDetailViewController *detailController = [[MBWPDetailViewController alloc] initWithNibName:nil bundle:nil];

    detailController.detailTitle       = [annotation.userInfo objectForKey:@"title"];
    detailController.detailDescription = [annotation.userInfo objectForKey:@"description"];

    [self.navigationController pushViewController:detailController animated:YES];
}

#pragma mark -

- (void)searchViewController:(MBWPSearchViewController *)controller didApplyFilterTypes:(NSArray *)filterTypes
{
    self.activeFilterTypes = filterTypes;
    
    for (RMAnnotation *annotation in self.mapView.annotations)
        annotation.layer.hidden = ! [self.activeFilterTypes containsObject:[annotation.userInfo objectForKey:@"marker-symbol"]];
}

@end
