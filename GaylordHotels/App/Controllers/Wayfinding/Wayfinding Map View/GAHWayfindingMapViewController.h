//
//  GAHWayfindingMapViewController.h
//  GaylordHotels
//
//  Created by MeetingPlay on 5/18/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "GAHMapViewController.h"

@class CHARoute, GAHDestination, GAHDirectionsDataSource;

@interface GAHWayfindingMapViewController : GAHMapViewController

@property (nonatomic, strong) CHARoute *route;
@property (nonatomic, strong) GAHDestination *start;
@property (nonatomic, strong) GAHDestination *destination;

@property (nonatomic, strong) NSNumber *initialVisibleFloor;

@property (strong, nonatomic) CHARouteOverlay *routeOverlay;

@property (nonatomic, assign) BOOL routeRequestInProgress;

- (void)showDestinationsOnFloor:(NSNumber *)visibleFloor;
- (void)clearMarkerPoints;

- (void)loadRouteNodes:(CHARoute *)route;

- (void)loadRoutePaths:(CHARouteOverlay *)routeOverlay;
- (void)displayRoutePathOverlay:(CHARouteOverlay *)pathOverlay;

- (void)clearRoutes;

- (void)displayRouteAndNodes;
- (void)resetMapView;

- (void)loadMapZoomToDestination:(CHADestination *)destination animated:(BOOL)animated;

- (void)loadMapZoomToDestination:(CHADestination *)destination
                       zoomScale:(CGFloat)zoomScale
                        animated:(BOOL)animated
               completionHandler:(void (^)(void))completionHandler;

@end
