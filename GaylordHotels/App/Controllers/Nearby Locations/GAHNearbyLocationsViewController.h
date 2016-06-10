//
//  GAHNearbyLocationsViewController.h
//  GaylordHotels
//
//  Created by John Pacheco on 9/14/15.
//  Copyright © 2015 MeetingPlay. All rights reserved.
//

#import "GAHBaseViewController.h"

@interface GAHNearbyLocationsViewController : GAHBaseViewController

@property (nonatomic, strong) GAHMapViewController *mapViewController;;

- (void)loadDataInitializer:(GAHAPIDataInitializer *)dataInitializer;

- (GAHMapViewController *)setupMapChildView;

- (NSArray *)nearestLocationsForDestinationType:(id)destinationType;
- (void)loadLocations:(NSArray *)targetLocations;
- (NSArray *)filterLocations:(id)filterCriteria inCollection:(NSArray *)locationCollection;

@end
