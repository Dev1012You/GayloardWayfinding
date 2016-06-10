//
//  DestinationButton.h
//  GaylordHotels
//
//  Created by MeetingPlay on 5/6/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GAHDestination;

@interface DestinationButton : UIButton

+ (instancetype)buttonWithSize:(CGSize)buttonSize;

+ (instancetype)cameraButtonWithSize:(CGSize)buttonSize;

+ (instancetype)wayfindingButtonSize:(CGSize)buttonSize userLocation:(BOOL)userLocationButton;

@end

