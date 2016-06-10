//
//  MDCustomTransmitter.m
//  MarriottDigitalSummit
//
//  Created by Michael Thongvanh on 4/30/14.
//  Copyright (c) 2014 Grumble Apps. All rights reserved.
//

#import "MDCustomTransmitter.h"

@interface MDCustomTransmitter ()
@property (strong, readwrite, nonatomic) NSString *identifier;
@property (strong, readwrite, nonatomic) NSString *name;
@property (strong, readwrite, nonatomic) NSString *iconURL;
@property (assign, readwrite, nonatomic) GMBLBatteryLevel batteryLevel;
@property (assign, readwrite, nonatomic) NSInteger temperature;
@end

@implementation MDCustomTransmitter

- (void)fillValuesFrom:(GMBLBeacon *)transmitter
{
    self.name = transmitter.name;
    self.identifier = transmitter.identifier;
    self.iconURL = transmitter.iconURL;
    self.batteryLevel = transmitter.batteryLevel;
    self.temperature = transmitter.temperature;
}

- (void)fillValuesFromAPI:(NSDictionary *)apiBeaconData
{
    self.name = [apiBeaconData objectForKey:@"name"];
    self.accuracy = [apiBeaconData objectForKey:@"accuracy"];
    self.identifier = [apiBeaconData objectForKey:@"beacon_id"];
    
    self.minor = [self changeEmptyStringToNil:[apiBeaconData objectForKey:@"minor"]];
    self.major = [self changeEmptyStringToNil:[apiBeaconData objectForKey:@"major"]];
    self.proximity = [self changeEmptyStringToNil:[apiBeaconData objectForKey:@"proximity"]];
    self.rssi_exit = [self changeEmptyStringToNil:[apiBeaconData objectForKey:@"rssi_exit"]];
    self.rssi_entry = [self changeEmptyStringToNil:[apiBeaconData objectForKey:@"rssi_entry"]];
    self.longitude = [self changeEmptyStringToNil:[apiBeaconData objectForKey:@"longitude"]];
    self.latitude = [self changeEmptyStringToNil:[apiBeaconData objectForKey:@"latitude"]];
}

- (id)changeEmptyStringToNil:(id)possibleString {
    if ([possibleString isKindOfClass:[NSString class]]) {
        return nil;
    } else {
        return possibleString;
    }
}

@end
