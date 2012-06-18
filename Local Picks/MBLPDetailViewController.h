//
//  MBLPDetailViewController.h
//  Local Picks
//
//  Created by Justin Miller on 6/15/12.
//  Copyright (c) 2012 MapBox / Development Seed. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MBLPDetailViewController : UIViewController <UIWebViewDelegate>

@property (strong) NSString *detailTitle;
@property (strong) NSString *detailDescription;

@end