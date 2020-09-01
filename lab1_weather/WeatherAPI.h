//
//  WeatherAPI.h
//  lab1_weather
//
//  Created by Eli Laird on 8/31/20.
//  Copyright © 2020 Mobile Sensing. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WeatherAPI : NSObject

    - (NSString *) getDataFor:(NSString *)location;
    + (NSString *) test:(NSString *)str;

@end


NS_ASSUME_NONNULL_END
