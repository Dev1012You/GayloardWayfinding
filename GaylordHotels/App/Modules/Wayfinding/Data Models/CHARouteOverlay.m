//
//  CHARouteOverlay.m
//  GaylordHotels
//
//  Created by MeetingPlay on 5/1/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "CHARouteOverlay.h"

@implementation CHARouteOverlay

+ (instancetype)routeOverlay:(NSMutableDictionary *)routePoints
                     onLayer:(CALayer *)parentLayer
{
    CHARouteOverlay *routeOverlay = [[CHARouteOverlay alloc] initWithLayer:parentLayer];
    routeOverlay.routePoints = routePoints;
    return routeOverlay;
}

- (instancetype)initWithLayer:(id)layer
{
    if (self = [super initWithLayer:layer])
    {
        _routePoints = [NSMutableDictionary new];
        _routeSegments = [NSMutableDictionary new];
        _segmentWidth = 5.f;
    }
    
    return self;
}

- (void)showSegmentsForFloor:(NSNumber *)floorNumber
{
    [self.routeSegments enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         if (![obj isKindOfClass:[NSArray class]]) return;
         
         [obj enumerateObjectsUsingBlock:^(id segment, NSUInteger idx, BOOL *stop) {
             if ([segment isKindOfClass:[CALayer class]])
             {
                 if ([key isKindOfClass:[NSNumber class]])
                 {
                     BOOL isHidden = ![key isEqualToNumber:floorNumber];
                     [(CALayer *)segment setHidden:isHidden];
                 }
             }
         }];
     }];
}

- (void)hideSegmentsForFloor:(NSNumber *)floorNumber
{    
    [self.routeSegments enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
    {
        if (![obj isKindOfClass:[NSArray class]]) return;
        
        [obj enumerateObjectsUsingBlock:^(id segment, NSUInteger idx, BOOL *stop) {
            if ([segment isKindOfClass:[CALayer class]])
            {
                if ([key isKindOfClass:[NSNumber class]])
                {
                    [(CALayer *)segment setHidden:[key isEqualToNumber:floorNumber]];
                }
            }
        }];
    }];
}

- (CHARouteOverlay *)renderRouteWithPoints:(NSMutableDictionary *)routePoints
{
    __weak __typeof(&*self)weakSelf = self;
    [routePoints enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         if ([obj isKindOfClass:[NSArray class]])
         {
             __block CGPoint previousPoint;
             
             NSMutableArray *floorPoints = [NSMutableArray new];
             
             CALayer *floorSegmentContainer = [CALayer layer];
             floorSegmentContainer.name = [NSString stringWithFormat:@"%@",key];
             
             [obj enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
              {
                  if (idx == 0)
                  {
                      previousPoint = [obj CGPointValue];
                      return;
                  }
                  
                  CGPoint currentPoint = [obj CGPointValue];
                  
                  CALayer *lineSegment = [weakSelf constructRouteSegment:previousPoint
                                                                endPoint:currentPoint];
                  
                  lineSegment.name = [NSString stringWithFormat:@"%@%@",
                                      NSStringFromCGPoint(previousPoint),
                                      NSStringFromCGPoint(currentPoint)];
                  
                  if (lineSegment)
                  {
                      [floorPoints addObject:lineSegment];
                      
                      [floorSegmentContainer addSublayer:lineSegment];
                  }
                  
                  previousPoint = currentPoint;
                  
              }];
             
             if (floorSegmentContainer)
             {
                 [weakSelf addSublayer:floorSegmentContainer];
             }
             
             if (floorPoints)
             {
                 [weakSelf.routeSegments setObject:floorPoints forKey:key];
             }
         }
     }];
    
    return self;
}

- (CALayer *)constructRouteSegment:(CGPoint)startPoint
                          endPoint:(CGPoint)endPoint
{
    UIBezierPath *lineSegmentPath = [UIBezierPath bezierPath];
    [lineSegmentPath moveToPoint:startPoint];
    [lineSegmentPath addLineToPoint:endPoint];
    
    CAShapeLayer *lineSegmentLayer = [CAShapeLayer layer];
    lineSegmentLayer.path = lineSegmentPath.CGPath;
    
    UIColor *segmentColor = self.routeSegmentColor ? self.routeSegmentColor : [UIColor orangeColor];
    
    lineSegmentLayer.strokeColor = segmentColor.CGColor;
    lineSegmentLayer.fillColor = nil;
    
    lineSegmentLayer.borderColor = segmentColor.CGColor;
    lineSegmentLayer.borderWidth = 2.f;
    
    lineSegmentLayer.lineCap = kCALineCapRound;
    
    CGFloat segmentWidth = self.segmentWidth > 0 ? self.segmentWidth : 0;
    segmentWidth = self.segmentWidth > 100 ? 100 : self.segmentWidth;
    lineSegmentLayer.lineWidth = segmentWidth;
    
    return lineSegmentLayer;
}

- (void)resetOverlay
{
    [self.routeSegments enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
    {
        [obj enumerateObjectsUsingBlock:^(id segmentLayer, NSUInteger idx, BOOL *stop)
        {
            [segmentLayer removeFromSuperlayer];
        }];
    }];
    
    self.routeSegments = [NSMutableDictionary new];
    self.routePoints = [NSMutableDictionary new];
}

@end