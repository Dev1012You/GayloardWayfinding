//
//  CHAFloorPathInfo.h
//  GaylordHotels
//
//  Created by MeetingPlay on 4/30/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CHAFloorPathInfo : NSObject

@property (nonatomic, strong) NSNumber *floorNumber;
/**
 NSArray of CHAMapLocation objects
 */
@property (nonatomic, strong) NSArray *pathNodes;

+ (instancetype)floorPathWithFloor:(NSNumber *)floorNumber
                         pathNodes:(NSArray *)pathNodes;

- (instancetype)initWithFloorNumber:(NSNumber *)floor
                          pathNodes:(NSArray *)pathNodes;

+ (NSArray *)pathNodesFromData:(NSArray *)pathInfo;

+ (NSNumber *)extractFloorNumber:(NSArray *)pathInfo;

// convenient collection creation
//- (NSArray *)floorPathsFromData:(NSArray *)floorPathsDataSource;
@end
