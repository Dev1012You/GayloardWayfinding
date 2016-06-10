//
//  GAHMapDataSource.h
//  GaylordHotels
//
//  Created by MeetingPlay on 5/5/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "GAHDataSource.h"
#import <UIKit/UITableView.h>

@class CHAMapImage, GAHDestination, CHADestination;

@protocol GAHFloorSelectionDelegate <NSObject>
- (void)floorSelector:(UITableView *)tableView didSelectFloor:(CHAMapImage *)mapFloorData;
@end

@interface GAHMapDataSource : GAHDataSource <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) NSArray *mapImageData;

@property (nonatomic, strong) NSArray *mapDestinations;

@property (nonatomic, weak) id <GAHFloorSelectionDelegate> floorSelectionDelegate;


+ (CHAMapImage *)lowestFloor:(NSArray *)mapImageData;

+ (CHAMapImage *)detailsForFloor:(NSNumber *)floorNumber mapImageData:(NSArray *)mapImageData;

+ (NSNumber *)floorForMapID:(NSNumber *)mapID;

- (BOOL)shouldFetchMapImages;



- (NSNumber *)floorNumberForSlug:(NSString *)wayfindingProIdentifier;

- (CHAMapImage *)mapImageForDestination:(GAHDestination *)destination;

- (NSNumber *)defaultFirstFloorForData;

- (CGFloat)scaleForImage:(UIImage *)image insideView:(UIView *)containerView;

- (CGPoint)calculateMapCenterDestinations:(CHADestination *)destination mapImage:(UIImage *)mapImage targetFloor:(NSNumber *)targetFloor;

@end
