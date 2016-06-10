//
//  GAHBaseNavigationController.h
//  GaylordHotels
//
//  Created by MeetingPlay on 6/24/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "MTPBaseNavigationController.h"

@class GAHRootNavigationController;

@interface GAHBaseNavigationController : MTPBaseNavigationController

@property (nonatomic, weak) GAHRootNavigationController *rootNavigationController;

@end
