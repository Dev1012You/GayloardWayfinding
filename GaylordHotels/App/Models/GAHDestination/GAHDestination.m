//
//  GAHDestination.m
//  GaylordHotels
//
//  Created by MeetingPlay on 5/8/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "GAHDestination.h"
#import "CHADestination.h"
#import "NSObject+EventDefaultsHelpers.h"
#import "NSObject+MTPFileManager.h"

@implementation GAHDestination

- (instancetype)init
{
    if (self = [super init])
    {
        _alt = @"";
        _category = @"";
        _image = @"";
        _location = @"";
        _locationid = @(0);
        _slug = @"";
    }
    return self;
}

- (void)updateWithMeetingPlay:(NSDictionary *)meetingPlayDictionary
{
    __weak __typeof(&*self)weakSelf = self;
    [meetingPlayDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        id propertyName = [weakSelf propertyForMeetingPlayKey:key];
        if (propertyName)
        {
            [weakSelf setValueFromKeyMeetingPlayKey:key propertyValue:obj];
        }
    }];
    /*
    self.alt = [self stringOrNil:[meetingPlayDictionary objectForKey:@"alt"]];
    self.category = [self stringOrNil:[meetingPlayDictionary objectForKey:@"category"]];
    self.slug = [self stringOrNil:[meetingPlayDictionary objectForKey:@"slug"]];
    self.image = [self stringOrNil:[meetingPlayDictionary objectForKey:@"image"]];
    self.location = [self stringOrNil:[meetingPlayDictionary objectForKey:@"location"]];
    self.locationid = [self numberOrNil:[meetingPlayDictionary objectForKey:@"locationid"]];
    
    self.mapImage = [self stringOrNil:[meetingPlayDictionary objectForKey:@"mapimage"]];
    self.map = [self stringOrNil:[meetingPlayDictionary objectForKey:@"map"]];
    self.mapSlug = [self stringOrNil:[meetingPlayDictionary objectForKey:@"mapslug"]];
    self.phone = [self stringOrNil:[meetingPlayDictionary objectForKey:@"phone"]];
    
    self.details = [meetingPlayDictionary objectForKey:@"details"];
    self.links = [meetingPlayDictionary objectForKey:@"links"];
    self.promos = [meetingPlayDictionary objectForKey:@"promos"];
    self.images = [meetingPlayDictionary objectForKey:@"images"];
     */
}

- (void)setValueFromKeyMeetingPlayKey:(NSString *)meetingPlayKey propertyValue:(id)propertyValue
{
    if (meetingPlayKey.length > 0 && propertyValue)
    {
        NSSet *propertyArrayNames = [NSSet setWithObjects:@"details",@"links",@"promos",@"images", nil];
        NSSet *propertyNumberNames = [NSSet setWithObjects:@"locationid", nil];
        
        id propertyName = [self propertyForMeetingPlayKey:meetingPlayKey];
        
        if ([propertyNumberNames containsObject:propertyName])
        {
            [self setValue:[self numberOrNil:propertyValue] forKey:propertyName];
        }
        else
        {
            if ([propertyArrayNames containsObject:meetingPlayKey])
            {
                [self setValue:propertyValue forKey:propertyName];
            }
            else
            {
                [self setValue:[self stringOrNil:propertyValue] forKey:propertyName];
            }
        }
    }
}

- (NSDictionary *)propertyForMeetingPlayKey:(NSString *)meetingPlayKey
{
    NSDictionary *keyAndPropertyName = @{@"alt": @"alt",
                                         @"category": @"category",
                                         @"slug": @"slug",
                                         @"image": @"image",
                                         @"location": @"location",
                                         @"locationid": @"locationid",
                                         @"mapimage": @"mapImage",
                                         @"map": @"map",
                                         @"mapslug": @"mapSlug",
                                         @"phone": @"phone",
                                         @"details": @"details",
                                         @"links": @"links",
                                         @"promos": @"promos",
                                         @"images": @"images",
                                         @"name": @"wfpName",
                                         @"room_key": @"roomKey"};
    
    return [keyAndPropertyName objectForKey:meetingPlayKey];
}

- (NSString *)stringOrNil:(id)possibleValue
{
    return [possibleValue isKindOfClass:[NSString class]] ? possibleValue : nil;
}

- (NSNumber *)numberOrNil:(id)possibleValue
{
    return [possibleValue isKindOfClass:[NSNumber class]] ? possibleValue : nil;
}

+ (GAHDestination *)existingDestination:(NSString *)destinationName inCollection:(NSArray *)collection
{
    __block GAHDestination *matchingDestination = nil;
    [collection enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         if ([obj isKindOfClass:[GAHDestination class]])
         {
             GAHDestination *destination = (GAHDestination *)obj;
             NSString *meetingPlayLocationName = [destination slug];

             if ([meetingPlayLocationName.lowercaseString isEqualToString:destinationName.lowercaseString])
             {
                 matchingDestination = destination;
                 *stop = true;
             }
         }
     }];
    
    return matchingDestination;
}

#pragma mark - NSCoding Protocol
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self)
    {
        _alt = [aDecoder decodeObjectForKey:@"alt"];
        _category = [aDecoder decodeObjectForKey:@"category"];
        _slug = [aDecoder decodeObjectForKey:@"slug"];
        _image = [aDecoder decodeObjectForKey:@"image"];
        _location = [aDecoder decodeObjectForKey:@"location"];
        _locationid = [aDecoder decodeObjectForKey:@"locationid"];
        _wfpName = [aDecoder decodeObjectForKey:@"wfpName"];
        _roomKey = [aDecoder decodeObjectForKey:@"roomKey"];
        
//        _wayfindingDetails = [aDecoder decodeObjectForKey:@"wayfindingDetails"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.alt forKey:@"alt"];
    [aCoder encodeObject:self.category forKey:@"category"];
    [aCoder encodeObject:self.slug forKey:@"slug"];
    [aCoder encodeObject:self.image forKey:@"image"];
    [aCoder encodeObject:self.location forKey:@"location"];
    [aCoder encodeObject:self.locationid forKey:@"locationid"];
    [aCoder encodeObject:self.wfpName forKey:@"wfpName"];
    [aCoder encodeObject:self.roomKey forKey:@"roomKey"];
    
//    [aCoder encodeObject:self.wayfindingDetails forKey:@"wayfindingDetails"];
}

#pragma mark - Archiving
+ (BOOL)archiveDestinationCollection:(NSArray *)destinationCollection
{
    NSUInteger invalidObject = [destinationCollection indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop)
                                  {
                                      if (![obj isKindOfClass:[self class]])
                                      {
                                          *stop = true;
                                          return true;
                                      }
                                      else
                                      {
                                          return false;
                                      }
                                  }];
    
    if (invalidObject == NSNotFound)
    {
        NSURL *urlForArchiving = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",
                                                       [self cacheDirectory],
                                                       [GAHDestination archiveFilename]]];
        
        return [NSKeyedArchiver archiveRootObject:destinationCollection
                                           toFile:urlForArchiving.path];
    }
    
    return false;
}

+ (NSString *)archiveFilename
{
    return @"destinations.archive";
}

#pragma mark - Unarchiving
+ (NSArray *)loadDestinationsFromDisk
{
    NSArray *destinations = [NSArray new];
    
    if ([destinations fileExistsInCaches:[GAHDestination archiveFilename]])
    {
        NSURL *urlForArchiving = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",
                                                       [self cacheDirectory],
                                                       [GAHDestination archiveFilename]]];
        
        destinations = [NSKeyedUnarchiver unarchiveObjectWithFile:[urlForArchiving path]];
        
    }
    else
    {
        destinations = nil;
    }
    
    return destinations;
}
@end
