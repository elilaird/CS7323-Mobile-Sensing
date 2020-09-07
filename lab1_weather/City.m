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
- (NSMutableArray *) getForecast;

@end

@implementation City


- (instancetype)initWithCityName:(NSString *)location{
    self = [super init];
    if(self) {
        _location = location;
        _cityWeatherAPI = [[WeatherAPI alloc] init];
        _currentWeatherDict = [self getCurrentWeatherDict];
        _forecastDict = [self getForecastDict];
        
        
        _currentDay = [[Day alloc] initWithDayDict:self.currentWeatherDict];
        _forecast = [self getForecast];
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

- (NSMutableArray *) getForecast{
    NSArray *forecastDayList = [self.forecastDict objectForKey:@"list"];
    NSMutableArray *forecastDays = [[NSMutableArray alloc] init];
    
    for (int i=0; i < forecastDayList.count; i++){
        [forecastDays addObject:[[Day alloc] initWithDayDict:forecastDayList[i]]];
    }
    
    return forecastDays;
}


//* Public Facing Methods *

- (void) logAllKeys{
    NSLog(@"Keys for forecast: %@", [self.forecastDict allKeys]);
    NSLog(@"Keys for current weather: %@", [self.currentWeatherDict allKeys]);
}
- (NSDictionary *) getDict{
    return self.forecastDict;
}

- (void) logList{
    id list = [self.forecastDict objectForKey:@"list"];
    NSLog(@"List type: %@",  NSStringFromClass([list class]));
    
    id days = list[0];
    NSLog(@"Days type: %@",  NSStringFromClass([days class]));
}



@end
