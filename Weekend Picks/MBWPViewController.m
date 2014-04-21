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

#import "NSDictionary+terrasses.h"
#import "NSDictionary+terrasses_package.h"
#import "UIColor+MBWPExtensions.h"

#define kNormalMapID  @"examples.map-zr0njcqy"
#define kRetinaMapID  @"examples.map-zjm2w6i9"
#define kTintColorHex @"#AA0000"

static NSString * const BaseURLString = @"http://terrasses.alwaysdata.net/";

@interface MBWPViewController ()

@property (strong) IBOutlet RMMapView *mapView;
@property (strong) NSArray *activeFilterTypes;
@property (strong) NSDictionary *terrasses;
@property (nonatomic, assign) RMSphericalTrapezium startbounds;

@end

#pragma mark -

@implementation MBWPViewController

@synthesize mapView;
@synthesize activeFilterTypes;
@synthesize terrasses;

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
    
    self.mapView.zoom = 16;
    
    self.mapView.userTrackingMode = RMUserTrackingModeFollow;
    
    [self.mapView setConstraintsSouthWest:[self.mapView.tileSource latitudeLongitudeBoundingBox].southWest 
                                northEast:[self.mapView.tileSource latitudeLongitudeBoundingBox].northEast];
    
    self.mapView.showsUserLocation = YES;
    
    self.title = [self.mapView.tileSource shortName];

    // zoom in to markers after launch
    //
    __weak RMMapView *weakMap = self.mapView; // avoid block-based memory leak

    // 1
    NSString *string = [NSString stringWithFormat:@"%@position2.php", BaseURLString];
    //NSURL *url = [NSURL URLWithString:string];
   
    /*            LON1s: boundsstart.getWest(),
     LON2s: boundsstart.getEast(),
     LAT1s: boundsstart.getSouth(),
     LAT2s: boundsstart.getNorth(),
     //limites (longitutde, latitude) de la fenêtre d'arrivée (par exemple initialisé au limites de la fenêtre pour le premier appel
     LON1e: boundsend.getWest(), //position.coords.latitude,
     LON2e: boundsend.getEast(),
     LAT1e: boundsend.getSouth(),
     LAT2e: boundsend.getNorth(), //position.coords.latitude,
     //centre (longitutde, latitude) de la fenêtre arrivée (pas trop utilisé mais en fait les terrasses sont classées par distance au centre
     lat: center.lat, //position.coords.latitude,
     lon: center.lng,
     // Pour spécifier la fonction du php utilisée
     type: "move"
*/
    NSDictionary *parameters = @{@"type": @"move",
                                 @"LON1s": [NSString stringWithFormat:@"%f", self.mapView.centerCoordinate.longitude],
                                     @"LON2s": [NSString stringWithFormat:@"%f",self.mapView.centerCoordinate.longitude],
                                 @"LAT1s": [NSString stringWithFormat:@"%f",self.mapView.centerCoordinate.latitude ],
                                 @"LAT2s": [NSString stringWithFormat:@"%f",self.mapView.centerCoordinate.latitude ],
                                 @"LON1s": [NSString stringWithFormat:@"%f",self.mapView.latitudeLongitudeBoundingBox.southWest.longitude ],
                                 @"LAT1s": [NSString stringWithFormat:@"%f",self.mapView.latitudeLongitudeBoundingBox.southWest.latitude ],
                                 @"LON2s": [NSString stringWithFormat:@"%f",self.mapView.latitudeLongitudeBoundingBox.northEast.longitude ],
                                 @"LAT2s": [NSString stringWithFormat:@"%f",self.mapView.latitudeLongitudeBoundingBox.northEast.latitude ],
                                 };
    //self.mapView.latitudeLongitudeBoundingBox.northEast.longitude
    NSURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET" URLString:string parameters:parameters error:nil];
    
    //NSURLRequest *request = [NSURLRequest requestWithURL:url];
    // 2
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    NSLog([request debugDescription]);
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
    // 3
            self.terrasses = (NSDictionary *)responseObject;
            self.title = @"JSON Retrieved";
        NSLog(responseObject);
    //        [self.tableView reloadData];
            
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

/** When a map is about to move.
 *   @param map The map view that is about to move.
 *   @param wasUserAction A Boolean indicating whether the map move is in response to a user action or not. */
- (void)beforeMapMove:(RMMapView *)map byUser:(BOOL)wasUserAction
{
    
};

/** When a map has finished moving.
 *   @param map The map view that has finished moving.
 *   @param wasUserAction A Boolean indicating whether the map move was in response to a user action or not. */
- (void)afterMapMove:(RMMapView *)map byUser:(BOOL)wasUserAction{
    
};

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
        if ( ! annotation.isUserLocationAnnotation)
            annotation.layer.hidden = ! [self.activeFilterTypes containsObject:[annotation.userInfo objectForKey:@"marker-symbol"]];
}

@end
