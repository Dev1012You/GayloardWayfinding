//
//  GAHLocationPlacement.m
//  GaylordHotels
//
//  Created by John Pacheco on 10/5/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "GAHLocationPlacement.h"
#import "GAHMapViewController.h"

#import "GAHAPIDataInitializer.h"
#import "GAHMapDataSource.h"
#import "CHAMapImage.h"
#import "CHADestination+HelperMethods.h"
#import "GAHDestination+Helpers.h"

#import "DestinationButton.h"
#import "GAHNodeMarker.h"

#import "MDCustomTransmitter+NetworkingHelper.h"
#import "MDBeaconManager.h"
#import "SDWebImageManager.h"
#import "SDImageCache.h"

#import <Gimbal/GMBLApplicationStatus.h>

@implementation GAHLocationPlacement

- (instancetype)initWithMapImageView:(UIImageView *)mapImageView dataInitializer:(GAHAPIDataInitializer *)dataInitializer
{
    self = [super init];
    if (self)
    {
        _mapFloorImageView = mapImageView;
        _dataInitializer = dataInitializer;
    }
    return self;
}

- (void)showUserLocation:(GAHNodeMarker *)userLocationMarker displayedFloor:(NSNumber *)displayedFloor view:(UIImageView *)targetView beacon:(MDCustomTransmitter *)activeBeacon
{
    if (self.dataInitializer.isFetching)
    {
        [userLocationMarker removeFromSuperview];
        return;
    }
    
    if ([GMBLApplicationStatus bluetoothStatus] != GMBLBluetoothStatusOK)
    {
        [userLocationMarker removeFromSuperview];
        return;
    }
    else
    {
        if (userLocationMarker.superview == nil)
        {
            [self.mapFloorImageView addSubview:userLocationMarker];
        }
    }
    
    self.activeBeacon = activeBeacon ? activeBeacon : self.dataInitializer.beaconManager.activeBeacon;
    
    if (self.activeBeacon)
    {
        [userLocationMarker.superview bringSubviewToFront:userLocationMarker];
        
        if (activeBeacon.placed)
        {
            self.currentUserLocationFloor = [GAHMapDataSource floorForMapID:activeBeacon.fkMapID];
            if ([self.currentUserLocationFloor isEqual:displayedFloor])
            {
                CGPoint beaconLocation = [self locationForBeacon:activeBeacon mapImage:targetView.image];
                
                if (isnan(beaconLocation.x) || isnan(beaconLocation.y))
                {
                    [self toggleUserLocationMarkerVisbility:userLocationMarker hidden:true];
                    return;
                }
                
                userLocationMarker.center = [self mapLocation:beaconLocation shouldRound:true];
            }
            else
            {
                // not the same floor
            }
            
            __weak __typeof(&*self)weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [weakSelf toggleUserLocationMarkerVisbility:userLocationMarker
                                                     hidden:![weakSelf.currentUserLocationFloor isEqualToNumber:displayedFloor]];
            });
        }
        else
        {
            if (activeBeacon.meetingPlaySlug.length > 0)
            {
                self.currentUserLocationFloor = [self showLocation:userLocationMarker forSlug:activeBeacon.meetingPlaySlug displayedFloor:displayedFloor].floorNumber;
            }
            else
            {
                __weak __typeof(&*self)weakSelf = self;
                [MDCustomTransmitter fetchLocationForBeacon:activeBeacon.identifier
                                          completionHandler:^(NSString *locationSlug)
                 {
                     weakSelf.activeBeacon.meetingPlaySlug = locationSlug;
                     weakSelf.currentUserLocationFloor = [weakSelf showLocation:userLocationMarker forSlug:locationSlug displayedFloor:displayedFloor].floorNumber;
                 }];
            }
        }
    }
}

- (CHADestination *)showLocation:(GAHNodeMarker *)userLocationMarker forSlug:(NSString *)meetingPlaySlug displayedFloor:(NSNumber *)displayedFloor
{
    // get location for beacon
    CHADestination *userLocation = [CHADestination wayfindingBasePointForMeetingPlaySlug:meetingPlaySlug
                                                                     wayfindingLocations:self.dataInitializer.mapDataSource.mapDestinations];
    userLocationMarker.center = [userLocation mapLocation:true];

    [self toggleUserLocationMarkerVisbility:userLocationMarker hidden:![userLocation.floorNumber isEqualToNumber:displayedFloor]];
    
    return userLocation;
}

- (void)toggleUserLocationMarkerVisbility:(GAHNodeMarker *)userLocationMarker hidden:(BOOL)hidden
{
    userLocationMarker.hidden = hidden;
}

- (NSMutableDictionary *)destinationMarkers:(NSArray *)destinations
                          withBaseLocations:(NSArray *)baseLocations
{
    NSMutableDictionary *buttonCollection = [NSMutableDictionary new];
    
    NSArray *wayfindingLocationIdentifiers = [CHADestination identifiersForWayfindingLocations:baseLocations];
    
    CGFloat scaledButtonSize = 25.f;
    
    UIFont *defaultFont = [UIFont fontWithName:@"FontAwesome" size:21.f];
    for (GAHDestination *destination in destinations)
    {
        NSIndexSet *matchingLocations =
        [CHADestination indexesOfWayfindingBasePointsForMeetingPlaySlug:destination.wfpName
                                              wayfindingDataIdentifiers:wayfindingLocationIdentifiers];
        
        if (matchingLocations.count > 0)
        {
            CHADestination *wayfindingBaseLocation = [baseLocations objectAtIndex:[matchingLocations firstIndex]];
            if (wayfindingBaseLocation)
            {
                CGPoint destinationCenter = CGPointMake(wayfindingBaseLocation.xCoordinate.floatValue,
                                                        wayfindingBaseLocation.yCoordinate.floatValue);
                
                DestinationButton *destinationPoint = [DestinationButton buttonWithSize:CGSizeMake(scaledButtonSize, scaledButtonSize)];
                [destinationPoint.titleLabel setFont:defaultFont];
                
                destinationPoint.center = destinationCenter;
                
                [destinationPoint addTarget:self action:@selector(retrieveLocationsForPoint:) forControlEvents:UIControlEventTouchUpInside];
                
                [self.mapFloorImageView addSubview:destinationPoint];
                
                NSMutableArray *buttonsForFloorNumber = [NSMutableArray arrayWithArray:[buttonCollection objectForKey:wayfindingBaseLocation.floorNumber]];
                if (!buttonsForFloorNumber)
                {
                    buttonsForFloorNumber = [NSMutableArray new];
                }
                [buttonsForFloorNumber addObject:destinationPoint];
                [buttonCollection setObject:buttonsForFloorNumber forKey:wayfindingBaseLocation.floorNumber];
            }
        }
    }
    
    return buttonCollection;
}

- (void)retrieveLocationsForPoint:(id)sender
{
    if ([sender isKindOfClass:[DestinationButton class]])
    {
        CGPoint destinationCenter = CGPointMake(rint([sender center].x),
                                                rint([sender center].y));
        
        __block CHADestination *baseLocation;
        
        [self.dataInitializer.mapDataSource.mapDestinations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
         {
             if ([obj isKindOfClass:[CHADestination class]])
             {
                 CGPoint baseLocationCenter = CGPointMake(rint([(CHADestination *)obj xCoordinate].floatValue),
                                                          rint([(CHADestination *)obj yCoordinate].floatValue));
                 if (CGPointEqualToPoint(destinationCenter, baseLocationCenter))
                 {
                     baseLocation = (CHADestination *)obj;
                     *stop = true;
                 }
             }
         }];
        
        if (baseLocation)
        {
            NSArray *meetingPlayDestinations = [GAHDestination destinationsForBaseLocation:baseLocation.destinationName meetingPlayLocations:self.dataInitializer.meetingPlayLocations];
            
            if (self.locationPlacementDelegate && [self.locationPlacementDelegate respondsToSelector:@selector(didShowCalloutForDestinations:atLocation:)])
            {
                [self.locationPlacementDelegate didShowCalloutForDestinations:meetingPlayDestinations atLocation:destinationCenter];
            }
        }
    }
}

- (void)showDestinationsOnFloor:(NSNumber *)visibleFloor destinationMarkers:(NSDictionary *)buttonCollection userLocationMarker:(GAHNodeMarker *)userLocationMarker
{
    [buttonCollection enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         if (![obj isKindOfClass:[NSArray class]])
         {
             return;
         }
         
         for (DestinationButton *button in obj)
         {
             button.hidden = ![key isEqualToNumber:visibleFloor];
         }
     }];
}

- (void)hideDestinations:(NSDictionary *)buttonCollection
{
    [buttonCollection enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         if (![obj isKindOfClass:[NSArray class]])
         {
             return;
         }
         
         for (DestinationButton *button in obj)
         {
             button.hidden = true;
         }
     }];
}

- (void)removeButtonsFromSuperview:(NSDictionary *)buttonCollection
{
    [buttonCollection enumerateKeysAndObjectsUsingBlock:^(id key, id buttons, BOOL *stop)
     {
         if ([buttons isKindOfClass:[NSArray class]])
         {
             [buttons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
              {
                  [obj removeFromSuperview];
              }];
         }
     }];
}

- (void)zoomDestination:(GAHDestination *)destination mapViewController:(GAHMapViewController *)mapViewController showCallout:(BOOL)showCallout
{
    CHADestination *wayfindingProDestination = [CHADestination wayfindingBasePointForMeetingPlaySlug:destination.slug.lowercaseString
                                                                                 wayfindingLocations:self.dataInitializer.mapDataSource.mapDestinations];
    
    __weak __typeof(&*self)weakSelf = self;
    [mapViewController loadMapZoomToDestination:destination
                                                 zoomScale:0.8
                                                  animated:YES
                                         completionHandler:^
     {
         if (showCallout)
         {
             if (weakSelf.locationPlacementDelegate && [weakSelf.locationPlacementDelegate respondsToSelector:@selector(didShowCalloutForDestinations:atLocation:)])
             {
                 [weakSelf.locationPlacementDelegate didShowCalloutForDestinations:@[destination]
                                                                        atLocation:[wayfindingProDestination mapLocation:true]];
             }
             else
             {
                 DLog(@"delegate check failed");
             }
         }
         else
         {
             DLog(@"\nshow callout was false");
         }
     }];
}

#pragma mark - Location Calculation
- (CGPoint)locationForBeacon:(MDCustomTransmitter *)activeBeacon mapImage:(UIImage *)mapImage
{
    CGPoint beaconLocation = CGPointMake(activeBeacon.placementX.floatValue, activeBeacon.placementY.floatValue);
    
    CGSize mapImageSize = mapImage.size;
    CGFloat plottingImageHeight = 1;
    
    if (mapImageSize.width > 0 && mapImageSize.height > 0)
    {
        plottingImageHeight = (500 * mapImageSize.height)/mapImageSize.width;
    }
    else
    {
        plottingImageHeight = 1;
    }
    
    CGPoint mapAxisMultiplier = CGPointMake(mapImageSize.width/500.f, mapImageSize.height/plottingImageHeight);

    beaconLocation = CGPointMake((activeBeacon.placementX.floatValue * mapAxisMultiplier.x) + 30,
                                 (activeBeacon.placementY.floatValue * mapAxisMultiplier.y) + 35);

    return beaconLocation;
}

- (CGPoint)coordinatesForBeacon:(MDCustomTransmitter *)beacon
{
    CGPoint beaconLocation = CGPointMake(beacon.placementX.floatValue, beacon.placementY.floatValue);
    
    NSNumber *floor = [GAHMapDataSource floorForMapID:beacon.fkMapID];
    self.currentUserLocationFloor = floor;
    
    CGPoint mapAxisMultiplier = [self mapAxisMultiplier:floor];
    beaconLocation = CGPointMake(beacon.placementX.floatValue * mapAxisMultiplier.x,
                                 beacon.placementY.floatValue * mapAxisMultiplier.y);
    
    return beaconLocation;
}

- (CGPoint)mapAxisMultiplier:(NSNumber *)floor
{
    CGPoint mapAxisMultiplier = [CHADestination mapAxisMultiplierForFloor:floor
                                                            mapDataSource:self.dataInitializer.mapDataSource];

    return mapAxisMultiplier;
}

- (CGPoint)mapLocation:(CGPoint)coordinates shouldRound:(BOOL)shouldRound
{
    CGFloat xCoordinate = shouldRound ? rint(coordinates.x) : coordinates.x;
    CGFloat yCoordinate = shouldRound ? rint(coordinates.y) : coordinates.y;
    CGPoint baseLocationPoint = CGPointMake(xCoordinate,yCoordinate);
    return baseLocationPoint;
}

@end
