//
//  NSMutableURLRequest+HelperMethods.h
//  GaylordHotels
//
//  Created by John Pacheco on 8/1/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "CHADestination.h"

@class GAHMapDataSource;

@interface CHADestination (HelperMethods)

+ (CHADestination *)wayfindingBasePointForMeetingPlaySlug:(NSString *)locationSlug wayfindingLocations:(NSArray *)wayfindingLocations;

+ (NSArray *)identifiersForWayfindingLocations:(NSArray *)wayfindingBaseLocations;

+ (NSIndexSet *)indexesOfWayfindingBasePointsForMeetingPlaySlug:(NSString *)locationSlug
                                      wayfindingDataIdentifiers:(NSArray *)wayfindingIdentifiers;

+ (CHADestination *)wayfindingBasePointForPoint:(CGPoint)nodeLocation
                                pointCollection:(NSArray *)destinations;

+ (CHADestination *)wayfindingBasePointForPoint:(CGPoint)nodeLocation
                                        onFloor:(NSNumber *)nodeFloor
                                pointCollection:(NSArray *)destinations;

+ (CHADestination *)findNearestDestinationBeaconLocation:(CGPoint)beaconLocation
                                             targetFloor:(NSNumber *)targetFloor
                                           mapDataSource:(GAHMapDataSource *)mapDataSource;

+ (CHADestination *)nearestDestinationToPoint:(CGPoint)point
                                      onFloor:(NSNumber *)targetFloor
                              mapDestinations:(NSArray *)mapDestinations;

+ (NSArray *)nearestDestinationsToPoint:(CGPoint)point
                                onFloor:(NSNumber *)targetFloor
                        mapDestinations:(NSArray *)mapDestinations;

+ (CGPoint)mapAxisMultiplierForFloor:(NSNumber *)floorNumber mapDataSource:(GAHMapDataSource *)mapDataSource;

@end
