//
//  MTSearchViewController.h
//  Transit PDX
//
//  Created by Justin Miller on 6/15/12.
//  Copyright (c) 2012 MapBox / Development Seed. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MBLPSearchViewController;

@protocol MBLPSearchDelegate <NSObject>

- (void)searchViewController:(MBLPSearchViewController *)controller didApplyFilterTypes:(NSArray *)filterTypes;

@end

#pragma mark -

@interface MBLPSearchViewController : UITableViewController

@property (weak) id <MBLPSearchDelegate>delegate;
@property (strong) NSArray *filterTypes;

@end