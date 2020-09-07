//
//  Day.h
//  lab1_weather
//
//  Created by Clay Harper on 9/6/20.
//  Copyright © 2020 Mobile Sensing. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Day : NSObject

@property (strong, nonatomic) NSDictionary *dayDict;

- (instancetype)initWithDayDict:(NSDictionary *)dayDict;


// Current Weather
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

@end

NS_ASSUME_NONNULL_END
