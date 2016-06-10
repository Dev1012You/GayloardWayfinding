//
//  GAHLocationPlacement.h
//  GaylordHotels
//
//  Created by John Pacheco on 10/5/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GAHAPIDataInitializer, MDCustomTransmitter, CHADestination, GAHNodeMarker, GAHDestination, GAHMapViewController;

@protocol GAHLocationPlacementDelegate <NSObject>
- (void)didShowLocation;
- (void)didShowCalloutForDestinations:(NSArray *)meetingPlayDestinations atLocation:(CGPoint)destinationCenter;
@end

#pragma mark -
@interface GAHLocationPlacement : NSObject
#pragma mark Properties
@property (nonatomic, weak) id <GAHLocationPlacementDelegate> locationPlacementDelegate;

@property (nonatomic, strong) GAHAPIDataInitializer *dataInitializer;
@property (nonatomic, strong) UIImageView *mapFloorImageView;

@property (nonatomic, strong) NSNumber *currentUserLocationFloor;

@property (nonatomic, strong) MDCustomTransmitter *activeBeacon;


#pragma mark Methods

- (instancetype)initWithMapImageView:(UIImageView *)mapImageView dataInitializer:(GAHAPIDataInitializer *)dataInitializer;

- (void)showUserLocation:(GAHNodeMarker *)userLocationMarker displayedFloor:(NSNumber *)displayedFloor view:(UIImageView *)targetView beacon:(MDCustomTransmitter *)activeBeacon;

- (void)toggleUserLocationMarkerVisbility:(GAHNodeMarker *)userLocationMarker hidden:(BOOL)hidden;

- (CHADestination *)showLocation:(GAHNodeMarker *)userLocationMarker forSlug:(NSString *)meetingPlaySlug displayedFloor:(NSNumber *)displayedFloor;

- (NSMutableDictionary *)destinationMarkers:(NSArray *)destinations withBaseLocations:(NSArray *)baseLocations;

- (void)showDestinationsOnFloor:(NSNumber *)visibleFloor destinationMarkers:(NSDictionary *)buttonCollection userLocationMarker:(GAHNodeMarker *)userLocationMarker;

- (void)hideDestinations:(NSDictionary *)buttonCollection;

- (void)removeButtonsFromSuperview:(NSDictionary *)buttonCollection;

- (void)showDestination:(NSURL *)url;

- (void)zoomDestination:(GAHDestination *)destination mapViewController:(GAHMapViewController *)mapViewController showCallout:(BOOL)showCallout;

#pragma mark - Location Calculation

- (CGPoint)locationForBeacon:(MDCustomTransmitter *)activeBeacon mapImage:(UIImage *)mapImage;

- (CGPoint)coordinatesForBeacon:(MDCustomTransmitter *)beacon;

- (CGPoint)mapAxisMultiplier:(NSNumber *)floor;

- (CGPoint)mapLocation:(CGPoint)coordinates shouldRound:(BOOL)shouldRound;

@end
