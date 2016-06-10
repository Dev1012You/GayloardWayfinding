//
//  CHARoute.m
//  GaylordHotels
//
//  Created by MeetingPlay on 4/30/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "CHARoute.h"
#import "CHAMapLocation.h"
#import "CHAFloorPathInfo.h"
#import <UIKit/UIKit.h>

@implementation CHARoute

+ (void)identifyStepNodes:(NSArray *)pathInfoCollection
{
    [pathInfoCollection enumerateObjectsUsingBlock:^(CHAFloorPathInfo *pathInfo, NSUInteger idx, BOOL *stop)
    {
        NSArray *pathNodes = [pathInfo pathNodes];
        
        NSArray *mapPoints = [NSArray arrayWithArray:pathNodes];
        
        CHAMapLocation *mapPointHead;
        CHAMapLocation *mapPointMiddle;
        CHAMapLocation *mapPointTail;
        
        for (NSInteger mapIndex = 0; mapIndex < mapPoints.count; mapIndex++)
        {
            // reset the map points on each iteration
            mapPointHead = nil;
            mapPointMiddle = nil;
            mapPointTail = nil;
            
            if (mapIndex > 1)
            {
                if (mapIndex == mapPoints.count - 1 || mapIndex == mapPoints.count - 2)
                {
                    // always mark the second to last and last point as a step node

                    mapPointHead = mapPoints[mapIndex];
                    mapPointHead.stepNode = true;
                }
                
                // setup necessary map nodes
                mapPointHead = mapPoints[mapIndex];
                mapPointMiddle = mapPoints[mapIndex-1];
                mapPointTail = mapPoints[mapIndex-2];
                
                NSInteger angle = [self calculateAngle:[mapPointMiddle floorLocation]
                                             headPoint:[mapPointHead floorLocation]
                                             tailPoint:[mapPointTail floorLocation]];
                
                BOOL turnNode = [self checkTurnNode:angle];
                mapPointMiddle.stepNode = turnNode;
                
                BOOL continueNode = [self checkContinueNode:angle];
                mapPointMiddle.continueNode = continueNode;
            
            }
            else
            {
                // always mark the first node as a step node
                mapPointHead = mapPoints[mapIndex];
                mapPointHead.stepNode = true;
            }
        }
    }];
}

+ (BOOL)checkTurnNode:(NSInteger)degrees
{
    BOOL isTurnNode = false;
    
    if (degrees > 50 && degrees < 150)
    {
        isTurnNode = true;
    }
    
    return isTurnNode;
}

+ (BOOL)checkContinueNode:(NSInteger)degrees
{
    BOOL isContinueNode = false;
    
    if (degrees > 120 || degrees < 10)
    {
        isContinueNode = true;
    }
    
    return isContinueNode;
}

+ (NSInteger)calculateAngle:(CGPoint)targetPoint headPoint:(CGPoint)headPoint tailPoint:(CGPoint)tailPoint
{
//    NSLog(@"head %@, middle %@, tail %@", NSStringFromCGPoint(headPoint),NSStringFromCGPoint(targetPoint),NSStringFromCGPoint(tailPoint));
    
    CGFloat a = pow(targetPoint.x - headPoint.x, 2) + pow(targetPoint.y - headPoint.y, 2);
    CGFloat b = pow(targetPoint.x - tailPoint.x, 2) + pow(targetPoint.y - tailPoint.y, 2);
    CGFloat c = pow(tailPoint.x - headPoint.x, 2) + pow(tailPoint.y - headPoint.y, 2);
    
    CGFloat radians = acos((a + b - c) / sqrt(4 * a * b));

    CGFloat degrees = radians * 180.f / M_PI;
    NSInteger roundedMeasure = rint(fabs(degrees));
    NSInteger finalMeasure = roundedMeasure % 180;
    
    return finalMeasure;
}

@end
