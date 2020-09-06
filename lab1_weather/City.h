//
//  City.h
//  lab1_weather
//  The City class will be our way to interface with the weather API.
//  The functionality here will call upon the weather API class and
//  fetch the necessary data for a specific city's weather.  This
//  object will be initialized with a city name, and helper
//  functions will be defined so that information can be easily
//  displayed in viewControllers.
//
//  Created by Clay Harper on 9/2/20.
//  Copyright © 2020 Mobile Sensing. All rights reserved.
//
//@import Foundation
#import <Foundation/Foundation.h>
#import "WeatherAPI.h"

NS_ASSUME_NONNULL_BEGIN

//@interface City : NSObject{
//    WeatherAPI *cityWeatherAPI;
//    NSString *location;
//}
@interface City : NSObject

@property (strong, nonatomic) WeatherAPI *cityWeatherAPI;
@property (strong, nonatomic) NSString *location;

-(id)initWithCityName:(NSString *)location;

// Current Weather
- (NSDictionary *) getDict; // remove this guy later.  This is just to check that the api calls work
- (void) logAllKeys; // remove later.  this is for testing

- (double) getCurrentWindSpeed;
- (double) getCurrentWindDirection;
- (double) getCurrentTemp;
- (double) getCurrentFeelsLike;
- (double) getCurrentHumidity;
- (double) getCurrentPressure;
- (NSString *) getCurrentWeather;
- (NSString *) getCurrentWeatherDesc;
- (double) getLongatude;
- (double) getLatitude;

// Forecast
- (NSDictionary *) getForecast;


@end

NS_ASSUME_NONNULL_END

