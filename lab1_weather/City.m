//
//  City.m
//  lab1_weather
//
//  Created by Clay Harper on 9/2/20.
//  Copyright © 2020 Mobile Sensing. All rights reserved.
//

#import "City.h"

@implementation City

- (instancetype)initWithCityName:(NSString *)location{
    self = [super init];
    if(self) {
        _location = location;
        _cityWeatherAPI = [[WeatherAPI alloc] init];
    }
    return self;
}

- (instancetype)init {
    self = [self initWithCityName:@""];
    return self;
}

//* Private Facing Functions *


//* Public Facing Methods *
- (NSDictionary *) getCurrentWeatherDict{
    return [_cityWeatherAPI getCurrentWeatherFor:_location];
}

- (NSDictionary *) getForecastDict{
    return [_cityWeatherAPI getForecastFor:_location];
}


@end
