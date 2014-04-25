//
//  NSDictionary+terrasses_package.m
//  INSPIRED FROM WeatherTutorial
//
//  Created by Scott on 26/01/2013.
//  Updated by Joshua Greene 16/12/2013.
//  Updated Thom WOLF 15/04/2014
//
//  Copyright (c) 2013 Scott Sherwood. All rights reserved.
//

#import "NSDictionary+terrasses_package.h"

@implementation NSDictionary (terrasses_package)

- (NSNumber *)first_time
{
    NSArray *ar = self[@"first_time"];
    NSDictionary *dict = ar[0];
    NSArray* foo = [dict[@"time_value"] componentsSeparatedByString: @":"];
    return [foo firstObject];
}

- (NSArray *)tableau
{
    NSArray *ar = self[@"tableau"];
    return ar;
}

/*- (NSArray *)upcomingWeather
{
    NSDictionary *dict = self[@"data"];
    return dict[@"weather"];
}*/

@end