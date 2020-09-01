//
//  WeatherAPI.m
//  lab1_weather
//
//  Created by Eli Laird on 8/31/20.
//  Copyright © 2020 Mobile Sensing. All rights reserved.
//

#import "WeatherAPI.h"

@interface WeatherAPI ()

//@property (strong, nonatomic) NSString* url;
//@property (strong, nonatomic) NSString* apiString;

- (NSString *) getDataFrom:(NSString *)targetUrl;


@end

@implementation WeatherAPI

//@synthesize url = _url;
//@synthesize apiString = _apiString;

//-(void)url:(NSString *)url {
//    if(!_url)
//        _url = @"https://api.openweathermap.org/data/2.5/weather";
//}
//
//-(NSString *)apiString{
//    if(!_apiString)
//        _apiString = @"dd12273b23df1d19ad59652762894830";
//    return _apiString;
//}

//taken from here: https://stackoverflow.com/questions/9404104/simple-objective-c-get-request
- (NSString *) getDataFrom:(NSString *)targetUrl{
    __block NSString *myString = nil;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    [request setURL:[NSURL URLWithString:targetUrl]];

    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:
      ^(NSData * _Nullable data,
        NSURLResponse * _Nullable response,
        NSError * _Nullable error) {

          myString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
          NSLog(@"Data received: %@", myString);
    }] resume];
    
    return myString;
}

- (NSString *) getDataFor:(NSString *)location{
    __block NSString *jsonData = nil;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    
    NSString *baseUrl = @"https://api.openweathermap.org/data/2.5/weather";
    NSString *appid = @"dd12273b23df1d19ad59652762894830";
    NSString *targetUrl = [NSString stringWithFormat:@"%@?q=%@&appid=%@", baseUrl, location, appid];
    
    NSLog(targetUrl);
    
    [request setURL:[NSURL URLWithString:targetUrl]];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:
      ^(NSData * _Nullable data,
        NSURLResponse * _Nullable response,
        NSError * _Nullable error) {

          jsonData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
          NSLog(@"Data received: %@", jsonData);
    }] resume];
    

    
    return jsonData;
}

+ (NSString *) test:(NSString *)str {
    return @"test";
}

@end
