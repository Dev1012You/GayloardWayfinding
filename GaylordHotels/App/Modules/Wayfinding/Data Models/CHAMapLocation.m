//
//  CHAMapLocation.m
//  GaylordHotels
//
//  Created by MeetingPlay on 4/30/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "CHAMapLocation.h"
#import <CoreGraphics/CGGeometry.h>

@implementation CHAMapLocation


+ (instancetype)mapLocation:(NSString *)rawLocation
                xCoordinate:(NSNumber *)xCoordinate
                yCoordinate:(NSNumber *)yCoordinate
                floorNumber:(NSNumber *)floor
{
    return [[CHAMapLocation alloc] initWithLocation:rawLocation
                                        xCoordinate:xCoordinate
                                        yCoordinate:yCoordinate
                                        floorNumber:floor];
}

- (instancetype)initWithLocation:(NSString *)rawLocation
                     xCoordinate:(NSNumber *)xCoordinate
                     yCoordinate:(NSNumber *)yCoordinate
                     floorNumber:(NSNumber *)floor
{
    NSParameterAssert(xCoordinate);
    NSParameterAssert(yCoordinate);
    NSParameterAssert(floor);
    
    if (self = [super init])
    {
        _rawLocation = rawLocation;
        _floorNumber = floor;
        _floorLocation = CGPointMake(xCoordinate.floatValue,yCoordinate.floatValue);
    }
    return self;
}

+ (NSDictionary *)extractLocationInformationFromString:(NSString *)locationString
{
    /*
     API returns a string like so, {983,356,1} which is x, y, and floor
     */
    
    NSScanner *scanner = [NSScanner scannerWithString:locationString];
    scanner.charactersToBeSkipped = [NSCharacterSet characterSetWithCharactersInString:@"{;}"];
    
    NSMutableArray *foundNumbers = [NSMutableArray new];
    
    while ([scanner isAtEnd] == false)
    {
        NSInteger foundInteger;
        if ([scanner scanInteger:&foundInteger])
        {
            [foundNumbers addObject:@(foundInteger)];
        }
    }

    if (foundNumbers.count == 3)
    {
        NSNumber *xCoordinate = [foundNumbers objectAtIndex:0];
        NSNumber *yCoordinate = [foundNumbers objectAtIndex:1];
        
        NSNumber *floor = [foundNumbers lastObject];
        
        return @{@"x": xCoordinate,
                 @"y": yCoordinate,
                 @"floor": floor };
    }
    else
    {
        return nil;
    }
}

// class convenience method to create a collection
+ (NSArray *)mapLocationsFromSource:(NSArray *)locationsDataSource
{
    NSMutableArray *newMapPoints = [NSMutableArray new];
    
    for (NSDictionary *mapPointDictionary in locationsDataSource)
    {
        if (![mapPointDictionary isKindOfClass:[NSDictionary class]])
        {
            return nil;
        }
        
        [mapPointDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
         {
             if ([key isEqualToString:@"string"]
                 && [obj isKindOfClass:[NSString class]])
             {
                 NSDictionary *mapData = [CHAMapLocation extractLocationInformationFromString:obj];
                 NSNumber *xCoordinate = [mapData objectForKey:@"x"];
                 NSNumber *yCoordinate = [mapData objectForKey:@"y"];
                 NSNumber *floor = [mapData objectForKey:@"floor"];
                 
                 if (xCoordinate && yCoordinate && floor)
                 {
                     CHAMapLocation *mapLocation = [CHAMapLocation mapLocation:obj
                                                                   xCoordinate:xCoordinate
                                                                   yCoordinate:yCoordinate
                                                                   floorNumber:floor];
                     if (mapLocation)
                     {
                         [newMapPoints addObject:mapLocation];
                     }
                 }
                 
             }
         }];
    }
    
    return newMapPoints;
}

@end

