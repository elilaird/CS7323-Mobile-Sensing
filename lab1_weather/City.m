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
        _cityWeatherAPI = [[WeatherAPI alloc] init];
        _currentWeatherDict = [self getCurrentWeatherDict];
        _forecastDict = [self getForecastDict];
        _isMetric = isMetric;
        
        _currentDayOfWeekInt = [self getCurrentDayOfWeek];
        _currentDay = [[Day alloc] initWithDayDict:self.currentWeatherDict andMetric:self.isMetric andWeeday:[self getCurrentDayOfWeekString:self.currentDayOfWeekInt]];
        _forecast = [self getForecast];

    }
    return self;
}

- (instancetype)init {
//    self = [self initWithCityName:@"" andMetric:FALSE];
    return self;
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
        case 7:
            return @"Saturday";
        default:
            return @"Unable to get date information";
    }
}

- (NSDictionary *) getCurrentWeatherDict{
    return [self.cityWeatherAPI getCurrentWeatherFor:self.location];
}

- (NSDictionary *) getForecastDict{
    return [self.cityWeatherAPI getForecastFor:self.location];
}

- (NSString *) getLocation{
    return _location;
}

- (NSMutableArray *) getForecast{
    NSArray *forecastDayList = [self.forecastDict objectForKey:@"list"];
    NSMutableArray *forecastDays = [[NSMutableArray alloc] init];
    
    for (int i=0; i < forecastDayList.count; i++){
        [forecastDays addObject:[[Day alloc] initWithDayDict:forecastDayList[i] andMetric:self.isMetric andWeeday:[self getCurrentDayOfWeekString:self.currentDayOfWeekInt + i + 1]]];
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
