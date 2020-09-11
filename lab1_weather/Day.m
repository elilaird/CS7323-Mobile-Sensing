//
//  Day.m
//  lab1_weather
//
//  Created by Clay Harper on 9/6/20.
//  Copyright © 2020 Mobile Sensing. All rights reserved.
//

#import "Day.h"

@interface Day()
@property (strong, nonatomic) NSString *dayOfWeek;

@end

@implementation Day


- (instancetype)initWithDayDict:(NSDictionary *)dayDict andMetric:(BOOL) isMetric andWeeday:(NSString *) dayOfWeek{
    self = [super init];
    if(self) {
        _dayDict = dayDict;
        _isMetric = isMetric;
        _dayOfWeek = dayOfWeek;
    }
    return self;
}

/*
 Day information calls
 */
- (NSString *) getTheDayOfWeek{
    return self.dayOfWeek;
}


/*
 Weather Calls
 */

- (double) getWindSpeed{
    /*
     Returns the current wind speed in mph
     */
    
    @try {
        NSDictionary *wind = [self.dayDict objectForKey:@"wind"];
        double speedMS = [[wind objectForKey:@"speed"] doubleValue];
        
        if(self.isMetric)
            return speedMS;
        return speedMS * 2.237;
    } @catch (NSException *exception) {
        return -999.0;
    }
}

- (double) getWindDirection{
    /*
     Returns the current wind direction in degrees
     */
    
    @try {
        NSDictionary *wind = [self.dayDict objectForKey:@"wind"];
        return [[wind objectForKey:@"deg"] doubleValue];
    } @catch (NSException *exception) {
        return -999.0;
    }
}

- (double) getTemp{
    /*
     Returns the current temperature for a city in Fahrenheit
     */
    
    @try {
        NSDictionary *main = [self.dayDict objectForKey:@"main"];
        double tempKelvin = [[main objectForKey:@"temp"] doubleValue];
        if(self.isMetric)
            return tempKelvin - 273.15;
        return ((tempKelvin - 273.15) * (9.0/5.0)) + 32.0;
    } @catch (NSException *exception) {
        return -999.0;
    }
}

- (double) getHighTemp{
    /*
     Returns the high temperature for a city on a day in Fahrenheit
     */
    
    @try {
        NSDictionary *main = [self.dayDict objectForKey:@"main"];
        double tempKelvin = [[main objectForKey:@"temp_max"] doubleValue];
        if(self.isMetric)
            return tempKelvin - 273.15;
        return ((tempKelvin - 273.15) * (9.0/5.0)) + 32.0;
    } @catch (NSException *exception) {
        return -999.0;
    }
}

- (double) getLowTemp{
    /*
     Returns the low temperature for a city on a day in Fahrenheit
     */
    
    @try {
        NSDictionary *main = [self.dayDict objectForKey:@"main"];
        double tempKelvin = [[main objectForKey:@"temp_min"] doubleValue];
        if(self.isMetric)
            return tempKelvin - 273.15;
        return ((tempKelvin - 273.15) * (9.0/5.0)) + 32.0;
    } @catch (NSException *exception) {
        return -999.0;
    }
}

- (double) getFeelsLike{
    /*
     Returns the current feels like temperature for a city in Fahrenheit
     */
    
    @try {
        NSDictionary *main = [self.dayDict objectForKey:@"main"];
        double tempKelvin = [[main objectForKey:@"feels_like"] doubleValue];
        if(self.isMetric)
            return tempKelvin - 273.15;
        return ((tempKelvin - 273.15) * (9.0/5.0)) + 32.0;
    } @catch (NSException *exception) {
        return -999.0;
    }
}

- (double) getHumidity{
    /*
     Returns the current humidity (%) in a city
     */
    
    @try {
        NSDictionary *main = [self.dayDict objectForKey:@"main"];
        return [[main objectForKey:@"humidity"] doubleValue];
    } @catch (NSException *exception) {
        return -999.0;
    }
}

- (double) getPressure{
    /*
     Returns the current atmospheric pressure (hPa)
     */
    
    @try {
        NSDictionary *main = [self.dayDict objectForKey:@"main"];
        return [[main objectForKey:@"pressure"] doubleValue];
    } @catch (NSException *exception) {
        return -999.0;
    }
}

- (NSString *) getWeather{
    /*
     Returns the city's weather condition (e.g. Clouds)
     */
    
    @try {
        NSDictionary *weather = [[self.dayDict objectForKey:@"weather"] objectAtIndex:0];
        return [weather objectForKey:@"main"];
    } @catch (NSException *exception) {
        return @"";
    }
}

- (NSString *) getWeatherDesc{
    /*
     Returns the city's weather condition description (e.g. broken clouds)
     */
    
    @try {
        NSDictionary *weather = [[self.dayDict objectForKey:@"weather"] objectAtIndex:0];
        return [weather objectForKey:@"description"];
    } @catch (NSException *exception) {
        return @"";
    }
}

- (double) getLongatude{
    /*
     Returns the city's longatude
     */
    
    @try {
        NSDictionary *coord = [self.dayDict objectForKey:@"coord"];
        return [[coord objectForKey:@"lon"] doubleValue];
    } @catch (NSException *exception) {
        return -999.0;
    }
}

- (double) getLatitude{
    /*
     Returns the city's latitude
     */
    
    @try {
        NSDictionary *coord = [self.dayDict objectForKey:@"coord"];
        return [[coord objectForKey:@"lat"] doubleValue];
    } @catch (NSException *exception) {
        return -999.0;
    }
}


@end
