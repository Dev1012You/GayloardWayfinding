//
//  MTPGimbalInitializer.h
//  MeetingPlayiBeaconStarter
//
//  Created by John Pacheco on 4/8/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MTPBeaconSightingManager, GMBLBeaconManager;

@interface MTPGimbalInitializer : NSObject
@property (nonatomic, strong) GMBLBeaconManager *gimbalBeaconManager;
@property (nonatomic, strong) MTPBeaconSightingManager *beaconSightingManager;
@end
