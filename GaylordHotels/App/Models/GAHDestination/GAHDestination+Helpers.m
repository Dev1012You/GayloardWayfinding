//
//  GAHDestination+Helpers.m
//  GaylordHotels
//
//  Created by John Pacheco on 8/1/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "GAHDestination+Helpers.h"
#import "CHADestination.h"

@implementation GAHDestination (Helpers)

+ (NSArray *)destinationsForBaseLocation:(NSString *)wayfindingSlug meetingPlayLocations:(NSArray *)meetingPlayLocations
{
    NSMutableArray *meetingplayDestinations = [NSMutableArray new];
    
    for (GAHDestination *destination in meetingPlayLocations)
    {
        if ([destination.wfpName caseInsensitiveCompare:wayfindingSlug] == NSOrderedSame)
        {
            [meetingplayDestinations addObject:destination];
        }
    }
    return [NSArray arrayWithArray:meetingplayDestinations];
}

+ (NSArray *)destinations:(NSArray *)meetingPlayDestinations forMatchingMapDestinations:(NSArray *)wayfindingMapDestinations
{
    __block NSMutableSet *wayfindingProIdentifiers = [NSMutableSet new];
    for (CHADestination *wfpDestination in wayfindingMapDestinations)
    {
        [wayfindingProIdentifiers addObject:wfpDestination.destinationName.lowercaseString];
    }
    
    NSMutableArray *meetingPlayMatches = [NSMutableArray new];
    for (GAHDestination *mpDestination in meetingPlayDestinations)
    {
        if ([wayfindingProIdentifiers member:mpDestination.wfpName.lowercaseString])
        {
            [meetingPlayMatches addObject:mpDestination];
        }
    }
    
    return meetingPlayMatches;
}

@end
