//
//  Client.m
//  Sample-SimpleWeather
//
//  Created by Ronaldo GomesJr on 3/12/2015.
//  Copyright © 2015 it.technophile. All rights reserved.
//

#import "Client.h"
#import "Condition.h"
#import "DailyForecast.h"

@interface Client ()

@property (nonatomic, strong) NSURLSession *session;

@end

@implementation Client

- (instancetype)init {
    if (self = [super init]) {
//        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sharedSession];
    }
    return self;
}

- (RACSignal *)fetchJSONFromURL:(NSURL *)url {
    NSLog(@"Fetching: %@", url.absoluteString);
    
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        NSURLSessionDataTask *dataTask = [self.session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            if (! error) {
                NSError *jsonError = nil;
                
                id json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
                
                if (! jsonError) {
                    [subscriber sendNext:json];
                } else {
                    [subscriber sendError:jsonError];
                }
                
            } else {
                [subscriber sendError:error];
            }
            
            [subscriber sendCompleted];
            
        }];
        
        [dataTask resume];
        
        return [RACDisposable disposableWithBlock:^{
            [dataTask cancel];
        }];
        
    }] doError:^(NSError *error) {
        NSLog(@"%@", error);
    }];
    
}

- (RACSignal *)fetchCurrentConditionsForLocation:(CLLocationCoordinate2D)coordinate {
    
    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%F&lon=%f&units=imperial&APPID=d752130f6fb0e75ca1497f59354ca065", coordinate.latitude, coordinate.longitude];
    NSURL *url = [NSURL URLWithString:urlString];
    
    return [[self fetchJSONFromURL:url] map:^(NSDictionary *json) {
        
        return [MTLJSONAdapter modelOfClass:[Condition class] fromJSONDictionary:json error:nil];
        
    }];
    
}

- (RACSignal *)fetchHourlyForecastForLocation:(CLLocationCoordinate2D)coordinate {
    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast?lat=%f&lon=%f&units=imperial&cnt=12&APPID=d752130f6fb0e75ca1497f59354ca065",coordinate.latitude, coordinate.longitude];
    NSURL *url = [NSURL URLWithString:urlString];
    
    // 1
    return [[self fetchJSONFromURL:url] map:^(NSDictionary *json) {
        // 2
        RACSequence *list = [json[@"list"] rac_sequence];
        
        // 3
        return [[list map:^(NSDictionary *item) {
            // 4
            return [MTLJSONAdapter modelOfClass:[Condition class] fromJSONDictionary:item error:nil];
            // 5
        }] array];
    }];
}

- (RACSignal *)fetchDailyForecastForLocation:(CLLocationCoordinate2D)coordinate {
    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast/daily?lat=%f&lon=%f&units=imperial&cnt=7&APPID=d752130f6fb0e75ca1497f59354ca065",coordinate.latitude, coordinate.longitude];
    NSURL *url = [NSURL URLWithString:urlString];
    
    // Use the generic fetch method and map results to convert into an array of Mantle objects
    return [[self fetchJSONFromURL:url] map:^(NSDictionary *json) {
        // Build a sequence from the list of raw JSON
        RACSequence *list = [json[@"list"] rac_sequence];
        
        // Use a function to map results from JSON to Mantle objects
        return [[list map:^(NSDictionary *item) {
            return [MTLJSONAdapter modelOfClass:[DailyForecast class] fromJSONDictionary:item error:nil];
        }] array];
    }];
}

@end
