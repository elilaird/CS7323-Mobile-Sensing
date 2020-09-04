//
//  City.m
//  lab1_weather
//
//  Created by Clay Harper on 9/2/20.
//  Copyright © 2020 Mobile Sensing. All rights reserved.
//

#import "City.h"

@interface City()
@property (strong, nonatomic) NSDictionary *currentWeatherDict;
@property (strong, nonatomic) NSDictionary *forecastDict;
- (NSDictionary *) getCurrentWeatherDict;
- (NSDictionary *) getForecastDict;

@end

@implementation City


- (instancetype)initWithCityName:(NSString *)location{
    self = [super init];
    if(self) {
        _location = location;
        _cityWeatherAPI = [[WeatherAPI alloc] init];
        _currentWeatherDict = [self getCurrentWeatherDict];
        _forecastDict = [self getForecastDict];
    }
    return self;
}

- (instancetype)init {
    self = [self initWithCityName:@""];
    return self;
}

//* Private Facing Functions *
- (NSDictionary *) getCurrentWeatherDict{
    return [self.cityWeatherAPI getCurrentWeatherFor:self.location];
}

- (NSDictionary *) getForecastDict{
    return [self.cityWeatherAPI getForecastFor:self.location];
}


//* Public Facing Methods *

- (void) logAllKeys{
    NSLog(@"Keys for forecast: %@", [self.forecastDict allKeys]);
    NSLog(@"Keys for current weather: %@", [self.currentWeatherDict allKeys]);
}
- (NSDictionary *) getDict{
    return self.forecastDict;
}


/*
 Current Weather Calls
 */

- (double) getCurrentWindSpeed{
    /*
     Returns the current wind speed in mph
     */
    NSDictionary *wind = [self.currentWeatherDict objectForKey:@"wind"];
    double speedMS = [[wind objectForKey:@"speed"] doubleValue];
    return speedMS * 2.237;
}

- (double) getCurrentWindDirection{
    /*
     Returns the current wind direction in degrees
     */
    NSDictionary *wind = [self.currentWeatherDict objectForKey:@"wind"];
    return [[wind objectForKey:@"deg"] doubleValue];
}

- (double) getCurrentTemp{
    /*
     Returns the current temperature for a city in Fahrenheit
     */
    NSDictionary *main = [self.currentWeatherDict objectForKey:@"main"];
    double tempKelvin = [[main objectForKey:@"temp"] doubleValue];
    return ((tempKelvin - 273.15) * (9.0/5.0)) + 32.0;
}

- (double) getCurrentFeelsLike{
    /*
     Returns the current feels like temperature for a city in Fahrenheit
     */
    NSDictionary *main = [self.currentWeatherDict objectForKey:@"main"];
    double tempKelvin = [[main objectForKey:@"feels_like"] doubleValue];
    return ((tempKelvin - 273.15) * (9.0/5.0)) + 32.0;
}

- (double) getCurrentHumidity{
    /*
     Returns the current humidity (%) in a city
     */
    NSDictionary *main = [self.currentWeatherDict objectForKey:@"main"];
    return [[main objectForKey:@"humidity"] doubleValue];
}

- (double) getCurrentPressure{
    /*
     Returns the current atmospheric pressure (hPa)
     */
    NSDictionary *main = [self.currentWeatherDict objectForKey:@"main"];
    return [[main objectForKey:@"pressure"] doubleValue];
}

- (NSString *) getCurrentWeather{
    /*
     Returns the city's weather condition (e.g. Clouds)
     */
    NSDictionary *weather = [[self.currentWeatherDict objectForKey:@"weather"] objectAtIndex:0];
    return [weather objectForKey:@"main"];
}

- (NSString *) getCurrentWeatherDesc{
    /*
     Returns the city's weather condition (e.g. Clouds)
     */
    NSDictionary *weather = [[self.currentWeatherDict objectForKey:@"weather"] objectAtIndex:0];
    return [weather objectForKey:@"description"];
}

- (double) getLongatude{
    /*
     Returns the city's longatude
     */
    NSDictionary *coord = [self.currentWeatherDict objectForKey:@"coord"];
    return [[coord objectForKey:@"lon"] doubleValue];
}

- (double) getLatitude{
    /*
     Returns the city's latitude
     */
    NSDictionary *coord = [self.currentWeatherDict objectForKey:@"coord"];
    return [[coord objectForKey:@"lat"] doubleValue];
}


/*
 Forecast Weather calls
 */

- (NSDictionary *) getForecast{
    /*
     Returns the city's weather condition (e.g. Clouds)
     */
    return self.forecastDict;
}



@end
