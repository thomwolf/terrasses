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

#define kNormalMapID  @"thomwolf.hkfl24gn"
#define kRetinaMapID  @"thomwolf.hkfl24gn"
#define kTintColorHex @"#AA0000"
#define CLUSTER_ZOOM 17

static NSString * const BaseURLString = @"http://terrasses.alwaysdata.net/";

@interface MBWPViewController ()

@property (strong) IBOutlet RMMapView *mapView;
@property (strong) NSArray *activeFilterTypes;
@property (strong) NSDictionary *terrasses;
@property (nonatomic, assign) RMSphericalTrapezium boundsstart;
@property (nonatomic, assign) BOOL readyToQueryMarkers;
@property (strong) NSMutableArray *numarray;
@property (strong) NSNumber *first_time;

@end

#pragma mark -

@implementation MBWPViewController

/* @synthesize mapView;
 @synthesize activeFilterTypes;
 @synthesize terrasses;
 @synthesize numarray;*/

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithHexString:kTintColorHex];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks
                                                                                           target:self
                                                                                           action:@selector(presentSearch:)];
    
    self.navigationItem.leftBarButtonItem = [[RMUserTrackingBarButtonItem alloc] initWithMapView:self.mapView];
    self.navigationItem.leftBarButtonItem.tintColor = self.navigationController.navigationBar.tintColor;
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Map" style:UIBarButtonItemStyleBordered target:nil action:nil];
    
    // this auto-enables annotations based on simplestyle data for this map (see http://mapbox.com/developers/simplestyle/ for more info)
    //
    self.mapView.tileSource = [[RMMapBoxSource alloc] initWithMapID:([[UIScreen mainScreen] scale] > 1.0 ? kRetinaMapID : kNormalMapID)
                                              enablingDataOnMapView:self.mapView];
    
//    self.mapView.zoom = 16;
    self.mapView.minZoom = 16;
    /** Contrain zooming and panning of the map view to a given coordinate boundary.
     *   @param southWest The southwest point to constrain to.
     *   @param northEast The northeast point to constrain to. */
    [self.mapView setConstraintsSouthWest:(CLLocationCoordinate2D) {.latitude= 48.788092642076286, .longitude= 2.1996688842773433}
                                northEast:(CLLocationCoordinate2D) {.latitude=48.926108577622024, .longitude=2.4757003784179683} ];
    
    //self.mapView.userTrackingMode = RMUserTrackingModeNone;
    
    //    [self.mapView setConstraintsSouthWest:[self.mapView.tileSource latitudeLongitudeBoundingBox].southWest
    //                                northEast:[self.mapView.tileSource latitudeLongitudeBoundingBox].northEast];
    
    //self.mapView.showsUserLocation = YES;
    
    self.title = [self.mapView.tileSource shortName];
    
    [self.mapView setCenterCoordinate:(CLLocationCoordinate2D) {48.8472876, 2.3482246}];
    [self.mapView setZoom:17];
    
    _numarray = [[NSMutableArray alloc] init];
    
    RMSphericalTrapezium boundsend = self.mapView.latitudeLongitudeBoundingBox;
    CLLocationCoordinate2D center= self.mapView.centerCoordinate;
    
//    self.first_time = [[NSNumber alloc] init];
    
    NSDictionary *parameters = @{@"type": @"move",
                                 /*                              @"LON1s": [NSString stringWithFormat:@"%f", self.boundsstart.southWest.longitude],
                                  @"LON2s": [NSString stringWithFormat:@"%f",self.boundsstart.northEast.longitude],
                                  @"LAT1s": [NSString stringWithFormat:@"%f",self.boundsstart.southWest.latitude ],
                                  @"LAT2s": [NSString stringWithFormat:@"%f",self.boundsstart.northEast.latitude ],*/
                                 @"LON1s": [NSString stringWithFormat:@"%f", center.longitude],
                                 @"LON2s": [NSString stringWithFormat:@"%f",center.longitude],
                                 @"LAT1s": [NSString stringWithFormat:@"%f",center.latitude ],
                                 @"LAT2s": [NSString stringWithFormat:@"%f",center.latitude ],
                                 @"LON1e": [NSString stringWithFormat:@"%f",boundsend.southWest.longitude ],
                                 @"LAT1e": [NSString stringWithFormat:@"%f",boundsend.southWest.latitude ],
                                 @"LON2e": [NSString stringWithFormat:@"%f",boundsend.northEast.longitude ],
                                 @"LAT2e": [NSString stringWithFormat:@"%f",boundsend.northEast.latitude ],
                                 @"lon": [NSString stringWithFormat:@"%f",center.longitude ],
                                 @"lat": [NSString stringWithFormat:@"%f",center.latitude ]
                                 };
    [self getAndAddTerrassesWithParameters:parameters];
    
    self.readyToQueryMarkers = YES;
    self.mapView.clusteringEnabled = YES;
    
    //    __weak RMMapView *map = self.mapView; // avoid block-based memory leak
    
    
    // zoom in to markers after launch
    //
    /*   __weak RMMapView *weakMap = self.mapView; // avoid block-based memory leak
     
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
     });*/
}

- (void)getAndAddTerrassesWithParameters:(NSDictionary *)parameters {
    
    // 1
    NSString *string = [NSString stringWithFormat:@"%@position2.php", BaseURLString];
    
    NSURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET" URLString:string parameters:parameters error:nil];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    NSLog([request debugDescription]);
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // 3
        self.terrasses = (NSDictionary *)responseObject;
  //      NSLog(@"Youhou");
  //      NSLog(self.terrasses.description);
        
        self.first_time = [self.terrasses first_time];
//        NSLog(first_time.description);
        //NSNumber * nexttime = first_time;
        
        NSArray * tableau = [self.terrasses tableau];//['tableau'];
        NSEnumerator *enumerator;
        enumerator =  [tableau objectEnumerator]; // Vous n'êtes pas propriétaire de enumerator
        
        //NSArray * markersarray = new Array();
        NSDictionary * place;
        
        while (place = [enumerator nextObject])
        { // On boucle tant que la méthode ne renvoie pas nil (ce qui casse la condition)
            NSLog(place.description);
            if ([place latitude] && [place longitude])
            {
 //               NSLog(@"ok lat long");
                //                NSLog([place latitude].description);
                //				console.debug(numarray.indexOf(place.num));
                //                NSNumber * num = [place num];
                if (![self.numarray containsObject:place])
                {
 //                   NSLog(@"ok pas dans numarray");
                    [self.numarray addObject:place];
                    //                    NSLog([NSString stringWithFormat:@"numarray: %@", self.numarray.description]);
                    
                    // Create an element to hold all your text and markup
                    ///var container = $('<div />');
                    
                    // Delegate all event handling for the container itself and its contents to the container
                    /*container.on('click', '.placeclick', function() {
                     //						console.debug(this, this.title);
                     var url = http://terrasses.alwaysdata.net/position2.php;
                     var numero = this.id;
                     $.getJSON( url, {
                     num: numero,
                     type: "marker"//position.coords.longitude,
                     //			date: strDateTime
                     },
                     function(data) {
                     displayTerrassesInfo(numero, data);
                     });
                     });*/
                    
                    //if ([place nombresoleil] != 0)
                    //{
                    RMAnnotation * marker;
                    CLLocationCoordinate2D markercoord = CLLocationCoordinate2DMake([[place latitude] doubleValue], [[place longitude] doubleValue]);
//                    NSLog([NSString stringWithFormat:@"%f, %f",markercoord.latitude, markercoord.longitude]);
                    
                    marker = [RMAnnotation annotationWithMapView:self.mapView coordinate:markercoord andTitle:[place placename_ter]];
                    
                    //marker.userInfo = place;
                    //                    NSArray * userinfo =
                   // NSS sunny = [[place nombresoleil] intValue] == 0 ? NO : YES;
                   // NSLog(@"sunny: %d", sunny);
                   NSDictionary *userinfo = [NSDictionary dictionaryWithObjectsAndKeys:[place num],@"num", [place nombresoleil], @"sunny", [place timenext], @"timenext", nil ];//,@"value2",@"key2", nil];
 //                   NSLog(userinfo.description);
                    [marker setUserInfo:userinfo];
                    
                    [self.mapView addAnnotation:marker];
 //                   NSLog(marker.description);
  //                  NSLog(@"ok ajouté le marker");
                    //var marker = new L.marker([place.latitude, place.longitude], {icon: sunIcon, num: place.num, sunny : true});//.bindPopup(insidehtml); //place.placename_ter+"<br/>"+place.address+"<br/>"+place.zip);
                    /*if (place.timenext)
                     {
                     nexttime = first_time+parseInt(place.timenext);
                     
                     container.html("<div id='"+place.num+"' title='"+place.placename_ter+"' class='placeclick'><span class='placedraw placeset'>"+nexttime+"h - "+place.placename_ter+"</span></div>");
                     }*/
                    /*} else {
                     var marker = new L.marker([place.latitude, place.longitude], {icon: shadowIcon, num: place.num, sunny : false});//.bindPopup(insidehtml); //place.placename_ter+"<br/>"+place.address+"<br/>"+place.zip);
                     if (place.timenext)
                     {
                     nexttime = first_time+parseInt(place.timenext);
                     
                     container.html("<div id='"+place.num+"' title='"+place.placename_ter+"' class='placeclick'><span class='placedraw placerise'>"+nexttime+"h - "+place.placename_ter+"</span></div>");
                     }
                     }*/
                    /*if ([place timenext] == nil) {
                     container.html("<div id='"+place.num+"' title='"+place.placename_ter+"' class='placeclick'><a class='placedraw'>"+place.placename_ter+"</a></div>");
                     }*/
                    //				console.debug(marker);
                    // Insert the container into the popup
                    // marker.bindPopup(container[0], {maxWidth : 500});
                    
                    //markersarray.push(marker);
                } else {
 //                   NSLog(@"déjà dans numarray");
                }
            }
            //			if (place.nombresoleil == 0) {
            //
            //			} else {
            //				L.marker(locationlatLng, {icon: sunIcon}).addTo(map).bindPopup(place.placename_ter+"<br/>"+place.address+"<br/>"+place.zip);
            //			}
        }
        //		console.debug(numarray);
        //markers1.addLayers(markersarray);
        //		console.debug(markers1);
        //		map.addLayer(markers2);
        
        
        
        
        
        
        //self.title = @"JSON Retrieved";
        //        [self.tableView reloadData];*/
        
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

/**  the location of the user was updated.
 *
 *   While the showsUserLocation property is set to YES, this method is called whenever a new location update is received by the map view. This method is also called if the map view’s user tracking mode is set to RMUserTrackingModeFollowWithHeading and the heading changes.
 *
 *   This method is not called if the application is currently running in the background. If you want to receive location updates while running in the background, you must use the Core Location framework.
 *   @param mapView The map view that is tracking the user’s location.
 *   @param userLocation The location object representing the user’s latest location. */
- (void)mapView:(RMMapView *)mapView didUpdateUserLocation:(RMUserLocation *)userLocation
{
    if(!self.readyToQueryMarkers)
    {
        self.readyToQueryMarkers = YES;
    }
};

/** When a map is about to move.
 *   @param mapView The map view that is about to move.
 *   @param wasUserAction A Boolean indicating whether the map move is in response to a user action or not. */
- (void)beforeMapMove:(RMMapView *)map byUser:(BOOL)wasUserAction
{
	if (self.readyToQueryMarkers && wasUserAction)
	{
        self.boundsstart = map.latitudeLongitudeBoundingBox;
        NSLog(@"before move: %f",self.boundsstart.northEast.latitude);
    }
};

/** When a map has finished moving.
 *   @param map The map view that has finished moving.
 *   @param wasUserAction A Boolean indicating whether the map move was in response to a user action or not. */
- (void)afterMapMove:(RMMapView *)map byUser:(BOOL)wasUserAction{
    NSLog(@"after move zoom: %f",map.zoom);
    BOOL cluster = map.zoom < CLUSTER_ZOOM ? YES : NO;
    [self.mapView setClusteringEnabled:cluster];
    NSLog(@"cluster ?: %d",self.mapView.clusteringEnabled);
    
	if (self.readyToQueryMarkers && wasUserAction)
	{
        RMSphericalTrapezium boundsend = self.mapView.latitudeLongitudeBoundingBox;
        CLLocationCoordinate2D center= self.mapView.centerCoordinate;
        
        NSDictionary *parameters = @{@"type": @"move",
                                     @"LON1s": [NSString stringWithFormat:@"%f", self.boundsstart.southWest.longitude],
                                     @"LON2s": [NSString stringWithFormat:@"%f",self.boundsstart.northEast.longitude],
                                     @"LAT1s": [NSString stringWithFormat:@"%f",self.boundsstart.southWest.latitude ],
                                     @"LAT2s": [NSString stringWithFormat:@"%f",self.boundsstart.northEast.latitude ],
                                     @"LON1e": [NSString stringWithFormat:@"%f",boundsend.southWest.longitude ],
                                     @"LAT1e": [NSString stringWithFormat:@"%f",boundsend.southWest.latitude ],
                                     @"LON2e": [NSString stringWithFormat:@"%f",boundsend.northEast.longitude ],
                                     @"LAT2e": [NSString stringWithFormat:@"%f",boundsend.northEast.latitude ],
                                     @"lon": [NSString stringWithFormat:@"%f",center.longitude ],
                                     @"lat": [NSString stringWithFormat:@"%f",center.latitude ]
                                     };
        [self getAndAddTerrassesWithParameters:parameters];
    }
};

/** When a map is about to move.
 *   @param mapView The map view that is about to move.
 *   @param wasUserAction A Boolean indicating whether the map move is in response to a user action or not. */
- (void)beforeMapZoom:(RMMapView *)map byUser:(BOOL)wasUserAction
{
	if (self.readyToQueryMarkers && wasUserAction)
	{
        self.boundsstart = map.latitudeLongitudeBoundingBox;
        NSLog(@"before zoom: %f",self.boundsstart.northEast.latitude);
    }
};

/** When a map has finished moving.
 *   @param map The map view that has finished moving.
 *   @param wasUserAction A Boolean indicating whether the map move was in response to a user action or not. */
- (void)afterMapZoom:(RMMapView *)map byUser:(BOOL)wasUserAction {

    NSLog(@"after zoom: %f",map.zoom);
    BOOL cluster = map.zoom < CLUSTER_ZOOM ? YES : NO;
    [self.mapView setClusteringEnabled:cluster];
    NSLog(@"cluster ?: %d",self.mapView.clusteringEnabled);

	if (self.readyToQueryMarkers && wasUserAction)
	{
        RMSphericalTrapezium boundsend = self.mapView.latitudeLongitudeBoundingBox;
        CLLocationCoordinate2D center= self.mapView.centerCoordinate;
        
        NSDictionary *parameters = @{@"type": @"move",
                                     @"LON1s": [NSString stringWithFormat:@"%f", self.boundsstart.southWest.longitude],
                                     @"LON2s": [NSString stringWithFormat:@"%f",self.boundsstart.northEast.longitude],
                                     @"LAT1s": [NSString stringWithFormat:@"%f",self.boundsstart.southWest.latitude ],
                                     @"LAT2s": [NSString stringWithFormat:@"%f",self.boundsstart.northEast.latitude ],
                                     @"LON1e": [NSString stringWithFormat:@"%f",boundsend.southWest.longitude ],
                                     @"LAT1e": [NSString stringWithFormat:@"%f",boundsend.southWest.latitude ],
                                     @"LON2e": [NSString stringWithFormat:@"%f",boundsend.northEast.longitude ],
                                     @"LAT2e": [NSString stringWithFormat:@"%f",boundsend.northEast.latitude ],
                                     @"lon": [NSString stringWithFormat:@"%f",center.longitude ],
                                     @"lat": [NSString stringWithFormat:@"%f",center.latitude ]
                                     };
        [self getAndAddTerrassesWithParameters:parameters];
    }
};

- (RMMapLayer *)mapView:(RMMapView *)mapView layerForAnnotation:(RMAnnotation *)annotation
{
    if (annotation.isUserLocationAnnotation)
        return nil;
    
    RMMarker *marker = nil;
    
    if (annotation.isClusterAnnotation)
    {
        marker = [[RMMarker alloc] initWithUIImage:[UIImage imageNamed:@"circle.png"]];
        
        marker.opacity = 1;//0.75;
        
        marker.bounds = CGRectMake(0, 0, 75, 75);
        
        [(RMMarker *)marker setTextForegroundColor:[UIColor whiteColor]];
        
        [(RMMarker *)marker changeLabelUsingText:[NSString stringWithFormat:@"%i", [annotation.clusteredAnnotations count]]];
    }
    else
    {
        
        /** Initializes and returns a newly allocated marker object using the specified image and anchor point.
         *   @param image An image to use for the marker.
         *   @param anchorPoint A point representing a range from `0` to `1` in each of the height and width coordinate space, normalized to the size of the image, at which to place the image.
         *   @return An initialized marker object. */
        //- (id)initWithUIImage:(UIImage *)image anchorPoint:(CGPoint)anchorPoint;
        UIImage * img = nil;
        UIImage * img2 = nil;
        if ([[annotation.userInfo objectForKey:@"sunny"] intValue] > 0)
        {
            img = [UIImage imageNamed: @"leaf-sun.png"];
            img2 = [UIImage imageNamed: @"settingsun.png"];
       } else {
            img = [UIImage imageNamed: @"leaf-shadow.png"];
            img2 = [UIImage imageNamed: @"risingsun.png"];
        }
        marker = [[RMMarker alloc] initWithUIImage:img anchorPoint:CGPointMake(0.5, 1)];
        
        marker.canShowCallout = YES;
        
        marker.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            
        marker.leftCalloutAccessoryView = [[UIImageView alloc] initWithImage:img2];
       /*   if (self.activeFilterTypes)
         marker.hidden = ! [self.activeFilterTypes containsObject:[annotation.userInfo objectForKey:@"marker-symbol"]];*/
    }
    return marker;
}

- (void)tapOnCalloutAccessoryControl:(UIControl *)control forAnnotation:(RMAnnotation *)annotation onMap:(RMMapView *)map
{
    MBWPDetailViewController *detailController = [[MBWPDetailViewController alloc] initWithNibName:nil bundle:nil];
    
    detailController.terrasseNumber       = [annotation.userInfo objectForKey:@"num"];
    //    detailController.detailDescription = [annotation.userInfo objectForKey:@"description"];
    
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
