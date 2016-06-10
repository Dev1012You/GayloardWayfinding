//
//  GAHWayfindingMapViewController.m
//  GaylordHotels
//
//  Created by MeetingPlay on 5/18/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "GAHWayfindingMapViewController.h"
#import "CHADestination.h"
#import "GAHDestination.h"
#import "DestinationButton.h"
#import "GAHNodeMarker.h"
#import "MBProgressHUD.h"
#import "GAHBaseNavigationController.h"
#import "GAHAPIDataInitializer.h"
#import "GAHMapDataSource.h"
#import "GAHLocationPlacement.h"

#import "CHARouteOverlay.h"
#import "CHARoute.h"
#import "CHAFloorPathInfo.h"
#import "CHAMapLocation.h"
#import "CHAMapImage.h"
#import "CHAInstruction.h"

#import "GAHDirectionsViewController.h"
#import "CHADestination+HelperMethods.h"
#import "UIImageView+WebCache.h"

@interface GAHWayfindingMapViewController ()
@property (nonatomic, assign) CGPoint startLocation;
@property (nonatomic, assign) CGPoint endLocation;
@property (nonatomic, strong) NSMutableDictionary *stepNumberBySlug;
@property (nonatomic, assign) NSInteger currentStep;
@end

@implementation GAHWayfindingMapViewController
#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.mapFloorImageView.layer insertSublayer:self.routeOverlay
                                           below:self.buttonOverlay];
    
    self.routeRequestInProgress = false;
    
    self.floorSelectorContainer.hidden = false;
    self.floorSelectionButton.hidden = false;
    
    [self setupFloorSelectorConstraints];
    
    self.view.backgroundColor = [UIColor blackColor];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)dealloc
{
    NSLog(@"wayfinding vc did dealloc");
}

#pragma mark - IBActions
- (void)showDestinationsOnFloor:(NSNumber *)visibleFloor
{
    [super showDestinationsOnFloor:visibleFloor];
}

#pragma mark Overriden Methods
- (void)loadMapZoomToDestination:(CHADestination *)destination animated:(BOOL)animated
{
    [self loadMapZoomToDestination:destination zoomScale:defaultZoomScale animated:animated completionHandler:nil];
}

- (void)loadMapZoomToDestination:(CHADestination *)destination
                       zoomScale:(CGFloat)zoomScale
                        animated:(BOOL)animated
               completionHandler:(void (^)(void))completionHandler
{
    __block CHAMapImage *mapImage = [self.dataInitializer.mapDataSource.mapImageData firstObject];
    self.currentFloor = destination ? destination.floorNumber : [self.dataInitializer.mapDataSource defaultFirstFloorForData];
    
    mapImage = [GAHMapDataSource detailsForFloor:self.currentFloor
                                    mapImageData:self.dataInitializer.mapDataSource.mapImageData];
    
    [self.loadingHUD show:true];
    
    __weak __typeof(&*self)weakSelf = self;
    [self.mapFloorImageView sd_setImageWithURL:[mapImage fullMapImageURL] placeholderImage:nil options:SDWebImageContinueInBackground progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
        DLog(@"\ndownloaded bytes %@", @(receivedSize));
        
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
        CGFloat newScaleForImageSize = [self.dataInitializer.mapDataSource scaleForImage:image
                                                                              insideView:self.mapContainerScrollView];
        
        [self.mapContainerScrollView setMinimumZoomScale:newScaleForImageSize];

        CGPoint destinationPoint =
        [weakSelf.dataInitializer.mapDataSource calculateMapCenterDestinations:destination
                                                                      mapImage:image
                                                                   targetFloor:weakSelf.currentFloor];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [weakSelf zoomToPoint:destinationPoint zoomScale:defaultZoomScale];
            [weakSelf.loadingHUD hide:true];
            [weakSelf displayRouteAndNodes];
            
            [weakSelf showUserLocation:weakSelf.dataInitializer.beaconManager.activeBeacon];
            
            if (completionHandler)
            {
                completionHandler();
            }
        });
    }];
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self resetMapView];
    });
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    [self resetMapView];
    [self displayRouteAndNodes];
    [self showUserLocation:self.dataInitializer.beaconManager.activeBeacon];
}

- (void)updateFloorImage:(UIImage *)floorMapImage center:(CGPoint)viewCenter zoomScale:(CGFloat)zoomScale
{
    [self.mapFloorImageView setImage:floorMapImage];
    
    [self resetZoomScale:self.mapFloorImageView];
    
    NSArray *floorButtons = [self.buttonCollection objectForKey:self.currentFloor];
    UIView *mapMarker = [floorButtons.firstObject isKindOfClass:[UIView class]] ? floorButtons.firstObject : nil;
    if (mapMarker)
    {
        viewCenter = mapMarker.center;
    }

    [self zoomToPoint:viewCenter zoomScale:zoomScale];
}

- (void)showUserLocation:(MDCustomTransmitter *)activeBeacon
{
    NSInteger previousFloor = self.locationPlacer.currentUserLocationFloor.integerValue;
    
    [super showUserLocation:activeBeacon];
    
    dispatch_async(dispatch_get_main_queue(), ^{

        if (self.userLocationMarker.superview == nil)
        {
            [self.mapFloorImageView addSubview:self.userLocationMarker];
        }
        [self.mapFloorImageView bringSubviewToFront:self.userLocationMarker];
    });

    if (previousFloor != self.locationPlacer.currentUserLocationFloor.integerValue)
    {
        CHAMapImage *mapImage = [GAHMapDataSource detailsForFloor:self.locationPlacer.currentUserLocationFloor
                                                     mapImageData:self.dataInitializer.mapDataSource.mapImageData];
        [self showFloorForMapImage:mapImage];
    }
}

- (void)showFloorForMapImage:(CHAMapImage *)mapImage
{
    self.currentFloor = mapImage.floorNumber;
    
    __weak __typeof(&*self)weakSelf = self;
    
    [weakSelf.calloutView removeFromSuperview];
    [weakSelf resetMapView];

    [self updateFloorImage:[mapImage fullMapImageURL] center:CGPointZero zoomScale:defaultZoomScale completionHandler:^
    {
        [weakSelf displayRouteAndNodes];
        [weakSelf showUserLocation:weakSelf.dataInitializer.beaconManager.activeBeacon];
    }];
}

#pragma mark - Helper Methods
- (void)resetMapView
{
    [self clearMarkerPoints];
    [self clearRoutes];
}

- (void)displayRouteAndNodes
{
    if (self.route)
    {
        [self loadRouteNodes:self.route];
    }
    
    if (self.routeOverlay)
    {
        [self displayRoutePathOverlay:self.routeOverlay];
        [self.routeOverlay showSegmentsForFloor:self.currentFloor];
    }
    
    [self showDestinationsOnFloor:self.currentFloor];
}

#pragma mark Route Display Utility Methods
- (void)loadRoutePaths:(CHARouteOverlay *)routeOverlay
{
    self.routeOverlay = routeOverlay;
}

- (void)displayRoutePathOverlay:(CHARouteOverlay *)pathOverlay
{
    [self.mapFloorImageView.layer insertSublayer:pathOverlay atIndex:0];
}

- (void)clearRoutes
{
    [self.routeOverlay removeFromSuperlayer];
}

#pragma mark Destination and Route Point Loading
- (CHADestination *)wayfindingBasePointForMeetingPlaySlug:(NSString *)locationSlug wayfindingLocations:(NSArray *)wayfindingLocations
{
    CHADestination *basePoint = nil;
    
    NSArray *destinationIdentifiers = [CHADestination identifiersForWayfindingLocations:self.dataInitializer.mapDataSource.mapDestinations];
    NSIndexSet *pointIndex = [CHADestination indexesOfWayfindingBasePointsForMeetingPlaySlug:locationSlug
                                                                   wayfindingDataIdentifiers:destinationIdentifiers];
    if (pointIndex.count > 0)
    {
        basePoint = [self.dataInitializer.mapDataSource.mapDestinations objectAtIndex:[pointIndex firstIndex]];
    }
    return basePoint;
}

- (void)loadRouteNodes:(CHARoute *)route
{
    if (route != self.route) {
        self.route = route;
    }
    
    self.currentStep = 1;
    
    __weak __typeof(&*self)weakSelf = self;
    
    __block NSInteger stepNumber = 1;
    
    self.buttonCollection = nil;
    NSMutableDictionary *buttonCollection = [NSMutableDictionary new];
    
    __block UIView *start = [UIView new];
    __block UIView *finish = [UIView new];
    
    CHADestination *startBasePoint = [CHADestination wayfindingBasePointForMeetingPlaySlug:self.start.wfpName
                                                                       wayfindingLocations:self.dataInitializer.mapDataSource.mapDestinations];
    
    CHADestination *endBasePoint = [CHADestination wayfindingBasePointForMeetingPlaySlug:self.destination.wfpName
                                                                     wayfindingLocations:self.dataInitializer.mapDataSource.mapDestinations];

    [route.floorPathInfo enumerateObjectsUsingBlock:^(id floorPath, NSUInteger idx, BOOL *stop)
    {
        if ([floorPath isKindOfClass:[CHAFloorPathInfo class]])
        {
            __block GAHNodeMarker *lastNode = nil;
            [[floorPath pathNodes] enumerateObjectsUsingBlock:^(id mapLocation, NSUInteger idx, BOOL *stop)
            {
                if (![mapLocation isKindOfClass:[CHAMapLocation class]])
                {
                    return;
                }
                /*
                 *   search for route node in wayfinding data to get the location name
                 */
                id mapDestination = [CHADestination wayfindingBasePointForPoint:[mapLocation floorLocation]
                                                                        onFloor:[mapLocation floorNumber]
                                                                pointCollection:weakSelf.dataInitializer.mapDataSource.mapDestinations];
                
                /*
                 *  using the location name, search for the route node in the meetingplay destinations
                 */
                GAHDestination *meetingPlayDestination = [weakSelf meetingPlayDestinationForIdentifier:[mapDestination destinationName]
                                                                       pointCollection:weakSelf.dataInitializer.meetingPlayLocations];
                
                if (CGPointEqualToPoint([mapLocation floorLocation],[startBasePoint mapLocation:true]))
                {
                    weakSelf.startLocation = [mapLocation floorLocation];
                }
                
                if (CGPointEqualToPoint([mapLocation floorLocation],[endBasePoint mapLocation:true]))
                {
                    weakSelf.endLocation = [mapLocation floorLocation];
                }
                
                /*
                 *   display map marker for node
                 */
                
                NSArray *existingFloorMarkers = [buttonCollection objectForKey:
                                                 [(CHAMapLocation *)mapLocation floorNumber]];
                
                NSMutableArray *floorMarkers = [NSMutableArray arrayWithArray:existingFloorMarkers];
                
                
                GAHNodeMarker *nodeMarker = [weakSelf drawDestination:meetingPlayDestination
                                                            routeNode:mapLocation];
                
                if (floorMarkers.count == 0)
                {
                    floorMarkers = [NSMutableArray new];
                    nodeMarker.stepNode = true;
//                    stepNumber++;
                }
                
                if ([meetingPlayDestination isEqual:self.start])
                {
                    start = nodeMarker;
                    nodeMarker.stepNode = true;
                    stepNumber++;
                }
                else if ([meetingPlayDestination isEqual:weakSelf.destination])
                {
                    finish = nodeMarker;
                }
                else
                {
                    BOOL stepNode = [mapLocation stepNode];
                    nodeMarker.stepNode = stepNode;
                    nodeMarker.hidden = !stepNode;

                    /*
                    // mark the first node after a turn node as a step node
                    if (stepNode == false && lastNode.stepNode == true)
                    {
                        stepNode = true;
                        nodeMarker.hidden = false;
                        nodeMarker.alpha = 1;
                    }
                    */
                    if (stepNode)
                    {
                        nodeMarker.stepLabel.text = [NSString stringWithFormat:@"%ld",(long)stepNumber++];
                    }
                }
                
                lastNode = nodeMarker;
                [weakSelf.mapFloorImageView addSubview:nodeMarker];
                nodeMarker.center = [(CHAMapLocation *)mapLocation floorLocation];
                
                /*
                 *   update the marker collection
                 */
                
                [floorMarkers addObject:nodeMarker];
                
                [buttonCollection setObject:floorMarkers
                                     forKey:[mapLocation floorNumber]];
            }];
        }
    }];
    
    self.buttonCollection = buttonCollection;
    
    if (start)
    {
        [self.mapFloorImageView bringSubviewToFront:start];
    }
    
    if (finish)
    {
        [self.mapFloorImageView bringSubviewToFront:finish];
    }
}

#pragma mark Map Marker Display
- (GAHNodeMarker *)drawDestination:(GAHDestination *)destination
                         routeNode:(CHAMapLocation *)mapLocation
{
    GAHNodeMarker *marker = nil;
    if (destination)
    {
        marker = [self mapRepresentationForDestination:mapLocation.floorLocation
                                           destination:destination];
    }
    
    if (marker == nil)
    {
        marker = [self markerForStepNumber];

        if ([mapLocation stepNode])
        {
            marker.alpha = 1;
        }
        else
        {
            marker.alpha = 0;
        }
    }

    return marker;
}

- (GAHNodeMarker *)mapRepresentationForDestination:(CGPoint)destinationCenter
                                destination:(GAHDestination *)destination
{
    GAHNodeMarker *destinationPoint = nil;
    
    CGPoint baseLocationPoint = CGPointMake(rint(destinationCenter.x),
                                            rint(destinationCenter.y));
    
    BOOL isStart = CGPointEqualToPoint(self.startLocation, baseLocationPoint);
    BOOL isDestination = CGPointEqualToPoint(self.endLocation, baseLocationPoint);
    
    if (isDestination)
    {
        CGSize keyLocationSize = CGSizeMake(24, 28);
        
        CGFloat scaledHeight = MIN(42, MAX(42 / self.mapContainerScrollView.zoomScale,keyLocationSize.height));
        CGFloat scaledWidth = MIN(36, MAX(36 / self.mapContainerScrollView.zoomScale,keyLocationSize.width));
        
        destinationPoint = [GAHNodeMarker wayfindingButtonType:isStart withSize:CGSizeMake(scaledWidth, scaledHeight)];
    }
    else
    {
        /*
         *  if there is an image for that destination, show a camera icon
         */

//        if (destination.image.length > 0)
//        {
//            CGFloat modifiedZoomScale = (self.mapContainerScrollView.zoomScale < 0.9 ? self.mapContainerScrollView.zoomScale * 1.5 : self.mapContainerScrollView.zoomScale);
//            CGFloat cameraButtonSize = MIN(35, 35 / modifiedZoomScale);
//            cameraButtonSize = 35;
//            destinationPoint = [GAHNodeMarker cameraButtonWithSize:CGSizeMake(cameraButtonSize, cameraButtonSize) stepNumber:nil];
//        }
//        else
//        {
//            destinationPoint = [self markerForStepNumber];
//        }
//        destinationPoint = [self markerForStepNumber];
    }
    return destinationPoint;
}

- (GAHNodeMarker *)markerForStepNumber
{
    GAHNodeMarker *marker = [GAHNodeMarker new];

    CGFloat stepLabelHeight = 20;
    CGFloat scaledButtonSize = MIN(30, MAX(30 / self.mapContainerScrollView.zoomScale,stepLabelHeight));
    [marker addStepNumberLabel:@(1) labelSize:CGSizeMake(scaledButtonSize, scaledButtonSize)];
    
    return marker;
}

- (void)clearMarkerPoints
{
    [self.mapFloorImageView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         [obj removeFromSuperview];
     }];
}

#pragma mark Destination Identification Methods

- (GAHDestination *)meetingPlayDestinationForIdentifier:(NSString *)wayfindingIdentifier
                                        pointCollection:(NSArray *)meetingPlayDestinations
{
    __block GAHDestination *matchingMeetingPlayDestination = nil;
    [meetingPlayDestinations enumerateObjectsUsingBlock:^(id meetingPlayDestination, NSUInteger idx, BOOL *stop)
    {
        if ([meetingPlayDestination isKindOfClass:[GAHDestination class]])
        {
            NSString *meetingPlayDestinationName = [(GAHDestination *)meetingPlayDestination wfpName];
            if (meetingPlayDestinationName.length > 0)
            {
                if ([meetingPlayDestinationName caseInsensitiveCompare:wayfindingIdentifier] == NSOrderedSame)
                {
                    matchingMeetingPlayDestination = meetingPlayDestination;
                    *stop = true;
                }
            }
        }
    }];

    return matchingMeetingPlayDestination;
}


#pragma mark - Initial Setup
#pragma mark - Protocol Conformance
#pragma mark GAHContentReloadable
- (void)reloadContent:(id)sender dataType:(GAHDataType)dataType reloadError:(NSError *)reloadError
{
    if (dataType == GAHDataTypeMapData)
    {
        [self loadMapZoomToDestination:self.start animated:true];
    }
}

@end
