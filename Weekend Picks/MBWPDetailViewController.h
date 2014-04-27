//
//  MBWPDetailViewController.h
//  Weekend Picks
//
//  Created by Justin Miller on 6/15/12.
//  Copyright (c) 2012 MapBox / Development Seed. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HorizontalTableView.h"

@interface MBWPDetailViewController : UIViewController <UIWebViewDelegate,HorizontalTableViewDelegate>

@property (strong, nonatomic) NSNumber *terrasseNumber;

@end