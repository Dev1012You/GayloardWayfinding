//
//  MDCustomTransmitter+NetworkingHelper.m
//  GaylordHotels
//
//  Created by John Pacheco on 7/16/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "MDCustomTransmitter+NetworkingHelper.h"
#import "NSString+MTPAPIAddresses.h"
#import "NSMutableURLRequest+MTPCategory.h"
#import "NSURLSession+MTPCategory.h"

@implementation MDCustomTransmitter (NetworkingHelper)

+ (void)fetchLocationForBeacon:(NSString *)beaconIdentifier
             completionHandler:(void(^)(NSString *locationSlug))completionHandler
{
    if (beaconIdentifier.length > 0)
    {
        NSMutableURLRequest *locationForBeacon =
        [NSMutableURLRequest defaultRequestMethod:@"GET"
                                              URL:[NSString stringWithFormat:[NSString locationForBeacon],beaconIdentifier]
                                       parameters:nil];
        [[[NSURLSession sharedSession] dataTaskWithRequest:locationForBeacon completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
        {
            if (error)
            {
                NSLog(@"\nlocation fetch error %@", error);
            }
            else
            {
                id responseData = [NSURLSession serializeJSONData:data response:response error:error];
                if (responseData)
                {
                    NSArray *matchingLocations = [[responseData objectForKey:@"data"] objectForKey:@"locations"];
                    NSDictionary *firstLocation = [matchingLocations firstObject];
                    if (firstLocation)
                    {
                        NSString *locationSlug = [firstLocation objectForKey:@"slug"];
                        if (completionHandler)
                        {
                            completionHandler(locationSlug);
                        }
                    }
                }
            }
        }] resume];
    }
}

@end
