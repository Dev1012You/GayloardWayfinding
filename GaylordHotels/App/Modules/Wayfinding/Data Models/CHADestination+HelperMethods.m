//
//  NSMutableURLRequest+HelperMethods.m
//  GaylordHotels
//
//  Created by John Pacheco on 8/1/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "CHADestination+HelperMethods.h"
#import "GAHMapDataSource.h"
#import "CHAMapImage.h"

#import "SDWebImageManager.h"
#import "SDImageCache.h"

@implementation CHADestination (HelperMethods)

+ (CHADestination *)wayfindingBasePointForMeetingPlaySlug:(NSString *)locationSlug wayfindingLocations:(NSArray *)wayfindingLocations
{
    CHADestination *basePoint = nil;
    
    NSArray *destinationIdentifiers = [self identifiersForWayfindingLocations:wayfindingLocations];
    NSIndexSet *pointIndex = [self indexesOfWayfindingBasePointsForMeetingPlaySlug:locationSlug
                                                         wayfindingDataIdentifiers:destinationIdentifiers];
    if (pointIndex.count > 0)
    {
        basePoint = [wayfindingLocations objectAtIndex:[pointIndex firstIndex]];
    }
    return basePoint;
}

+ (NSArray *)identifiersForWayfindingLocations:(NSArray *)wayfindingBaseLocations
{
    NSMutableArray *wayfindingDataIdentifiers = [NSMutableArray new];
    for (id wayfindingBaseLocation in wayfindingBaseLocations)
    {
        if ([wayfindingBaseLocation isKindOfClass:[CHADestination class]])
        {
            NSString *locationName = [(CHADestination *)wayfindingBaseLocation destinationName];
            if (locationName.length == 0)
            {
                locationName = @"unknown";
            }
            [wayfindingDataIdentifiers addObject:locationName];
        }
        else
        {
            NSLog(@"\ninvalid base location type %@", wayfindingBaseLocation);
        }
    }
    
    return [NSArray arrayWithArray:wayfindingDataIdentifiers];
}

+ (NSIndexSet *)indexesOfWayfindingBasePointsForMeetingPlaySlug:(NSString *)locationSlug
                                      wayfindingDataIdentifiers:(NSArray *)wayfindingIdentifiers
{
    NSIndexSet *matchingWayfindingLocations =
    [wayfindingIdentifiers indexesOfObjectsPassingTest:
     ^BOOL(id obj, NSUInteger idx, BOOL *stop)
     {
         if ([obj isKindOfClass:[NSString class]])
         {
             NSComparisonResult comparisonResult = [obj compare:locationSlug
                                                        options:NSCaseInsensitiveSearch];
             
             return (comparisonResult == NSOrderedSame) ? true : false;
         }
         else
         {
             return false;
         }
     }];
    
    return matchingWayfindingLocations;
}

+ (CHADestination *)wayfindingBasePointForPoint:(CGPoint)nodeLocation
                                pointCollection:(NSArray *)destinations
{
    __block CHADestination *matchingDestination = nil;
    
    [destinations enumerateObjectsUsingBlock:^(id baseLocation, NSUInteger idx, BOOL *stop)
     {
         if ([baseLocation isKindOfClass:[CHADestination class]])
         {
             CGPoint baseLocationPoint = CGPointMake(rint([baseLocation xCoordinate].floatValue),
                                                     rint([baseLocation yCoordinate].floatValue));
             if (CGPointEqualToPoint(nodeLocation, baseLocationPoint))
             {
                 matchingDestination = (CHADestination *)baseLocation;
                 *stop = true;
             }
         }
     }];
    
    return matchingDestination;
}

+ (CHADestination *)wayfindingBasePointForPoint:(CGPoint)nodeLocation
                                        onFloor:(NSNumber *)nodeFloor
                                pointCollection:(NSArray *)destinations
{
    __block CHADestination *matchingDestination = nil;
    
    [destinations enumerateObjectsUsingBlock:^(id baseLocation, NSUInteger idx, BOOL *stop)
     {
         if ([baseLocation isKindOfClass:[CHADestination class]])
         {
             if (nodeFloor.integerValue == [baseLocation floorNumber].integerValue)
             {
                 CGPoint baseLocationPoint = CGPointMake(rint([baseLocation xCoordinate].floatValue),
                                                         rint([baseLocation yCoordinate].floatValue));
                 if (CGPointEqualToPoint(nodeLocation, baseLocationPoint))
                 {
                     matchingDestination = (CHADestination *)baseLocation;
                     *stop = true;
                 }
                 
             }
         }
     }];
    
    return matchingDestination;
}

+ (CHADestination *)findNearestDestinationBeaconLocation:(CGPoint)beaconLocation
                                             targetFloor:(NSNumber *)targetFloor
                                           mapDataSource:(GAHMapDataSource *)mapDataSource
{
    CGPoint mapAxisMultiplier = [self mapAxisMultiplierForFloor:targetFloor mapDataSource:mapDataSource];
    
    CGPoint beaconCoordinates = CGPointMake((beaconLocation.x * mapAxisMultiplier.x) + 30,
                                            (beaconLocation.y * mapAxisMultiplier.y) + 35);
    
    CHADestination *closestNavigablePoint = [self nearestDestinationToPoint:beaconCoordinates
                                                                    onFloor:targetFloor
                                                            mapDestinations:mapDataSource.mapDestinations];
    
    return closestNavigablePoint;
}



+ (CHADestination *)nearestDestinationToPoint:(CGPoint)point
                                      onFloor:(NSNumber *)targetFloor
                              mapDestinations:(NSArray *)mapDestinations;
{
    __block CHADestination *closestNavigablePoint = nil;
    __block float smallestDistanceBetweenPoints = MAXFLOAT;
    
    // get the closest navigable WFP destination
    [mapDestinations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         CHADestination *wfpDestination = obj;
         if (targetFloor.integerValue == wfpDestination.floorNumber.integerValue)
         {
             CGPoint wfpLocation = CGPointMake(wfpDestination.xCoordinate.floatValue, wfpDestination.yCoordinate.floatValue);
             CGFloat distance = [self distanceBetweenPoint:point andPoint:wfpLocation];
             if (distance < smallestDistanceBetweenPoints)
             {
                 smallestDistanceBetweenPoints = distance;
                 closestNavigablePoint = wfpDestination;
             }
         }
     }];
    /*
    NSArray *destinationsForTargetFloor = [mapDestinations filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.floorNumber == %@",targetFloor]];
    NSArray *closestDestinations = [destinationsForTargetFloor sortedArrayUsingComparator:^NSComparisonResult(CHADestination * obj1, CHADestination * obj2) {
        
        CGFloat distance1 = [self distanceBetweenPoint:point andPoint:CGPointMake(obj1.xCoordinate.floatValue, obj1.yCoordinate.floatValue)];
        CGFloat distance2 = [self distanceBetweenPoint:point andPoint:CGPointMake(obj2.xCoordinate.floatValue, obj2.yCoordinate.floatValue)];
        
        return distance1 == distance2 ? NSOrderedSame : ((distance1 > distance2) ? NSOrderedDescending : NSOrderedAscending);
    }];
    */
    return closestNavigablePoint;
}

+ (NSArray *)nearestDestinationsToPoint:(CGPoint)point
                                onFloor:(NSNumber *)targetFloor
                        mapDestinations:(NSArray *)mapDestinations;
{
    NSArray *locationsByDistance = [mapDestinations filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.floorNumber = %@",targetFloor]];
    
    NSArray *sortedDestinations = [locationsByDistance sortedArrayUsingComparator:^NSComparisonResult(CHADestination * obj1, CHADestination * obj2) {
        
        CGPoint firstLocation = CGPointMake(obj1.xCoordinate.floatValue, obj1.yCoordinate.floatValue);
        CGFloat firstDistance = [self distanceBetweenPoint:point andPoint:firstLocation];
        
        CGPoint secondLocation = CGPointMake(obj2.xCoordinate.floatValue, obj2.yCoordinate.floatValue);
        CGFloat secondDistance = [self distanceBetweenPoint:point andPoint:secondLocation];
        
        if (firstDistance > secondDistance)
        {
            return NSOrderedDescending;
        }
        else if (firstDistance < secondDistance)
        {
            return NSOrderedAscending;
        }
        else
        {
            return NSOrderedSame;
        }
    }];
    
    return sortedDestinations;
}

+ (CGFloat)distanceBetweenPoint:(CGPoint)firstPoint andPoint:(CGPoint)secondPoint
{
    CGFloat dx = (firstPoint.x - secondPoint.x);
    CGFloat dy = (firstPoint.y - secondPoint.y);
    
    CGFloat dist = sqrt(dx*dx + dy*dy);
    
    return dist;
}

+ (CGPoint)mapAxisMultiplierForFloor:(NSNumber *)floorNumber mapDataSource:(GAHMapDataSource *)mapDataSource
{
    __block CGPoint mapAxisMultiplier = CGPointMake(1, 1);
    
    [mapDataSource.mapImageData enumerateObjectsUsingBlock:^(CHAMapImage *mapData, NSUInteger idx, BOOL *stop) {
        
        if (floorNumber)
        {
            if ([mapData.floorNumber isEqualToNumber:floorNumber])
            {
                UIImage *imageForFloor = [[[SDWebImageManager sharedManager] imageCache] imageFromDiskCacheForKey:[mapData fullMapImageURL].absoluteString];
                if (imageForFloor)
                {
                    CGSize mapImageSize = imageForFloor.size;
                    CGFloat plottingImageHeight = (500 * mapImageSize.height)/mapImageSize.width;
                    
                    mapAxisMultiplier = CGPointMake(mapImageSize.width/500.f,
                                                    mapImageSize.height/MAX(1,plottingImageHeight));
                }
                
                *stop = true;
            }
        }
    }];
    
    if (mapAxisMultiplier.x == NAN || mapAxisMultiplier.y == NAN)
    {
        mapAxisMultiplier = CGPointMake(1, 1);
    }
    
    return mapAxisMultiplier;
}


















@end
