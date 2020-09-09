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
@property (nonatomic, assign) BOOL isMetric;

- (instancetype)initWithDayDict:(NSDictionary *)dayDict andMetric:(BOOL) isMetric andWeeday:(NSString *) dayOfWeek;

// Get day information
- (NSString *) getTheDayOfWeek;

// Weather info
- (double) getWindSpeed;
- (double) getWindDirection;
- (double) getTemp;
- (double) getHighTemp;
- (double) getLowTemp;
- (double) getFeelsLike;
- (double) getHumidity;
- (double) getPressure;
- (NSString *) getWeather;
- (NSString *) getWeatherDesc;
- (double) getLongatude;
- (double) getLatitude;

@end

NS_ASSUME_NONNULL_END
