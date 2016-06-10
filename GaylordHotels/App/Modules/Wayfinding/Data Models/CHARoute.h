//
//  CHARoute.h
//  GaylordHotels
//
//  Created by MeetingPlay on 4/30/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@class UIView;

@interface CHARoute : NSObject

@property (nonatomic, strong) NSArray *mapPoints;
@property (nonatomic, strong) NSArray *directions;
@property (nonatomic, strong) NSArray *floorPathInfo;

+ (void)identifyStepNodes:(NSArray *)nodeCollection;
+ (BOOL)checkTurnNode:(CGPoint)targetPoint headPoint:(CGPoint)headPoint tailPoint:(CGPoint)tailPoint;
@end

@protocol CHARouteDirectionDisplayDelegate <NSObject>

- (void)map:(UIView *)mapView
didFetchRoute:(CHARoute *)route;

- (void)map:(UIView *)mapView
didSwitchRoute:(CHARoute *)route
  fromFloor:(NSNumber *)sourceFloor
    toFloor:(NSNumber *)destinationFloor;

- (BOOL)map:(UIView *)mapView
shouldShowRoute:(CHARoute *)route
 directions:(NSArray *)directionSet
   forFloor:(NSNumber *)floorNumber;

@end