//
//  Manager.h
//  Sample-SimpleWeather
//
//  Created by Ronaldo GomesJr on 3/12/2015.
//  Copyright © 2015 it.technophile. All rights reserved.
//
@import Foundation;
@import CoreLocation;

#import <ReactiveCocoa/ReactiveCocoa.h>

// 1
#import "Condition.h"

@interface Manager : NSObject <CLLocationManagerDelegate>

// 2
+ (instancetype)sharedManager;

// 3
@property (nonatomic, strong, readonly) CLLocation *currentLocation;
@property (nonatomic, strong, readonly) Condition *currentCondition;
@property (nonatomic, strong, readonly) NSArray *hourlyForecast;
@property (nonatomic, strong, readonly) NSArray *dailyForecast;

// 4
- (void)findCurrentLocation;

@end