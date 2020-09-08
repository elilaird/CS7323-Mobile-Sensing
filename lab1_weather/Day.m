//
//  Day.m
//  lab1_weather
//
//  Created by Clay Harper on 9/6/20.
//  Copyright © 2020 Mobile Sensing. All rights reserved.
//

#import "Day.h"

@implementation Day


- (instancetype)initWithDayDict:(NSDictionary *)dayDict{
    self = [super init];
    if(self) {
        _dayDict = dayDict;
    }
    return self;
}

/*
 Current Weather Calls
 */

- (double) getCurrentWindSpeed{
    /*
     Returns the current wind speed in mph
     */
    NSDictionary *wind = [self.dayDict objectForKey:@"wind"];
    double speedMS = [[wind objectForKey:@"speed"] doubleValue];
    return speedMS * 2.237;
}

- (double) getCurrentWindDirection{
    /*
     Returns the current wind direction in degrees
     */
    NSDictionary *wind = [self.dayDict objectForKey:@"wind"];
    return [[wind objectForKey:@"deg"] doubleValue];
}

- (double) getCurrentTemp{
    /*
     Returns the current temperature for a city in Fahrenheit
     */
    NSDictionary *main = [self.dayDict objectForKey:@"main"];
    double tempKelvin = [[main objectForKey:@"temp"] doubleValue];
    return ((tempKelvin - 273.15) * (9.0/5.0)) + 32.0;
}

- (double) getCurrentFeelsLike{
    /*
     Returns the current feels like temperature for a city in Fahrenheit
     */
    NSDictionary *main = [self.dayDict objectForKey:@"main"];
    double tempKelvin = [[main objectForKey:@"feels_like"] doubleValue];
    return ((tempKelvin - 273.15) * (9.0/5.0)) + 32.0;
}

- (double) getCurrentHumidity{
    /*
     Returns the current humidity (%) in a city
     */
    NSDictionary *main = [self.dayDict objectForKey:@"main"];
    return [[main objectForKey:@"humidity"] doubleValue];
}

- (double) getCurrentPressure{
    /*
     Returns the current atmospheric pressure (hPa)
     */
    NSDictionary *main = [self.dayDict objectForKey:@"main"];
    return [[main objectForKey:@"pressure"] doubleValue];
}

- (NSString *) getCurrentWeather{
    /*
     Returns the city's weather condition (e.g. Clouds)
     */
    NSDictionary *weather = [[self.dayDict objectForKey:@"weather"] objectAtIndex:0];
    return [weather objectForKey:@"main"];
}

- (NSString *) getCurrentWeatherDesc{
    /*
     Returns the city's weather condition description (e.g. broken clouds)
     */
    NSDictionary *weather = [[self.dayDict objectForKey:@"weather"] objectAtIndex:0];
    return [weather objectForKey:@"description"];
}

- (double) getLongatude{
    /*
     Returns the city's longatude
     */
    NSDictionary *coord = [self.dayDict objectForKey:@"coord"];
    return [[coord objectForKey:@"lon"] doubleValue];
}

- (double) getLatitude{
    /*
     Returns the city's latitude
     */
    NSDictionary *coord = [self.dayDict objectForKey:@"coord"];
    return [[coord objectForKey:@"lat"] doubleValue];
}


@end
