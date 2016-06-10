//
//  UIViewController+GAHWayfindingRouteRequests.m
//  GaylordHotels
//
//  Created by MeetingPlay on 5/14/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "UIViewController+GAHWayfindingRouteRequests.h"
#import "CHAWayfindingRouteXMLParser.h"
#import "CHAWayfindingSOAPTask.h"
#import "CHADestination.h"
#import "CHARoute.h"
#import "MBProgressHUD.h"

@implementation UIViewController (GAHWayfindingRouteRequests)

#pragma mark - API Call
- (void)sendRouteRequestFromStart:(CHADestination *)startPoint
                      destination:(CHADestination *)destinationPoint
                    requestStatus:(BOOL)requestInProgress
                   successHandler:(void (^)(CHARoute *))successHandler
                     errorHandler:(void (^)(NSError *))errorHandler
{
    BOOL shouldSendRequest = [self shouldSendRouteRequestForStart:startPoint
                                                      destination:destinationPoint
                                                    requestStatus:requestInProgress];
    if (shouldSendRequest)
    {
        CHAWayfindingRouteXMLParser *routeParser = [CHAWayfindingRouteXMLParser new];
        [routeParser setParseCompletionHandler:successHandler];
        [routeParser setErrorHandler:errorHandler];
        
        CHAWayfindingSOAPTask *routeRequest =
        [CHAWayfindingSOAPTask getPathStartFloor:startPoint.floorNumber
                                startXCoordinate:startPoint.xCoordinate
                                startYCoordinate:startPoint.yCoordinate
                                        endFloor:destinationPoint.floorNumber
                                  endXCoordinate:destinationPoint.xCoordinate
                                            endY:destinationPoint.yCoordinate];
        
        routeRequest =
        [CHAWayfindingSOAPTask getPathStartFloor:startPoint.floorNumber
                                startXCoordinate:startPoint.xCoordinate
                                startYCoordinate:startPoint.yCoordinate
                                        endFloor:destinationPoint.floorNumber
                                  endXCoordinate:destinationPoint.xCoordinate
                                            endY:destinationPoint.yCoordinate];

        
        routeRequest.customXMLParser = routeParser;
        [routeRequest startTask];
    }
    else
    {
        if (errorHandler) {
            errorHandler([NSError errorWithDomain:@"GHARouteRequestErrorDomain"
                                             code:1001
                                         userInfo:@{NSLocalizedDescriptionKey: @"Route request criteria failed"}]);
        }
        [MBProgressHUD hideAllHUDsForView:self.view animated:true];
    }
}

- (BOOL)shouldSendRouteRequestForStart:(CHADestination *)start
                           destination:(CHADestination *)destination
                         requestStatus:(BOOL)requestInProgress
{
    if ([start.destinationName isEqualToString:destination.destinationName])
    {
        return false;
    }
    if (!start)
    {
        return false;
    }
    if (!destination)
    {
        return false;
    }
    if (requestInProgress)
    {
        return false;
    }
    
    return true;
}

@end