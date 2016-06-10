//
//  GAHRootNavigationController.h
//  GaylordHotels
//
//  Created by MeetingPlay on 4/28/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "MTPCustomRootNavigationViewController.h"
#import "GAHMapDataSource.h"

@class GAHDestination, CHADestination, GAHWayfindingViewController, GAHAPIDataInitializer, GAHMapViewController;

@protocol GAHWayfindingLoading <NSObject>

- (void)loadWayfindingStart:(CHADestination *)startPoint
                destination:(GAHDestination *)destinationPoint;

@end

@interface GAHRootNavigationController : MTPCustomRootNavigationViewController <GAHWayfindingLoading, MTPMainMenuToggling>

/**
 GAHMapDataSource that contains data returned from the WayfindingPRO API: <br /> - NSArray of CHADestinations <br /> - NSArray of CHAMapImage data
 */
@property (nonatomic, strong) GAHMapDataSource *mapDataSource;
/**
 An NSArray of GAHDestinations based on the data returned from the MeetingPlay API
 */
@property (nonatomic, strong) NSArray *destinations;
/**
 An NSArray of GAHPropertyCategories based on the data returned from the MeetingPlay API
 */
@property (nonatomic, strong) NSArray *propertyCategories;

//@property (nonatomic, strong) GAHWayfindingViewController *persistentWayfindingSession;

@property (nonatomic, strong) GAHAPIDataInitializer *apiInitializer;

//@property (nonatomic, strong) GAHMapViewController *sharedMapViewController;

- (GAHMapViewController *)sharedMapViewController;

- (void)openMapLocationFromURL:(NSURL *)url;

@end
