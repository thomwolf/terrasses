//
//  MBWPAppDelegate.m
//  Weekend Picks
//
//  Created by Justin Miller on 6/15/12.
//  Copyright (c) 2012 MapBox / Development Seed. All rights reserved.
//

#import "MBWPAppDelegate.h"

#import "MBWPViewController.h"

@implementation MBWPAppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[MBWPViewController alloc] initWithNibName:nil bundle:nil]];
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end