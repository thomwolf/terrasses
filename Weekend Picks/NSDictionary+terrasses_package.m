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

@implementation NSDictionary (weather_package)

- (NSDictionary *)currentCondition
{
    NSDictionary *dict = self[@"data"];
    NSArray *ar = dict[@"current_condition"];
    return ar[0];
}

- (NSDictionary *)request
{
    NSDictionary *dict = self[@"data"];
    NSArray *ar = dict[@"request"];
    return ar[0];
}

- (NSArray *)upcomingWeather
{
    NSDictionary *dict = self[@"data"];
    return dict[@"weather"];
}

@end