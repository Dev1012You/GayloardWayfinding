//
//  MDCustomTransmitter.h
//  MarriottDigitalSummit
//
//  Created by Michael Thongvanh on 4/30/14.
//  Copyright (c) 2014 Grumble Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Gimbal/GMBLBeacon.h>

@interface MDCustomTransmitter : NSObject

/// A unique string identifier (factory id) that represents the beacon
@property (readonly, nonatomic) NSString *identifier;

/// The name for the GMBLBeacon that can be assigned via the Gimbal Manager
@property (readonly, nonatomic) NSString *name;

/// The iconUrl for the GMBLBeacon
@property (readonly, nonatomic) NSString *iconURL;

/// The battery level for the GMBLBeacon
@property (readonly, nonatomic) GMBLBatteryLevel batteryLevel;

/// The ambient temperature surrounding the Beacon in Fahrenheit, the value is equal will be NSIntegerMax if no temperature reading is available for this beacon
@property (readonly, nonatomic) NSInteger temperature;

@property (strong,nonatomic) NSString *accuracy;
@property (strong,nonatomic) NSNumber *minor;
@property (strong,nonatomic) NSNumber *major;
@property (strong,nonatomic) NSNumber *proximity;
@property (strong,nonatomic) NSNumber *rssi_exit;
@property (strong,nonatomic) NSNumber *rssi_entry;
@property (strong,nonatomic) NSNumber *RSSI;
@property (strong,nonatomic) NSNumber *longitude;
@property (strong,nonatomic) NSNumber *latitude;
@property (assign,nonatomic,getter = hasTriggeredEvent) BOOL triggeredEvent;

- (void)fillValuesFrom:(GMBLBeacon *)transmitter;
- (void)fillValuesFromAPI:(NSDictionary *)apiBeaconData;
@end
