//
//  MTPBeaconSightingManager.h
//  MeetingPlayiBeaconStarter
//
//  Created by John Pacheco on 4/3/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Gimbal/GMBLBeaconManager.h>

@class MDBeaconManager, MDAlertManager;

@interface MTPBeaconSightingManager : NSObject <GMBLBeaconManagerDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) NSManagedObjectContext *rootObjectContext;
@property (strong, nonatomic) NSTimer *beaconUpdateTimer;
 
@property (nonatomic, strong) GMBLBeaconManager *beaconService;
@property (strong, nonatomic) MDBeaconManager *beaconManager;

@property (strong, nonatomic) NSArray *lastUpdatedBeacons;
@property (strong, nonatomic) NSString *lastStrongestID;

@property (strong, nonatomic) NSTimer *apiCallTimer;

@property (assign, nonatomic) BOOL enteredBackground;

+ (instancetype)sightingManager:(GMBLBeaconManager *)beaconManager;
- (instancetype)initWithGimbalBeaconManager:(GMBLBeaconManager *)beaconManager NS_DESIGNATED_INITIALIZER;
@end
