//
//  MDCustomTransmitter+NetworkingHelper.h
//  GaylordHotels
//
//  Created by John Pacheco on 7/16/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "MDCustomTransmitter.h"

@interface MDCustomTransmitter (NetworkingHelper)

+ (void)fetchLocationForBeacon:(NSString *)beaconIdentifier
             completionHandler:(void(^)(NSString *locationSlug))completionHandler;
@end
