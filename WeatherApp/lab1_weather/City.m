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
@property (nonatomic, assign) NSInteger currentDayOfWeekInt;

- (NSDictionary *) getCurrentWeatherDict;
- (NSDictionary *) getForecastDict;
- (NSMutableArray *) getForecast;
- (NSInteger) getCurrentDayOfWeek;
- (NSString *) getCurrentDayOfWeekString: (NSInteger)dayInt;

@end

@implementation City

- (instancetype)initWithCityName:(NSString *)location andMetric:(BOOL) isMetric{
    self = [super init];
    if(self) {
        _location = location;
        _isMetric = isMetric;
    }
    return self;
}

- (instancetype)init {
    return self;
}

/*
 Lazy instantiation
 */

- (Day *) currentDay{
    if(!_currentDay)
        _currentDay = [[Day alloc] initWithDayDict:self.currentWeatherDict andMetric:self.isMetric andWeeday:[self getCurrentDayOfWeekString:self.currentDayOfWeekInt]];
    
    return _currentDay;
}

- (WeatherAPI *) cityWeatherAPI{
    if(!_cityWeatherAPI)
        _cityWeatherAPI = [[WeatherAPI alloc] init];
    
    return _cityWeatherAPI;
}

- (NSDictionary *) currentWeatherDict{
    if(!_currentWeatherDict)
        _currentWeatherDict = [self getCurrentWeatherDict];
    
    return _currentWeatherDict;
}

- (NSDictionary *) forecastDict{
    if(!_forecastDict)
        _forecastDict = [self getForecastDict];
    
    return _forecastDict;
}

- (NSInteger) currentDayOfWeekInt{
    if(!_currentDayOfWeekInt)
        _currentDayOfWeekInt = [self getCurrentDayOfWeek];

    return _currentDayOfWeekInt;
}

- (NSMutableArray *) forecast{
    if(!_forecast)
        _forecast = [self getForecast];
        
    return _forecast;
}





//* Private Facing Functions *
- (NSInteger) getCurrentDayOfWeek{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    //Get the day number
    return [calendar component:NSCalendarUnitWeekday fromDate:[NSDate date]];
}

- (NSString *) getCurrentDayOfWeekString: (NSInteger)dayInt{
    NSInteger modDay = dayInt%7;
    
    switch (modDay) {
        case 1:
            return @"Sunday";
        case 2:
            return @"Monday";
        case 3:
            return @"Tuesday";
        case 4:
            return @"Wednesday";
        case 5:
            return @"Thursday";
        case 6:
            return @"Friday";
        case 0:
            return @"Saturday";
        default:
            return @"Unable to get date information";
    }
}

- (NSDictionary *) getCurrentWeatherDict{
    @try {
        return [self.cityWeatherAPI getCurrentWeatherFor:self.location];
    } @catch (NSException *exception) {
        return @{};
    }
}

- (NSDictionary *) getForecastDict{
    @try {
        return [self.cityWeatherAPI getForecastFor:self.location];
    } @catch (NSException *exception) {
        return @{};
    } 
}

- (NSString *) getLocation{
    return _location;
}

- (NSMutableArray *) getForecast{
    @try {
        NSArray *forecastDayList = [self.forecastDict objectForKey:@"list"];
        NSMutableArray *forecastDays = [[NSMutableArray alloc] init];
        
        for (int i=0; i < forecastDayList.count; i++){
            [forecastDays addObject:[[Day alloc] initWithDayDict:forecastDayList[i] andMetric:self.isMetric andWeeday:[self getCurrentDayOfWeekString:self.currentDayOfWeekInt + i + 1]]];
        }
        
        return forecastDays;
    } @catch (NSException *exception) {
        return [[NSMutableArray alloc] init];
    }

}



@end
