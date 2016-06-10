//
//  GAHMapDataSource.m
//  GaylordHotels
//
//  Created by MeetingPlay on 5/5/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "GAHMapDataSource.h"
#import "CHAMapImage.h"
#import "GAHDestination+Helpers.h"
#import "CHADestination+HelperMethods.h"

@implementation GAHMapDataSource

- (instancetype)init
{
    if (self = [super init])
    {
        _mapDestinations = [NSArray new];
        _mapImageData = [NSArray new];
    }
    return self;
}

+ (CHAMapImage *)lowestFloor:(NSArray *)mapImageData
{
    __block CHAMapImage *mapImage;
    
    __block NSNumber *mapImageDataDefaultFirstFloor = @1000;
    
    [mapImageData enumerateObjectsUsingBlock:^(CHAMapImage *obj, NSUInteger idx, BOOL *stop)
     {
         if (obj.floorNumber.integerValue < mapImageDataDefaultFirstFloor.integerValue) {
             mapImageDataDefaultFirstFloor = obj.floorNumber;
             mapImage = obj;
         }
     }];
    
    return mapImage;
}

+ (CHAMapImage *)detailsForFloor:(NSNumber *)floorNumber mapImageData:(NSArray *)mapImageData
{
    __block CHAMapImage *mapImage = nil;
    
    [mapImageData enumerateObjectsUsingBlock:^(CHAMapImage * obj, NSUInteger idx, BOOL *stop)
     {
         if (obj.floorNumber.integerValue == floorNumber.integerValue)
         {
//             weakSelf.currentFloor = obj.floorNumber;
             mapImage = obj;
             *stop = true;
         }
     }];
    
    return mapImage;
}

- (BOOL)shouldFetchMapImages
{
    __block BOOL shouldFetchImages = false;
    [self.mapImageData enumerateObjectsUsingBlock:^(CHAMapImage *mapDetails, NSUInteger idx, BOOL *stop)
    {
        if (mapDetails.mapImage == nil)
        {
            shouldFetchImages = true;
            *stop = true;
        }
    }];
    
    return shouldFetchImages;
}

+ (NSNumber *)floorForMapID:(NSNumber *)mapID
{
    NSDictionary *mapScales = [[[NSUserDefaults standardUserDefaults] objectForKey:@"MTP_BaseOptions"] objectForKey:@"GAH_MapScales"];
    NSDictionary *mapFloorIndex = [[mapScales objectForKey:@"GAH_MapFloorIndex"] firstObject];
    NSNumber *floor = [mapFloorIndex objectForKey:[NSString stringWithFormat:@"%@",mapID]];
    return floor;
}

- (CHAMapImage *)mapImageForDestination:(GAHDestination *)destination
{
    NSNumber *currentFloor = nil;
    
    if (destination)
    {
        currentFloor = [self floorNumberForSlug:destination.wfpName];
    }
    else
    {
        currentFloor = [self defaultFirstFloorForData];
    }
    
    CHAMapImage *mapImage = [GAHMapDataSource detailsForFloor:currentFloor
                                                 mapImageData:self.mapImageData];
    
    return mapImage;
}

- (NSNumber *)floorNumberForSlug:(NSString *)wayfindingProIdentifier
{
    NSNumber *floor = nil;
    
    CHADestination *wfpDestination = [CHADestination wayfindingBasePointForMeetingPlaySlug:wayfindingProIdentifier
                                                                       wayfindingLocations:self.mapDestinations];
    if (wfpDestination)
    {
        floor = wfpDestination.floorNumber;
    }
    else
    {
        floor = [self defaultFirstFloorForData];
    }
    
    return floor;
}

- (NSNumber *)defaultFirstFloorForData
{
    __block NSNumber *mapImageDataDefaultFirstFloor = @100;
    [self.mapImageData enumerateObjectsUsingBlock:^(CHAMapImage *obj, NSUInteger idx, BOOL *stop)
     {
         if ([obj.floorName caseInsensitiveCompare:@"lobby-level"] == NSOrderedSame)
         {
             mapImageDataDefaultFirstFloor = obj.floorNumber;
             *stop = true;
         }
         
         //         if (obj.floorNumber.integerValue == 0)
         //         {
         //             mapImageDataDefaultFirstFloor = obj.floorNumber;
         //         }
     }];
    
    return mapImageDataDefaultFirstFloor;
}

- (CGFloat)scaleForImage:(UIImage *)image insideView:(UIView *)containerView
{
    CGFloat newScaleForImage = 1;
    CGFloat aspectRatio = containerView.frame.size.height / containerView.frame.size.width;
    if (aspectRatio < 1.25f)
    {
        newScaleForImage = CGRectGetWidth(containerView.frame) / image.size.width;
    }
    else
    {
        newScaleForImage = CGRectGetHeight(containerView.frame) / image.size.height;
    }
    return newScaleForImage;
}

- (CGPoint)calculateMapCenterDestinations:(CHADestination *)destination mapImage:(UIImage *)mapImage targetFloor:(NSNumber *)targetFloor
{
    CGPoint destinationPoint = CGPointMake(mapImage.size.width/2.f,mapImage.size.height/2.f);
    
    if (destination)
    {
        destinationPoint = CGPointMake(destination.xCoordinate.floatValue,
                                       destination.yCoordinate.floatValue);
    }
    else
    {
        CHADestination *closestPoint = [CHADestination nearestDestinationToPoint:destinationPoint
                                                                         onFloor:targetFloor
                                                                 mapDestinations:self.mapDestinations];
        
        destinationPoint = CGPointMake(closestPoint.xCoordinate.floatValue, closestPoint.yCoordinate.floatValue);
    }
    
    return destinationPoint;
}

#pragma mark - Table View Data Source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.mapImageData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"defaultCell"];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"defaultCell"];
        cell.separatorInset = UIEdgeInsetsZero;
        cell.textLabel.adjustsFontSizeToFitWidth = true;
        cell.textLabel.minimumScaleFactor = 0.5f;
        cell.textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    
    CHAMapImage *mapData = [self.mapImageData objectAtIndex:indexPath.row];
    cell.textLabel.text = mapData.displayName;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    if (self.floorSelectionDelegate && [self.floorSelectionDelegate respondsToSelector:@selector(floorSelector:didSelectFloor:)])
    {
        CHAMapImage *mapImageData = [self.mapImageData objectAtIndex:indexPath.row];
        [self.floorSelectionDelegate floorSelector:tableView didSelectFloor:mapImageData];
    }
}

@end
