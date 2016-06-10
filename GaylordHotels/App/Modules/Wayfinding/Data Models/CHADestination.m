//
//  CHADestination.m
//  GaylordHotels
//
//  Created by MeetingPlay on 4/28/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "CHADestination.h"
//#import "NSObject+EventDefaultsHelpers.h"
#import "NSObject+MTPFileManager.h"

@implementation CHADestination

+ (instancetype)destinationWithData:(NSDictionary *)dataDictionary
{
    return [[CHADestination alloc] initWithData:dataDictionary];
}

- (instancetype)initWithData:(NSDictionary *)dataDictionary
{
    if (self = [super init])
    {
        [self updateWithData:dataDictionary];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init])
    {
        _buildingID = [aDecoder decodeObjectForKey:@"buildingID"];
        _category = [aDecoder decodeObjectForKey:@"category"];
        _destinationDescription = [aDecoder decodeObjectForKey:@"destinationDescription"];
        _floorNumber = [aDecoder decodeObjectForKey:@"floorNumber"];
        _parentType = [aDecoder decodeObjectForKey:@"parentType"];
        _destinationName = [aDecoder decodeObjectForKey:@"destinationName"];
        
        _isAltDestName = [aDecoder decodeObjectForKey:@"isAltDestName"];
        _isKiosk = [aDecoder decodeObjectForKey:@"isKiosk"];
        _isWayPoint = [aDecoder decodeObjectForKey:@"isWayPoint"];
        _visible = [aDecoder decodeObjectForKey:@"visible"];
        
        _xCoordinate = [aDecoder decodeObjectForKey:@"xCoordinate"];
        _yCoordinate = [aDecoder decodeObjectForKey:@"yCoordinate"];
    }
    return self;
}

- (void)updateWithData:(NSDictionary *)dataDictionary
{
    self.category = [dataDictionary objectForKey:@"Category"];
    
    NSString *base64String = [[dataDictionary objectForKey:@"Description"] length] > 0 ? [dataDictionary objectForKey:@"Description"] : nil;

    if (base64String.length)
    {
        NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:base64String options:0];
        
        NSError *jsonSerializationError = nil;
        id detailsObject = [NSJSONSerialization JSONObjectWithData:decodedData options:NSJSONReadingAllowFragments error:&jsonSerializationError];
        if (jsonSerializationError)
        {
            NSLog(@"\njson serialization error %@ in\n %@", jsonSerializationError,dataDictionary);
        }
        else
        {
            if ([detailsObject isKindOfClass:[NSDictionary class]])
            {
                self.details = [detailsObject objectForKey:@"data"];
                NSString *description = [self.details objectForKey:@"alternate_description"];
                if (description.length > 0)
                {
                    self.destinationDescription = description;
                }
            }
            else
            {
                NSLog(@"\ndetails object %@", detailsObject);
            }
        }
    }
    
    self.parentType = [dataDictionary objectForKey:@"ParentType"];
    self.destinationName = [dataDictionary objectForKey:@"name"];
    
    self.buildingID = [self transformToCoordinate:[dataDictionary objectForKey:@"BuildingID"]];
    self.floorNumber = [self transformToCoordinate:[dataDictionary objectForKey:@"FloorNumber"]];
    
    self.isAltDestName = [self transformToNumber:[dataDictionary objectForKey:@"IsAltDestName"]];
    self.isKiosk = [self transformToNumber:[dataDictionary objectForKey:@"IsKiosk"]];
    self.isWayPoint = [self transformToNumber:[dataDictionary objectForKey:@"isWayPoint"]];
    self.visible = [self transformToNumber:[dataDictionary objectForKey:@"visible"]];

    self.xCoordinate = [self transformToCoordinate:[dataDictionary objectForKey:@"x"]];
    self.yCoordinate = [self transformToCoordinate:[dataDictionary objectForKey:@"y"]];
    
    for (id shouldBeNumber in @[self.buildingID,self.floorNumber,self.isAltDestName,self.isKiosk,self.isWayPoint,self.visible,self.xCoordinate,self.yCoordinate])
    {
        NSAssert1([shouldBeNumber isKindOfClass:[NSNumber class]], @"%@ should have been a number",shouldBeNumber);
    }
}

- (NSNumber *)transformToNumber:(NSString *)sourceString
{
    return [sourceString.lowercaseString isEqualToString:@"true"] ? @(true) : @(false);
}

- (NSNumber *)transformToCoordinate:(NSString *)sourceString
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    return [numberFormatter numberFromString:sourceString];
}

- (CGPoint)mapLocation:(BOOL)shouldRound
{
    CGFloat xCoordinate = shouldRound ? rint([self xCoordinate].floatValue) : [self xCoordinate].floatValue;
    CGFloat yCoordinate = shouldRound ? rint([self yCoordinate].floatValue) : [self yCoordinate].floatValue;
    CGPoint baseLocationPoint = CGPointMake(xCoordinate,yCoordinate);
    return baseLocationPoint;
}

+ (NSArray *)createDestinationCollection:(NSArray *)destinationCollection
{
    NSMutableArray *destinations = [NSMutableArray new];
    
    for (NSDictionary *destinationData in destinationCollection)
    {
        CHADestination *newDestination = [CHADestination destinationWithData:destinationData];
        if (newDestination)
        {
            [destinations addObject:newDestination];
        }
    }
    
    return destinations;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.buildingID forKey:@"buildingID"];
    [aCoder encodeObject:self.category forKey:@"category"];
    [aCoder encodeObject:self.destinationDescription forKey:@"destinationDescription"];
    [aCoder encodeObject:self.floorNumber forKey:@"floorNumber"];
    [aCoder encodeObject:self.parentType forKey:@"parentType"];
    [aCoder encodeObject:self.destinationName forKey:@"destinationName"];
    
    [aCoder encodeObject:self.isAltDestName forKey:@"isAltDestName"];
    [aCoder encodeObject:self.isKiosk forKey:@"isKiosk"];
    [aCoder encodeObject:self.isWayPoint forKey:@"isWayPoint"];
    [aCoder encodeObject:self.visible forKey:@"visible"];
    
    [aCoder encodeObject:self.xCoordinate forKey:@"xCoordinate"];
    [aCoder encodeObject:self.yCoordinate forKey:@"yCoordinate"];
}

+ (NSArray *)destinationsFromDisk
{
    NSArray *destinations = [NSArray new];

    if ([destinations fileExistsInCaches:[CHADestination archiveFilename]])
    {
        NSURL *urlForArchiving = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",
                                                       [self cacheDirectory],
                                                       [CHADestination archiveFilename]]];
        
        destinations = [NSKeyedUnarchiver unarchiveObjectWithFile:[urlForArchiving path]];
        
    }
    else
    {
        destinations = nil;
    }
    
    return destinations;
}

+ (BOOL)saveDestinationCollection:(NSArray *)destinations
{
    for (id possibleDestination in destinations)
    {
        if (![possibleDestination isKindOfClass:[CHADestination class]])
        {
            NSLog(@"%s\n[%s]: Line %i] Invalid object for archival %@",__FILE__,__PRETTY_FUNCTION__,__LINE__,
                  possibleDestination);
            return false;
        }
    }
    
    NSURL *urlForArchiving = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",
                                                   [self cacheDirectory],
                                                   [CHADestination archiveFilename]]];
    
    return [NSKeyedArchiver archiveRootObject:destinations
                                       toFile:urlForArchiving.path];
}

+ (NSString *)archiveFilename
{
    return @"wayfinding_pro_destinations.archive";
}


@end
