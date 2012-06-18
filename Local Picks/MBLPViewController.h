//
//  MBLPViewController.h
//  Local Picks
//
//  Created by Justin Miller on 6/15/12.
//  Copyright (c) 2012 MapBox / Development Seed. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RMMapViewDelegate.h"

#import "MBLPSearchViewController.h"

@interface MBLPViewController : UIViewController <RMMapViewDelegate, MBLPSearchDelegate>

@end