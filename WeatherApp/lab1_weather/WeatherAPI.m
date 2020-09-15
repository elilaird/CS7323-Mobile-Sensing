//
//  WeatherAPI.m
//  lab1_weather
//
//  Created by Eli Laird on 8/31/20.
//  Copyright © 2020 Mobile Sensing. All rights reserved.
//

#import "WeatherAPI.h"

@interface WeatherAPI ()

- (NSDictionary *) requestCurrentWeatherFor:(NSString *)location;
- (NSDictionary *) requestForecastFor:(NSString *)location;

@end

@implementation WeatherAPI

//* Private Facing Functions *
- (NSDictionary *) requestCurrentWeatherFor:(NSString *)location{

    NSString *baseUrl = @"https://api.openweathermap.org/data/2.5/weather";
    NSString *appid = @"dd12273b23df1d19ad59652762894830";
    NSString *targetUrl = [NSString stringWithFormat:@"%@?q=%@&appid=%@", baseUrl, location, appid];
    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:targetUrl]];
    
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * jsonData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
   
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];

    return jsonDict;
}

- (NSDictionary *) requestForecastFor:(NSString *)location{

    NSString *baseUrl = @"https://api.openweathermap.org/data/2.5/forecast";
    NSString *appid = @"dd12273b23df1d19ad59652762894830";
    NSString *targetUrl = [NSString stringWithFormat:@"%@?q=%@&appid=%@", baseUrl, location, appid];
    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:targetUrl]];
    
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * jsonData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
    
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];

    return jsonDict;
}

//* Public Facing Methods *
- (NSDictionary *) getCurrentWeatherFor:(NSString *) location {
    return [self requestCurrentWeatherFor:location];
}

- (NSDictionary *) getForecastFor:(NSString *) location {
    return [self requestForecastFor:location];
}

@end
