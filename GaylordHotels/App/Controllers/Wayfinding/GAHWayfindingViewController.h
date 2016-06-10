//
//  GAHWayfindingViewController.h
//  GaylordHotels
//
//  Created by MeetingPlay on 5/12/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "MTPBaseViewController.h"
#import "GAHRootNavigationController.h"

@class GAHDestination, CHADestination, GAHDirectionsViewController, GAHWayfindingMapViewController;

@interface GAHWayfindingViewController : MTPBaseViewController

@property (nonatomic, strong) GAHWayfindingMapViewController *mapViewController;
@property (nonatomic, strong) GAHDirectionsViewController *directionsViewController;

@property (nonatomic, strong) GAHAPIDataInitializer *dataInitializer;
@property (nonatomic, strong) MDBeaconManager *beaconManager;

@property (weak, nonatomic) IBOutlet UIView *statusBarBackground;
@property (weak, nonatomic) IBOutlet UIView *wayfindingMapKeyContainer;

@property (weak, nonatomic) IBOutlet UIView *mapContainer;
@property (weak, nonatomic) IBOutlet UIView *directionsContainer;

@property (weak, nonatomic) IBOutlet UIView *toggleDirectionsContainer;
@property (weak, nonatomic) IBOutlet UIButton *toggleDirectionsButton;

@property (nonatomic, assign, getter = isFirstLoad) BOOL firstLoad;

#pragma mark Wayfinding Header Items
@property (weak, nonatomic) IBOutlet UIButton *refreshButton;
@property (weak, nonatomic) IBOutlet UIButton *hideWayfindingButton;

@property (weak, nonatomic) IBOutlet UILabel *userLocationKeyIcon;
@property (weak, nonatomic) IBOutlet UILabel *userLocationKeyLabel;

@property (weak, nonatomic) IBOutlet UILabel *userDestinationKeyIcon;
@property (weak, nonatomic) IBOutlet UILabel *userDestinationKeyLabel;

#pragma mark - Wayfinding Methods
+ (instancetype)wayfindingMapView:(GAHWayfindingMapViewController *)mapView;

- (instancetype)initWithMap:(GAHWayfindingMapViewController *)mapView;

- (void)loadWayfindingWithStart:(CHADestination *)startPoint
                 andDestination:(GAHDestination *)destinationPoint
                       animated:(BOOL)animated;

- (void)loadDirections:(id)directionSet;

@end
