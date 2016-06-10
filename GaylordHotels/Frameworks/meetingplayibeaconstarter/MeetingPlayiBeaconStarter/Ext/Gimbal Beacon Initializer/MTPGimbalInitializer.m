//
//  MTPGimbalInitializer.m
//  MeetingPlayiBeaconStarter
//
//  Created by John Pacheco on 4/8/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "MTPGimbalInitializer.h"
#import <Gimbal/Gimbal.h> 
#import "MTPBeaconSightingManager.h"

@implementation MTPGimbalInitializer

- (instancetype)init
{
    self = [super init];
    if (self) {
        _gimbalBeaconManager = [[GMBLBeaconManager alloc] init];
        _beaconSightingManager = [MTPBeaconSightingManager sightingManager:_gimbalBeaconManager];
        _gimbalBeaconManager.delegate = _beaconSightingManager;
    }
    return self;
}


@end
