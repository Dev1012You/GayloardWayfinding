//
//  GAHBaseHeaderStyleViewController.h
//  GaylordHotels
//
//  Created by MeetingPlay on 4/27/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "GAHBaseViewController.h"
#import "GAHRootNavigationController.h"

typedef NS_ENUM(NSUInteger, GAHDataType)
{
    GAHDataTypeMapData                  = 0,
    GAHDataTypeMeetingPlayLocation      = 1,
};

@interface GAHBaseHeaderStyleViewController : GAHBaseViewController

@property (nonatomic, weak) id <GAHWayfindingLoading> directionsLoader;

@property (nonatomic, weak) IBOutlet UIView *headerContainer;
@property (weak, nonatomic) IBOutlet UIView *contentContainer;

//- (void)showMapView:(id)sender;

@end
