//
//  WeatherAPI.m
//  lab1_weather
//
//  Created by Eli Laird on 8/31/20.
//  Copyright © 2020 Mobile Sensing. All rights reserved.
//

#import "WeatherAPI.h"

@interface WeatherAPI ()

- (NSString *) getDataFor:(NSString *)location;

@end

@implementation WeatherAPI

//* Private Facing Functions *

- (NSDictionary *) getDataFor:(NSString *)location{
//    __block NSString *jsonData = nil;
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
//    [request setHTTPMethod:@"GET"];
//
//    NSString *baseUrl = @"https://api.openweathermap.org/data/2.5/weather";
//    NSString *appid = @"dd12273b23df1d19ad59652762894830";
//    NSString *targetUrl = [NSString stringWithFormat:@"%@?q=%@&appid=%@", baseUrl, location, appid];
//
//    NSLog(@"%@", targetUrl);
//
//    [request setURL:[NSURL URLWithString:targetUrl]];
//
//    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:
//      ^(NSData * _Nullable data,
//        NSURLResponse * _Nullable response,
//        NSError * _Nullable error) {
//
//          jsonData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//          NSLog(@"Data received: %@", jsonData);
//    }] resume];
    
//    new code
    
    NSString *baseUrl = @"https://api.openweathermap.org/data/2.5/weather";
    NSString *appid = @"dd12273b23df1d19ad59652762894830";
    NSString *targetUrl = [NSString stringWithFormat:@"%@?q=%@&appid=%@", baseUrl, location, appid];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:targetUrl]];

    __block NSDictionary *jsonData = nil;
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               jsonData = [NSJSONSerialization JSONObjectWithData:data
                                                                      options:0
                                                                        error:nil];
                               NSLog(@"Async JSON: %@", jsonData);
                           }];
    
    
    
    return jsonData;
}

//* Public Facing Methods *
- (NSString *) getWeatherFor:(NSString *)location{
    return [self getDataFor:location];
}

@end
