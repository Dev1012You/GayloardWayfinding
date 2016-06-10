//
//  MDCustomTransmitter.h
//  MarriottDigitalSummit
//
//  Created by John Pacheco on 4/30/14.
//  Copyright (c) 2014 Grumble Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Gimbal/GMBLBeacon.h>

@interface MDCustomTransmitter : NSObject <NSCoding, NSCopying>

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

/// Last time a beacon was seen
@property (nonatomic, strong) NSDate *lastSeen;

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

// non-map beacon properties
@property (nonatomic, strong) NSString *meetingPlaySlug;
// map beacon properties
@property (nonatomic, strong) NSNumber *fkMapID;
@property (nonatomic, strong) NSString *friendlyName;
@property (nonatomic, strong) NSString *placementImage;
@property (nonatomic, strong) NSNumber *placementX;
@property (nonatomic, strong) NSNumber *placementY;
@property (nonatomic, assign, getter=isPlaced) BOOL placed;
@property (nonatomic, strong) NSString *installDate;
@property (nonatomic, strong) NSString *placementDescription;
@property (nonatomic, strong) NSNumber *fkPropertyID;

@property (nonatomic, strong) NSString *defaultStart;

@property (nonatomic, strong) NSArray *readingHistory;

- (void)fillValuesFrom:(GMBLBeacon *)transmitter;
- (void)fillValuesFromAPI:(NSDictionary *)apiBeaconData;

- (void)updateRSSI:(NSNumber *)newRSSI;

@end
