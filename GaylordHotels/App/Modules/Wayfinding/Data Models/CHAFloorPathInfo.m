//
//  CHAFloorPathInfo.m
//  GaylordHotels
//
//  Created by MeetingPlay on 4/30/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "CHAFloorPathInfo.h"
#import "CHAMapLocation.h"

@implementation CHAFloorPathInfo

+ (instancetype)floorPathWithFloor:(NSNumber *)floorNumber
                         pathNodes:(NSArray *)pathNodes
{
    return [[CHAFloorPathInfo alloc] initWithFloorNumber:floorNumber
                                               pathNodes:pathNodes];
}

- (instancetype)initWithFloorNumber:(NSNumber *)floor
                          pathNodes:(NSArray *)pathNodes
{
    if (self = [super init])
    {
        _floorNumber = floor;
        _pathNodes = pathNodes;
    }
    
    return self;
}

+ (NSArray *)pathNodesFromData:(NSArray *)pathInfo
{
    NSArray *mapLocations = [CHAMapLocation mapLocationsFromSource:pathInfo];
    return mapLocations;
}

+ (NSNumber *)extractFloorNumber:(NSArray *)pathInfo
{
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];

    __block NSNumber *floorNumber;

    [pathInfo enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (![obj isKindOfClass:[NSDictionary class]]) return;
        
        [obj enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
         {
             if ([key isKindOfClass:[NSString class]]
                 && [key isEqualToString:@"FloorNumber"])
             {

                 floorNumber = [numberFormatter numberFromString:obj];
                 *stop = true;
             }
         }];
    }];
    
    return floorNumber;
}

@end
