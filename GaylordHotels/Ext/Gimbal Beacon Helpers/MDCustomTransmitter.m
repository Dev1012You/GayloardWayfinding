//
//  MDCustomTransmitter.m
//  MarriottDigitalSummit
//
//  Created by John Pacheco on 4/30/14.
//  Copyright (c) 2014 Grumble Apps. All rights reserved.
//

#import "MDCustomTransmitter.h"

@interface MDCustomTransmitter ()
@property (strong, readwrite, nonatomic) NSString *identifier;
@property (strong, readwrite, nonatomic) NSString *name;
@property (strong, readwrite, nonatomic) NSString *iconURL;
@property (assign, readwrite, nonatomic) GMBLBatteryLevel batteryLevel;
@property (assign, readwrite, nonatomic) NSInteger temperature;

@property (nonatomic, assign) NSInteger totalRSSIValues;
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
    
    self.friendlyName = [self changeEmptyStringToNil:[apiBeaconData objectForKey:@"friendly_name"]];
    self.placementDescription = [self changeEmptyStringToNil:[apiBeaconData objectForKey:@"placement_description"]];
    self.placementImage = [self changeEmptyStringToNil:[apiBeaconData objectForKey:@"placement_image"]];
    self.installDate = [self changeEmptyStringToNil:[apiBeaconData objectForKey:@"install_date"]];
    self.defaultStart = [apiBeaconData objectForKey:@"default_start"];

    // bool
    self.placed = [[apiBeaconData objectForKey:@"placed"] boolValue];
    
    // these should all be NSNumber's, but if they are nil, they appear as empty strings
    self.minor = [self changeEmptyStringToNil:[apiBeaconData objectForKey:@"minor"]];
    self.major = [self changeEmptyStringToNil:[apiBeaconData objectForKey:@"major"]];
    self.proximity = [self changeEmptyStringToNil:[apiBeaconData objectForKey:@"proximity"]];
    self.rssi_exit = [self changeEmptyStringToNil:[apiBeaconData objectForKey:@"rssi_exit"]];
    self.rssi_entry = [self changeEmptyStringToNil:[apiBeaconData objectForKey:@"rssi_entry"]];
    self.longitude = [self changeEmptyStringToNil:[apiBeaconData objectForKey:@"longitude"]];
    self.latitude = [self changeEmptyStringToNil:[apiBeaconData objectForKey:@"latitude"]];
    
    self.fkMapID = [self changeEmptyStringToNil:[apiBeaconData objectForKey:@"fk_mapid"]];
    self.fkPropertyID = [self changeEmptyStringToNil:[apiBeaconData objectForKey:@"fk_propertyid"]];
    self.placementX = [self changeEmptyStringToNil:[apiBeaconData objectForKey:@"placement_x"]];
    self.placementY = [self changeEmptyStringToNil:[apiBeaconData objectForKey:@"placement_y"]];
}

- (id)changeEmptyStringToNil:(id)possibleString
{
    if ([possibleString isKindOfClass:[NSString class]]) {
        return nil;
    } else {
        return possibleString;
    }
}

- (void)updateRSSI:(NSNumber *)newRSSI
{
    NSNumber *oldestRSSI = [self.readingHistory firstObject];
    
    if (self.readingHistory.count > 3)
    {
        NSMutableArray *tempReadingHistory = [NSMutableArray arrayWithArray:self.readingHistory];
        [tempReadingHistory removeObject:oldestRSSI];
        self.totalRSSIValues -= oldestRSSI.integerValue;
        self.readingHistory = [NSArray arrayWithArray:tempReadingHistory];
    }
    
    self.readingHistory = [self.readingHistory arrayByAddingObject:newRSSI];
    
    self.totalRSSIValues = 0;
    
    NSInteger newTotal = 0;
    for (NSNumber *rssiValue in self.readingHistory)
    {
        newTotal += rssiValue.integerValue;
    }
    self.totalRSSIValues = newTotal;
    
    NSInteger numberOfReadings = MAX(self.readingHistory.count, 1);
    
    NSNumber *updatedRSSIAverage = @(self.totalRSSIValues/numberOfReadings);
    
    if (updatedRSSIAverage.integerValue > -5)
    {
        updatedRSSIAverage = @-1000;
    }
    
    self.RSSI = updatedRSSIAverage;
}

- (NSArray *)readingHistory
{
    if (_readingHistory == nil)
    {
        _readingHistory = [NSArray new];
    }
    return _readingHistory;
}

// NSCoding Protocol
- (id)initWithCoder:(NSCoder *)aDecoder
{
    MDCustomTransmitter *archivedTransmitter = [MDCustomTransmitter new];
    
    self.name = [aDecoder decodeObjectForKey:@"name"];
    self.accuracy = [aDecoder decodeObjectForKey:@"accuracy"];
    self.identifier = [aDecoder decodeObjectForKey:@"identifier"];
    
    self.friendlyName = [aDecoder decodeObjectForKey:@"friendlyName"];
    self.placementDescription = [aDecoder decodeObjectForKey:@"placementDescription"];
    self.placementImage = [aDecoder decodeObjectForKey:@"placementImage"];
    
    self.installDate = [aDecoder decodeObjectForKey:@"installDate"];
    self.iconURL = [aDecoder decodeObjectForKey:@"iconURL"];
    
    self.placed = [aDecoder decodeBoolForKey:@"placed"];
    self.batteryLevel = [aDecoder decodeIntegerForKey:@"batteryLevel"];
    
    self.minor = [aDecoder decodeObjectForKey:@"minor"];
    self.major = [aDecoder decodeObjectForKey:@"major"];
    self.proximity = [aDecoder decodeObjectForKey:@"proximity"];
    self.rssi_exit = [aDecoder decodeObjectForKey:@"rssi_exit"];
    self.rssi_entry = [aDecoder decodeObjectForKey:@"rssi_entry"];
    self.longitude = [aDecoder decodeObjectForKey:@"longitude"];
    self.latitude = [aDecoder decodeObjectForKey:@"latitude"];
    self.fkMapID = [aDecoder decodeObjectForKey:@"fkMapID"];
    self.fkPropertyID = [aDecoder decodeObjectForKey:@"fkPropertyID"];
    self.placementX = [aDecoder decodeObjectForKey:@"placementX"];
    self.placementY = [aDecoder decodeObjectForKey:@"placementY"];
    self.defaultStart = [aDecoder decodeObjectForKey:@"defaultStart"];
    
    return archivedTransmitter;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.accuracy forKey:@"accuracy"];
    [aCoder encodeObject:self.identifier forKey:@"identifier"];
    
    [aCoder encodeObject:self.friendlyName forKey:@"friendlyName"];
    [aCoder encodeObject:self.placementDescription forKey:@"placementDescription"];
    [aCoder encodeObject:self.placementImage forKey:@"placementImage"];
    [aCoder encodeObject:self.installDate forKey:@"installDate"];
    [aCoder encodeObject:self.iconURL forKey:@"iconURL"];
    
    // bool
    [aCoder encodeBool:self.placed forKey:@"placed"];
    // integer
    [aCoder encodeInteger:self.batteryLevel forKey:@"batteryLevel"];
    
    // these should all be NSNumber's, but if they are nil, they appear as empty strings
    [aCoder encodeObject:self.minor forKey:@"minor"];
    [aCoder encodeObject:self.major forKey:@"major"];
    [aCoder encodeObject:self.proximity forKey:@"proximity"];
    [aCoder encodeObject:self.rssi_exit forKey:@"rssi_exit"];
    [aCoder encodeObject:self.rssi_entry forKey:@"rssi_entry"];
    [aCoder encodeObject:self.longitude forKey:@"longitude"];
    [aCoder encodeObject:self.latitude forKey:@"latitude"];
    
    [aCoder encodeObject:self.fkMapID forKey:@"fkMapID"];
    [aCoder encodeObject:self.fkPropertyID forKey:@"fkPropertyID"];
    [aCoder encodeObject:self.placementX forKey:@"placementX"];
    [aCoder encodeObject:self.placementY forKey:@"placementY"];
    [aCoder encodeObject:self.defaultStart forKey:@"defaultStart"];
}

// NSCopying
- (instancetype)copyWithZone:(NSZone *)zone
{
    MDCustomTransmitter *transmitter = [[[self class] allocWithZone:zone] init];
    
    transmitter.name = [self.name copyWithZone:zone];
    transmitter.accuracy = [self.accuracy copyWithZone:zone];
    transmitter.identifier = [self.identifier copyWithZone:zone];
    transmitter.friendlyName = [self.friendlyName copyWithZone:zone];
    transmitter.placementDescription = [self.placementDescription copyWithZone:zone];
    transmitter.placementImage = [self.placementImage copyWithZone:zone];
    transmitter.installDate = [self.installDate copyWithZone:zone];
    transmitter.iconURL = [self.iconURL copyWithZone:zone];
    
    transmitter.placed = self.placed;
    transmitter.batteryLevel = self.batteryLevel;
    
    transmitter.minor = [self.minor copyWithZone:zone];
    transmitter.major = [self.major copyWithZone:zone];
    transmitter.proximity = [self.proximity copyWithZone:zone];
    transmitter.rssi_exit = [self.rssi_exit copyWithZone:zone];
    transmitter.rssi_entry = [self.rssi_entry copyWithZone:zone];
    transmitter.longitude = [self.longitude copyWithZone:zone];
    transmitter.latitude = [self.latitude copyWithZone:zone];
    transmitter.fkMapID = [self.fkMapID copyWithZone:zone];
    transmitter.fkPropertyID = [self.fkPropertyID copyWithZone:zone];
    transmitter.placementX = [self.placementX copyWithZone:zone];
    transmitter.placementY = [self.placementY copyWithZone:zone];
    transmitter.defaultStart = [self.defaultStart copyWithZone:zone];
    
    return transmitter;
}

@end
