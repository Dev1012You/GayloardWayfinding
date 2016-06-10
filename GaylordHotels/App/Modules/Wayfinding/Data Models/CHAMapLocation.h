//
//  CHAMapLocation.h
//  GaylordHotels
//
//  Created by MeetingPlay on 4/30/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CGGeometry.h>

@interface CHAMapLocation : NSObject

@property (nonatomic, assign) NSNumber *floorNumber;
@property (nonatomic, assign) CGPoint floorLocation;
@property (nonatomic, strong) NSString *rawLocation;
@property (nonatomic, assign) BOOL stepNode;
@property (nonatomic, assign) BOOL continueNode;

+ (instancetype)mapLocation:(NSString *)rawLocation
                xCoordinate:(NSNumber *)xCoordinate
                yCoordinate:(NSNumber *)yCoordinate
                floorNumber:(NSNumber *)floor;;

- (instancetype)initWithLocation:(NSString *)rawLocation
                     xCoordinate:(NSNumber *)xCoordinate
                     yCoordinate:(NSNumber *)yCoordinate
                     floorNumber:(NSNumber *)floor;

// helper method
+ (NSDictionary *)extractLocationInformationFromString:(NSString *)locationString;

// collection convenience method
+ (NSArray *)mapLocationsFromSource:(NSArray *)locationsDataSource;

@end
