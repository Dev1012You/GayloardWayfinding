//
//  GAHLocationSearchViewController.h
//  GaylordHotels
//
//  Created by MeetingPlay on 7/3/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "GAHLandingViewController.h"

@interface GAHLocationSearchViewController : GAHLandingViewController
@property (nonatomic, strong) NSArray *matchingLocations;
- (NSArray *)filterDestinations:(NSArray *)destinations criteria:(NSString *)criteria;

@end
