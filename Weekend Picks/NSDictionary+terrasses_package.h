//
//  NSDictionary+terrasses_package.h
//  INSPIRED FROM WeatherTutorial
//
//  Created by Scott on 26/01/2013.
//  Updated by Joshua Greene 16/12/2013.
//  Updated Thom WOLF 15/04/2014
//
//  Copyright (c) 2013 Scott Sherwood. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (terrasses_package)

- (NSNumber *)first_time;
- (NSArray *)tableau;

- (NSNumber *)num;
- (NSString *)address;
- (NSNumber *)zip;
- (NSString *)dosred_type;
- (NSNumber *)longitude;
- (NSNumber *)latitude;
- (NSString *)placename_ter;
- (NSNumber *)nombretot;
- (NSNumber *)nombresoleil;
- (NSNumber *)time_num;
//-(NSArray *)upcomingWeather;

@end