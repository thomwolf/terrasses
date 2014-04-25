//
//  NSDictionary+weather.m
//  Weather
//
//  Created by Scott on 26/01/2013.
//  Updated by Joshua Greene 16/12/2013.
//
//  Copyright (c) 2013 Scott Sherwood. All rights reserved.
//

#import "NSDictionary+terrasses.h"

@implementation NSDictionary (terrasses)

- (NSNumber *)num
{
    NSString *cc = self[@"num"];
    NSLog(cc.description);
    NSNumber *n = @([cc intValue]);
    NSLog([NSString stringWithFormat:@"n: %d", n.intValue]);
    return n;
};
- (NSString *)address
{
    return self[@"address"];
};
- (NSNumber *)zip
{
    NSString *cc = self[@"zip"];
    NSNumber *n = @([cc intValue]);
    return n;
};
- (NSString *)dosred_type
{
    return self[@"dosred_type"];
};
- (NSNumber *)longitude
{
    NSString *cc = self[@"longitude"];
    NSNumber *n = @([cc doubleValue]);
    return n;
};
- (NSNumber *)latitude
{
    NSString *cc = self[@"latitude"];
    NSNumber *n = @([cc doubleValue]);
    return n;
};
- (NSString *)placename_ter
{
    return self[@"placename_ter"];
};
- (NSNumber *)nombretot
{
    NSString *cc = self[@"nombretot"];
    NSNumber *n = @([cc intValue]);
    return n;
};
- (NSNumber *)nombresoleil
{
    NSString *cc = self[@"nombresoleil"];
    NSNumber *n = @([cc intValue]);
    return n;
};
- (NSNumber *)time_num
{
    NSString *cc = self[@"time_num"];
    NSNumber *n = @([cc intValue]);
    return n;
};

/*- (NSNumber *)cloudCover
{
    NSString *cc = self[@"cloudcover"];
    NSNumber *n = @([cc intValue]);
    return n;
}

- (NSNumber *)humidity
{
    NSString *cc = self[@"humidity"];
    NSNumber *n = @([cc intValue]);
    return n;
}

- (NSDate *)observationTime
{
//    NSString *cc = [self currentWeather][@"observation_time"];
    NSDate *n = [NSDate date]; // parse instead "09:07 PM";
    return n;
}

- (NSNumber *)precipMM
{
    NSString *cc = self[@"precipMM"];
    NSNumber *n = @([cc intValue]);
    return n;
}

- (NSNumber *)pressue
{
    NSString *cc = self[@"pressure"];
    NSNumber *n = @([cc intValue]);
    return n;
}

- (NSNumber *)tempC
{
    NSString *cc = self[@"temp_C"];
    NSNumber *n = @([cc intValue]);
    return n;
}

- (NSNumber *)tempF
{
    NSString *cc = self[@"temp_F"];
    NSNumber *n = @([cc intValue]);
    return n;
}

- (NSNumber *)visibility
{
    NSString *cc = self[@"visibility"];
    NSNumber *n = @([cc intValue]);
    return n;
}

- (NSNumber *)weatherCode
{
    NSString *cc = self[@"weatherCode"];
    NSNumber *n = @([cc intValue]);
    return n;
}

-(NSString *)windDir16Point
{
    return self[@"winddir16Point"];
}

- (NSNumber *)windDirDegree
{
    NSString *cc = self[@"winddirDegree"];
    NSNumber *n = @([cc intValue]);
    return n;
}

- (NSNumber *)windSpeedKmph
{
    NSString *cc = self[@"windspeedKmph"];
    NSNumber *n = @([cc intValue]);
    return n;
}

- (NSNumber *)windSpeedMiles
{
    NSString *cc = self[@"windspeedMiles"];
    NSNumber *n = @([cc intValue]);
    return n;
}

- (NSString *)weatherDescription
{
    NSArray *ar = self[@"weatherDesc"];
    NSDictionary *dict = ar[0];
    return dict[@"value"];
}

- (NSString *)weatherIconURL
{
    NSArray *ar = self[@"weatherIconUrl"];
    NSDictionary *dict = ar[0];
    return dict[@"value"];
}

- (NSDate *)date
{
//    NSString *dateStr = self[@"date"]; // date = "2013-01-15";
    return [NSDate date];
}

- (NSNumber *)tempMaxC
{
    NSString *cc = self[@"tempMaxC"];
    NSNumber *n = @([cc intValue]);
    return n;
}

- (NSNumber *)tempMaxF
{
    NSString *cc = self[@"tempMaxF"];
    NSNumber *n = @([cc intValue]);
    return n;
}

- (NSNumber *)tempMinC
{
    NSString *cc = self[@"tempMinC"];
    NSNumber *n = @([cc intValue]);
    return n;
}

- (NSNumber *)tempMinF
{
    NSString *cc = self[@"tempMinF"];
    NSNumber *n = @([cc intValue]);
    return n;
}*/

@end