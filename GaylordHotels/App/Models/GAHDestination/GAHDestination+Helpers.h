//
//  GAHDestination+Helpers.h
//  GaylordHotels
//
//  Created by John Pacheco on 8/1/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "GAHDestination.h"

@interface GAHDestination (Helpers)

+ (NSArray *)destinationsForBaseLocation:(NSString *)wayfindingSlug meetingPlayLocations:(NSArray *)meetingPlayLocations;

+ (NSArray *)destinations:(NSArray *)meetingPlayDestinations forMatchingMapDestinations:(NSArray *)wayfindingMapDestinations;

@end
