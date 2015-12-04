//
//  DailyForecast.m
//  Sample-SimpleWeather
//
//  Created by Ronaldo GomesJr on 3/12/2015.
//  Copyright © 2015 it.technophile. All rights reserved.
//

#import "DailyForecast.h"

@implementation DailyForecast

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    // 1
    NSMutableDictionary *paths = [[super JSONKeyPathsByPropertyKey] mutableCopy];
    // 2
    paths[@"tempHigh"] = @"temp.max";
    paths[@"tempLow"] = @"temp.min";
    // 3
    return paths;
}

@end
