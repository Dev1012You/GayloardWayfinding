//
//  GAHNearbyLocationsViewController.m
//  GaylordHotels
//
//  Created by John Pacheco on 9/14/15.
//  Copyright © 2015 MeetingPlay. All rights reserved.
//

#import "GAHNearbyLocationsViewController.h"
#import "GAHMapViewController.h"
#import "GAHLocationDetailsViewController.h"

#import "GAHDestination+Helpers.h"
#import "CHADestination+HelperMethods.h"

#import "MDCustomTransmitter.h"

#import "UIView+AutoLayoutHelper.h"
#import "GAHStoryboardIdentifiers.h"

@interface GAHNearbyLocationsViewController () <GAHMapViewDelegate>
@end

@implementation GAHNearbyLocationsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view
    
    self.mapViewController = [self setupMapChildView];
    
    self.mapViewController.floorSelectorContainer.hidden = false;
    [self.mapViewController setupFloorSelectorConstraints];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (GAHMapViewController *)setupMapChildView
{
    GAHMapViewController *mapView = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:GAHMapViewControllerIdentifier];
    mapView.view.translatesAutoresizingMaskIntoConstraints = false;
    [self.detailContainer addSubview:mapView.view];
    [mapView.view.superview addConstraints:[mapView.view pinToSuperviewBounds]];
    [self addChildViewController:mapView];
    
    mapView.dataInitializer = self.dataInitializer;
    mapView.mapViewDelegate = self;
    
    [mapView loadMap:true];
    
    return mapView;
}

- (void)loadDataInitializer:(GAHAPIDataInitializer *)dataInitializer
{
    self.dataInitializer = dataInitializer;
    self.mapViewController.dataInitializer = dataInitializer;
}

- (void)loadLocations:(NSArray *)targetLocations
{
    SIAlertView *noLocationsFound;
    
    if (targetLocations.count == 0)
    {
        noLocationsFound = [[SIAlertView alloc] initWithTitle:@"No Locations Found" andMessage:@"Sorry, but we couldn't find any locations near you on this floor."];
        [noLocationsFound addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeDefault handler:nil];
    }
    
    MDCustomTransmitter *activeBeacon = self.rootNavigationController.beaconSightingManager.beaconManager.activeBeacon;
    
    NSNumber *beaconFloor = [self floorForBeacon:activeBeacon];
    
    CHAMapImage *mapImageForLocation = [GAHMapDataSource detailsForFloor:beaconFloor
                                                            mapImageData:self.mapViewController.dataInitializer.mapDataSource.mapImageData];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.mapViewController plotDestinationPoints:targetLocations
                                    withBaseLocations:self.dataInitializer.mapDataSource.mapDestinations];
        
        [self.mapViewController showFloorForMapImage:mapImageForLocation];
        [self.mapViewController zoomToPoint:[self locationForBeacon:activeBeacon floorNumber:beaconFloor] zoomScale:0.25f];
        
        [noLocationsFound show];
    });
}

- (NSArray *)nearestLocationsForDestinationType:(id)destinationType
{
    MDCustomTransmitter *activeBeacon = self.rootNavigationController.beaconSightingManager.beaconManager.activeBeacon;
    NSNumber *beaconFloor = [self floorForBeacon:activeBeacon];
    CGPoint activeBeaconLocation = [self locationForBeacon:activeBeacon floorNumber:beaconFloor];
    
    NSArray *activeBeaconNearbyLocations = [CHADestination nearestDestinationsToPoint:activeBeaconLocation
                                                                              onFloor:beaconFloor
                                                                      mapDestinations:self.dataInitializer.mapDataSource.mapDestinations];
    
    NSArray *meetingPlayDestinations = [NSArray arrayWithArray:self.dataInitializer.meetingPlayLocations];
    
    __block NSMutableArray *matchingDestinations = [NSMutableArray new];
    [activeBeaconNearbyLocations enumerateObjectsUsingBlock:^(CHADestination * obj, NSUInteger idx, BOOL *stop) {
        
        [meetingPlayDestinations enumerateObjectsUsingBlock:^(GAHDestination *mpDestination, NSUInteger idx, BOOL *stop) {
            
            if ([mpDestination.wfpName caseInsensitiveCompare:obj.destinationName] == NSOrderedSame)
            {
                [matchingDestinations addObject:mpDestination];
                *stop = true;
            }
        }];
    }];
    
    NSArray *locations = [self filterLocations:destinationType inCollection:matchingDestinations];
    
    return locations;
}

#pragma mark - Protocol Conformance

- (void)mapView:(GAHMapViewController *)mapView didSelectDetails:(GAHDestination *)selectedDestination;
{
    [self loadDestinationDetails:selectedDestination];
}

- (void)loadDestinationDetails:(GAHDestination *)destination
{
    GAHLocationDetailsViewController *explore = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:GAHExploreDetailViewControllerIdentifier];
    
    explore.rootNavigationController = self.rootNavigationController;
    explore.dataInitializer = self.dataInitializer;
    explore.directionsLoader = self.rootNavigationController;
    
    explore.locationData = destination;
    
    [self.navigationController pushViewController:explore animated:true];
}

#pragma mark - Location Identification Methods

- (CGPoint)locationForBeacon:(MDCustomTransmitter *)targetBeacon floorNumber:(NSNumber *)floorNumber
{
    CGPoint mapAxisMultipler = [CHADestination mapAxisMultiplierForFloor:floorNumber
                                                           mapDataSource:self.dataInitializer.mapDataSource];
    
    CGPoint beaconLocation = CGPointZero;

    GAHDestination *meetingPlayLocation;
    CHADestination *wfpDestination;
    
    if (targetBeacon.placed)
    {
        beaconLocation = CGPointMake(targetBeacon.placementX.floatValue * mapAxisMultipler.x,
                                     targetBeacon.placementY.floatValue * mapAxisMultipler.y);
        
    }
    else
    {
        meetingPlayLocation = [[GAHDestination destinationsForBaseLocation:targetBeacon.meetingPlaySlug
                                                      meetingPlayLocations:self.dataInitializer.meetingPlayLocations] firstObject];
        
        wfpDestination = [CHADestination wayfindingBasePointForMeetingPlaySlug:meetingPlayLocation.wfpName
                                                           wayfindingLocations:self.dataInitializer.mapDataSource.mapDestinations];
        
        beaconLocation = [wfpDestination mapLocation:true];
    }
    
    return beaconLocation;
}

- (NSNumber *)floorForBeacon:(MDCustomTransmitter *)targetBeacon
{
    NSString *userCurrentMap = [self.dataInitializer mapSlugForMapID:targetBeacon.fkMapID];
    if (userCurrentMap.length > 0)
    {
        userCurrentMap = [userCurrentMap stringByReplacingOccurrencesOfString:@"-gyn" withString:@""];
    }
    NSNumber *userFloor = [self.dataInitializer floorForMapName:userCurrentMap];
    
    return userFloor;
}

- (NSArray *)filterLocations:(id)filterCriteria inCollection:(NSArray *)locationCollection
{
    NSArray *matchingLocations;
    
    if ([filterCriteria isKindOfClass:[NSString class]])
    {
        if ([filterCriteria caseInsensitiveCompare:@"meeting space"] == NSOrderedSame)
        {
            NSPredicate *locationFilter = [NSPredicate predicateWithFormat:@"self.category contains[cd] %@",filterCriteria];
            matchingLocations = [locationCollection filteredArrayUsingPredicate:locationFilter];
        }
        else if ([filterCriteria caseInsensitiveCompare:@"atm"] == NSOrderedSame)
        {
            NSPredicate *locationFilter = [NSPredicate predicateWithFormat:@"self.location contains[cd] %@",filterCriteria];
            matchingLocations = [locationCollection filteredArrayUsingPredicate:locationFilter];
        }
        else
        {
            NSPredicate *locationFilter = [NSPredicate predicateWithFormat:@"self.category contains[cd] %@",filterCriteria];
            matchingLocations = [locationCollection filteredArrayUsingPredicate:locationFilter];
        }
    }
    
    return matchingLocations;
}

@end
