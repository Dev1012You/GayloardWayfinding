//
//  UIViewController+GAHWayfindingRouteRequests.h
//  GaylordHotels
//
//  Created by MeetingPlay on 5/14/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CHADestination, CHARoute;

@interface UIViewController (GAHWayfindingRouteRequests)

- (void)sendRouteRequestFromStart:(CHADestination *)startPoint
                      destination:(CHADestination *)destinationPoint
                    requestStatus:(BOOL)requestInProgress
                   successHandler:(void(^)(CHARoute *fetchedRoute))successHandler
                     errorHandler:(void(^)(NSError *error))errorHandler;

- (BOOL)shouldSendRouteRequestForStart:(CHADestination *)start
                           destination:(CHADestination *)destination
                         requestStatus:(BOOL)requestInProgress;
@end
