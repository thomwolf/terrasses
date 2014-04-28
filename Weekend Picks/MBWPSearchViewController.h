//
//  MTSearchViewController.h
//  Transit PDX
//
//  Created by Justin Miller on 6/15/12.
//  Copyright (c) 2012 MapBox / Development Seed. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MBWPSearchViewController;

@protocol MBWPSearchDelegate <NSObject>

- (void)searchViewController:(MBWPSearchViewController *)controller didApplyFilterTypes:(NSArray *)filterTypes;

@end

#pragma mark -

@interface MBWPSearchViewController : UITableViewController

@property (weak) id <MBWPSearchDelegate>delegate;
@property (strong, nonatomic) NSArray *favorites;

@end
