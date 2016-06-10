//
//  CHARouteOverlay.h
//  GaylordHotels
//
//  Created by MeetingPlay on 5/1/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@interface CHARouteOverlay : CALayer

@property (nonatomic, strong) NSMutableDictionary *routePoints;
@property (nonatomic, strong) NSMutableDictionary *routeSegments;

@property (nonatomic, strong) UIColor *routeSegmentColor;
@property (nonatomic, assign) CGFloat segmentWidth;

+ (instancetype)routeOverlay:(NSMutableDictionary *)routePoints
                     onLayer:(CALayer *)parentLayer;

- (CHARouteOverlay *)renderRouteWithPoints:(NSMutableDictionary *)routePoints;

- (CALayer *)constructRouteSegment:(CGPoint)startPoint
                          endPoint:(CGPoint)endPoint;

- (void)showSegmentsForFloor:(NSNumber *)floorNumber;

- (void)hideSegmentsForFloor:(NSNumber *)floorNumber;

- (void)resetOverlay;

@end