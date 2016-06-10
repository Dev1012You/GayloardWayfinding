//
//  GAHDetailHeaderViewController.h
//  GaylordHotels
//
//  Created by MeetingPlay on 5/7/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "MTPBaseViewController.h"
#import "GAHDataSource.h"
#import "GAHMapViewController.h"

@interface GAHDetailHeaderViewController : MTPBaseViewController

@property (nonatomic, weak) GAHRootNavigationController *rootNavigationController;
@property (nonatomic, strong) NSTimer *imageCycle;
@property (weak, nonatomic) IBOutlet UIImageView *headerImage;

@property (nonatomic, weak) id <GAHMapViewDelegate> mapViewDelegate;

- (void)configureWithDataSource:(id)locationItem;

- (void)updateHeaderImage:(GAHDestination *)destination;
- (void)startImageCycle;
- (void)cancelTimer;
@end
