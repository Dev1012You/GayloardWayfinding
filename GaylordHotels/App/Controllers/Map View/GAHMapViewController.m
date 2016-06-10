//
//  GAHMapViewController.m
//  GaylordHotels
//
//  Created by MeetingPlay on 4/29/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "GAHMapViewController.h"
#import "GAHCategoriesViewController.h"
#import "CHADestination.h"
#import "CHAMapImage.h"
#import "GAHBaseNavigationController.h"
#import "GAHAPIDataInitializer.h"

#import "CHAMapLocation.h"
#import "CHADestination.h"

#import "GAHDataSource.h"
#import "GAHDestination.h"
#import "GAHPropertyCategory.h"

#import "MDCustomTransmitter+NetworkingHelper.h"

#import "MBProgressHUD.h"
#import "UIView+AutoLayoutHelper.h"

#import "GAHDestination+Helpers.h"
#import "CHADestination+HelperMethods.h"

#import "MDBeaconManager.h"
#import "GAHNodeMarker.h"
#import "DestinationButton.h"
#import "UIViewController+GAHWayfindingRouteRequests.h"
#import "AFNetworkReachabilityManager.h"
#import "GAHSelectionModalView.h"
#import "GAHLocationPlacement.h"

#import "UIImageView+WebCache.h"

#import <Gimbal/Gimbal.h>

@interface GAHMapViewController () <GAHCategorySelectable, GAHSelectionModalDelegate, GAHLocationPlacementDelegate>

@property (nonatomic, strong) GAHDestination *currentDestination;

@property (nonatomic, strong) NSArray *currentlyPlottedDestinations;

@property (nonatomic, strong) GAHDestination *calloutSelectedDestination;

@property (nonatomic, strong) UITapGestureRecognizer *doubleTapRecognizer;
@property (nonatomic, strong) NSLayoutConstraint *floorSelectionContainerHeight;

@property (nonatomic, assign) BOOL shouldHideCategories;
@property (nonatomic, assign) BOOL showingDataError;
@end

@implementation GAHMapViewController

CGFloat buttonSize = 35.f;
CGFloat defaultZoomScale = 0.25f;

#pragma mark - View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.animatingMapContainer = false;
    self.mapFloorImageView.userInteractionEnabled = true;
    self.currentFloor = @(0);
    
    self.locationPlacer = [[GAHLocationPlacement alloc] initWithMapImageView:self.mapFloorImageView
                                                             dataInitializer:self.dataInitializer];
    self.locationPlacer.locationPlacementDelegate = self;
    
    [self setupConstraints];
    
    [self setupInitialViews];

    [self loadMeetingPlayLocationData];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MTP_StartRangingBeacons" object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.userLocationUpdateTimer)
    {
        self.userLocationUpdateTimer = [NSTimer timerWithTimeInterval:3 target:self selector:@selector(updateBeacons:) userInfo:nil repeats:true];
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop addTimer:self.userLocationUpdateTimer forMode:NSDefaultRunLoopMode];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"map view controller did dealloc");
}

- (void)setDataInitializer:(GAHAPIDataInitializer *)dataInitializer
{
    if (_dataInitializer != dataInitializer)
    {
        _dataInitializer = dataInitializer;
    }
    
    if (_locationPlacer && _locationPlacer.dataInitializer != dataInitializer)
    {
        _locationPlacer.dataInitializer = dataInitializer;
    }
}

#pragma mark - Initial Setup

- (void)setupInitialViews
{
    self.buttonOverlay = [CALayer layer];
    [self.mapFloorImageView.layer addSublayer:self.buttonOverlay];
    
    [self setupScrollView:self.mapContainerScrollView
             withDelegate:self];
    
    [self setupDoubleTapGesture:self.mapFloorImageView];
    
    [self.floorSelectionButton setBackgroundColor:[UIColor colorWithWhite:0.45f alpha:0.75f]];
    self.floorSelectionButton.layer.cornerRadius = 5.f;
    [self.floorSelectionButton addTarget:self
                                  action:@selector(showFloorSelectionView:)
                        forControlEvents:UIControlEventTouchUpInside];
    
    if (self.userLocationMarker == nil)
    {
        self.userLocationMarker = [GAHNodeMarker wayfindingButtonType:true withSize:CGSizeMake(48, 56)];
        self.userLocationMarker.hidden = true;
        [self.mapFloorImageView addSubview:self.userLocationMarker];
    }
    
    self.loadingHUD = [[MBProgressHUD alloc] initWithView:self.view];
    self.loadingHUD.labelText = @"Loading Map";
    [self.view addSubview:self.loadingHUD];
}

- (void)loadMeetingPlayLocationData
{
    __weak __typeof(&*self)weakSelf = self;
    
    if (self.dataInitializer.meetingPlayLocations.count == 2)
    {
        [self.dataInitializer fetchMeetingPlayLocations:^(NSArray *locations, NSError *fetchError) {
            
            if (fetchError)
            {
                SIAlertView *noLocations = [[SIAlertView alloc] initWithTitle:@"Network Error"
                                                                   andMessage:@"There was a problem loading the map destinations. Press OK to try again."];
                [noLocations addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alertView) {
                    
                    [weakSelf.dataInitializer fetchMeetingPlayLocations:^(NSArray *locations, NSError *fetchError) {
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf plotDestinationPoints:weakSelf.dataInitializer.meetingPlayLocations
                                          withBaseLocations:weakSelf.dataInitializer.mapDataSource.mapDestinations];
                        });
                    }];
                }];
                
                [noLocations addButtonWithTitle:@"Cancel" type:SIAlertViewButtonTypeCancel handler:nil];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [noLocations show];
                });
            }
            else
            {
                [weakSelf loadMapZoomToDestination:self.currentDestination zoomScale:defaultZoomScale animated:true completionHandler:nil];
            }
        }];
    }
    else if (self.dataInitializer.mapDataSource.mapImageData.count == 0)
    {
        [self.dataInitializer fetchMapImageURLs:^(GAHMapDataSource *mapDataSource, NSError *mapFetchError) {
            
            if (mapFetchError)
            {
                SIAlertView *noMaps = [[SIAlertView alloc] initWithTitle:@"Network Error"
                                                              andMessage:@"There was a problem loading the map information. Press OK to try again."];
                
                [noMaps addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alertView) {
                    [weakSelf loadMeetingPlayLocationData];
                }];
                
                [noMaps addButtonWithTitle:@"Cancel" type:SIAlertViewButtonTypeCancel handler:nil];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [noMaps show];
                });
            }
            else
            {
                [weakSelf loadMapZoomToDestination:weakSelf.currentDestination zoomScale:defaultZoomScale animated:true completionHandler:nil];
            }
        }];
    }
}

- (void)showDataError
{
    if (self.showingDataError)
    {
        return;
    }
    
    self.showingDataError = true;
    [MBProgressHUD hideAllHUDsForView:self.view animated:true];
    
    __weak __typeof(&*self)weakSelf = self;
    SIAlertView *noCategories = [[SIAlertView alloc] initWithTitle:@"Network Error"
                                                        andMessage:@"There was a problem loading the map information. Press OK to try again."];
    
    [noCategories addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alertView) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD showHUDAddedTo:weakSelf.view animated:true];
        });
        
        [weakSelf.dataInitializer fetchMeetingPlayLocations:^(NSArray *locations, NSError *fetchError) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (fetchError)
                {
                    [weakSelf showDataError];
                }
                else
                {
                    [weakSelf plotDestinationPoints:weakSelf.dataInitializer.meetingPlayLocations
                                  withBaseLocations:weakSelf.dataInitializer.mapDataSource.mapDestinations];
                    [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:true];
                }
            });
        }];
        weakSelf.showingDataError = false;
    }];
    
    [noCategories addButtonWithTitle:@"Cancel" type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView) {
        weakSelf.showingDataError = false;
    }];
    
    [noCategories show];
}


- (NSNumber *)retrieveCurrentFloor:(NSString *)locationSlug
{
    NSNumber *currentFloor = @0;
    
    __block NSNumber *mapImageDataDefaultFirstFloor = [self.dataInitializer.mapDataSource defaultFirstFloorForData];
    
    if (locationSlug.length > 0)
    {
        CHADestination *wayfindingDestination = [CHADestination wayfindingBasePointForMeetingPlaySlug:locationSlug wayfindingLocations:self.dataInitializer.mapDataSource.mapDestinations];

        currentFloor = wayfindingDestination.floorNumber;
        if (!currentFloor)
        {
            if (self.currentUserLocationFloor)
            {
                currentFloor = self.currentUserLocationFloor;
            }
            else
            {
                currentFloor = mapImageDataDefaultFirstFloor;
            }
        }
    }
    else
    {
        currentFloor = mapImageDataDefaultFirstFloor;
    }
    
    return currentFloor;
}

#pragma mark View Setup

- (void)setupScrollView:(UIScrollView *)scrollView withDelegate:(id <UIScrollViewDelegate>)delegate
{
    scrollView.minimumZoomScale = 0.1f;
    scrollView.maximumZoomScale = 2.0f;
    scrollView.delegate = delegate;
    scrollView.showsHorizontalScrollIndicator = false;
}

#pragma mark Map Zooming Setup
- (void)loadMap:(BOOL)animated
{
    [self loadMapZoomToDestination:nil zoomScale:defaultZoomScale animated:animated completionHandler:nil];
}

- (void)loadMapZoomToDestination:(GAHDestination *)destination zoomScale:(CGFloat)zoomScale animated:(BOOL)animated completionHandler:(void (^)(void))completionHandler
{
    self.currentDestination = destination;
    self.currentlyPlottedDestinations = destination ? @[destination] : self.dataInitializer.meetingPlayLocations;
    self.currentFloor = [self retrieveCurrentFloor:destination.wfpName];
    
    CHAMapImage *mapImage = [self.dataInitializer.mapDataSource mapImageForDestination:destination];
    
    [self.loadingHUD show:true];
    
    __weak __typeof(&*self)weakSelf = self;
    
    [self.mapFloorImageView sd_setImageWithURL:[mapImage fullMapImageURL]
                              placeholderImage:nil
                                       options:SDWebImageContinueInBackground
                                      progress:nil
                                     completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
    {
        if (error)
        {
            [weakSelf showDataError];
        }
        else
        {
            [weakSelf resetZoomScale:weakSelf.mapFloorImageView];
            
            [weakSelf plotDestinationPoints:weakSelf.currentlyPlottedDestinations
                          withBaseLocations:weakSelf.dataInitializer.mapDataSource.mapDestinations];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [weakSelf showDestinationsOnFloor:mapImage.floorNumber];
            });
            
            [weakSelf zoomDestination:destination mapImageData:mapImage map:image zoomScale:zoomScale];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.loadingHUD hide:true];
        });
        
        if (completionHandler)
        {
            completionHandler();
        }
    }];
}

- (void)zoomDestination:(GAHDestination *)destination mapImageData:(CHAMapImage *)mapImage map:(UIImage *)image zoomScale:(CGFloat)zoomScale
{
    CHADestination *wayfindingDestination = [CHADestination wayfindingBasePointForMeetingPlaySlug:destination.wfpName wayfindingLocations:self.dataInitializer.mapDataSource.mapDestinations];
    
    CGPoint destinationPoint = [self.dataInitializer.mapDataSource
                                calculateMapCenterDestinations:wayfindingDestination
                                mapImage:image
                                targetFloor:wayfindingDestination.floorNumber];
    
    [self zoomToPoint:destinationPoint zoomScale:zoomScale];
}

- (void)zoomToPoint:(CGPoint)zoomCenter zoomScale:(CGFloat)mapScale
{
    self.mapContainerScrollView.zoomScale = mapScale;
    
    CGPoint translatedPoint = [self.mapFloorImageView convertPoint:zoomCenter toView:self.mapContainerScrollView];
    
    translatedPoint = CGPointMake(translatedPoint.x - CGRectGetMidX(self.mapContainerScrollView.frame),
                                  translatedPoint.y - CGRectGetMidY(self.mapContainerScrollView.frame));
    
    if (isnan(translatedPoint.x) || isnan(translatedPoint.y))
    {
        translatedPoint = CGPointZero;
    }
    
    translatedPoint = CGPointMake(MAX(0,translatedPoint.x), MAX(0, translatedPoint.y));
    
    self.mapContainerScrollView.contentOffset = translatedPoint;
}

- (void)updateFloorImage:(NSURL *)floorMapImageURL center:(CGPoint)viewCenter zoomScale:(CGFloat)zoomScale completionHandler:(void(^)(void))completionHandler
{
    UIImage *floorMapImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[floorMapImageURL absoluteString]];
    
    if (floorMapImage)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.mapFloorImageView setImage:floorMapImage];
            [self prepareMapForDisplay:floorMapImage viewCenter:viewCenter zoomScale:zoomScale];
            
            if (completionHandler)
            {
                completionHandler();
            }
            else
            {
                DLog(@"\ncompletion handler is nil");
            }
        });
    }
    else
    {
        [self.loadingHUD show:true];
        
        __weak __typeof(&*self)weakSelf = self;

        [self.mapFloorImageView sd_setImageWithURL:floorMapImageURL
                                  placeholderImage:nil
                                           options:SDWebImageContinueInBackground
                                          progress:nil
                                         completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [weakSelf prepareMapForDisplay:image viewCenter:viewCenter zoomScale:zoomScale];
                
                if (completionHandler)
                {
                    completionHandler();
                }
                else
                {
                    DLog(@"\nno completion handler found");
                }
                [weakSelf.loadingHUD hide:true];
            });
        }];
    }
}

- (void)prepareMapForDisplay:(UIImage *)loadedImage viewCenter:(CGPoint)viewCenter zoomScale:(CGFloat)zoomScale
{
    CGFloat newScaleForImageSize = [self.dataInitializer.mapDataSource scaleForImage:loadedImage
                                                                          insideView:self.mapContainerScrollView];
    
    [self.mapContainerScrollView setMinimumZoomScale:newScaleForImageSize];
    
    CGPoint mapCenter = viewCenter;
    if (CGPointEqualToPoint(mapCenter, CGPointZero))
    {
        mapCenter = CGPointMake(loadedImage.size.width/2.f,
                                loadedImage.size.height/2.f);
    }
    
    [self zoomToPoint:mapCenter zoomScale:zoomScale];
}

#pragma mark Zoom Actions

- (void)setupDoubleTapGesture:(UIView *)tappingView
{
    if (!self.doubleTapRecognizer)
    {
        self.doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didDoubleTap:)];
        self.doubleTapRecognizer.numberOfTapsRequired = 2;
        self.doubleTapRecognizer.delaysTouchesBegan = true;
    }
    
    [tappingView addGestureRecognizer:self.doubleTapRecognizer];
}

- (IBAction)didDoubleTap:(id)sender
{
    if ([sender isKindOfClass:[UITapGestureRecognizer class]])
    {
        if (self.mapContainerScrollView.zoomScale <= self.mapContainerScrollView.minimumZoomScale)
        {
            CGPoint touchPoint = [(UITapGestureRecognizer *)sender locationInView:self.mapFloorImageView];
            CGFloat sideLength = buttonSize * 8.f;
            CGRect touchPointRect = CGRectMake(touchPoint.x - (sideLength/2.f), touchPoint.y - (sideLength/2.f), sideLength, sideLength);
            [self.mapContainerScrollView zoomToRect:touchPointRect animated:true];
        }
        else
        {
            self.mapContainerScrollView.zoomScale = self.mapContainerScrollView.minimumZoomScale;
        }
    }
}

- (void)didShowCalloutForDestinations:(NSArray *)meetingPlayDestinations atLocation:(CGPoint)destinationCenter
{
    [self showCalloutForDestinations:meetingPlayDestinations atLocation:destinationCenter];
}

#pragma mark - Protocol Conformance
#pragma mark UIScrollView Protocol
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    if (self.mapFloorImageView.image)
    {
        return self.mapFloorImageView;
    }
    else
    {
        return nil;
    }
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    [self.locationPlacer removeButtonsFromSuperview:self.buttonCollection];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    [self plotDestinationPoints:self.currentlyPlottedDestinations
              withBaseLocations:self.dataInitializer.wayfindingBaseLocations];
    [self showUserLocation:self.dataInitializer.beaconManager.activeBeacon];
    [self showDestinationsOnFloor:self.currentFloor];
    
    if (self.calloutView)
    {
        [self.calloutView.superview bringSubviewToFront:self.calloutView];
    }
}

#pragma mark GAHMapView Protocol
- (void)loadDestinations:(NSArray *)meetingPlayDestinations
{
    [self plotDestinationPoints:meetingPlayDestinations
              withBaseLocations:self.dataInitializer.mapDataSource.mapDestinations];

    [self.calloutView removeFromSuperview];
    
    [self showDestinationsOnFloor:self.currentFloor];
}

#pragma mark GAHContentReloadable Protocol
- (void)reloadContent:(id)content dataType:(GAHDataType)dataType reloadError:(NSError *)reloadError
{
    if (dataType == GAHDataTypeMapData)
    {
        [self loadMapZoomToDestination:self.currentDestination zoomScale:defaultZoomScale animated:true completionHandler:nil];
    }
}

#pragma mark - Helper Methods

- (void)cancelTimer
{
    [self.userLocationUpdateTimer invalidate];
    self.userLocationUpdateTimer = nil;
}

#pragma mark User Location

- (void)showUserLocation:(MDCustomTransmitter *)activeBeacon
{
//    activeBeacon = [self.dataInitializer.beaconManager findBeacon:@"G6XP-6JC59"];
    
    [self.locationPlacer showUserLocation:self.userLocationMarker
                           displayedFloor:self.currentFloor
                                     view:self.mapFloorImageView
                                   beacon:activeBeacon];
}

- (void)updateBeacons:(id)sender
{
    MDCustomTransmitter *activeBeacon = [self.dataInitializer.beaconManager identifyActiveBeacon];
    [self showUserLocation:activeBeacon];
}

#pragma mark Map Callouts
- (UIView *)createCalloutView:(NSArray *)locations location:(CGPoint)location
{
    NSMutableArray *locationNames = [NSMutableArray new];
    for (GAHDestination *destination in locations)
    {
        [locationNames addObject:destination.location];
    }
    
    NSString *locationList = [locationNames componentsJoinedByString:@"\n"];
    
    UIFont *labelFont = [UIFont fontWithName:@"MyriadPro-Condensed" size:17.f];
    
    self.locationNamesLabel = [UILabel new];
    self.locationNamesLabel.translatesAutoresizingMaskIntoConstraints = false;
    self.locationNamesLabel.font = labelFont;
    self.locationNamesLabel.textColor = [UIColor whiteColor];
    self.locationNamesLabel.adjustsFontSizeToFitWidth = true;
    self.locationNamesLabel.minimumScaleFactor = 1.f;
    self.locationNamesLabel.numberOfLines = 0;
    self.locationNamesLabel.textAlignment = NSTextAlignmentCenter;
    
    self.locationNamesLabel.text = locationList;
    
    CGFloat labelWidth = 200;// MIN(200, 200 / MAX(0.1, self.mapContainerScrollView.zoomScale));
    CGSize locationNamesLabelSize = [self.locationNamesLabel sizeThatFits:CGSizeMake(labelWidth, MAXFLOAT)];
    labelWidth = MAX(100, MIN(locationNamesLabelSize.width, labelWidth));
    locationNamesLabelSize.width = MAX(100, locationNamesLabelSize.width);
    
    UIButton *viewLocationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    viewLocationButton.translatesAutoresizingMaskIntoConstraints = false;
    viewLocationButton.layer.cornerRadius = 5.f;
    [viewLocationButton setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.3]];
    [viewLocationButton setTitle:@"Details" forState:UIControlStateNormal];
    [viewLocationButton addTarget:self action:@selector(didPressLocationDetails:) forControlEvents:UIControlEventTouchUpInside];
    CGFloat viewLocationButtonHeight = 35.f;
    [viewLocationButton addConstraint:[viewLocationButton height:viewLocationButtonHeight]];
    
    CGFloat calloutMargin = 10;
    CGFloat calloutWidth = (labelWidth + (calloutMargin * 2));
    CGFloat calloutHeight = (locationNamesLabelSize.height + viewLocationButtonHeight + (calloutMargin * 3));
    
    UIView *calloutView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, calloutWidth, calloutHeight)];
    calloutView.layer.cornerRadius = 10.f;
    calloutView.backgroundColor = [UIColor blackColor];
    
    [calloutView addSubview:self.locationNamesLabel];
    [calloutView addSubview:viewLocationButton];
    
    [calloutView addConstraints:[self.locationNamesLabel pinSides:@[@(NSLayoutAttributeTop),
                                                                    @(NSLayoutAttributeLeading),
                                                                    @(NSLayoutAttributeTrailing)]
                                                         constant:calloutMargin]];
    [calloutView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[locationNames]-(>=10)-[viewLocation]"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:@{@"locationNames": self.locationNamesLabel,
                                                                                 @"viewLocation": viewLocationButton}]];
    [calloutView addConstraints:[viewLocationButton pinSides:@[@(NSLayoutAttributeLeading),@(NSLayoutAttributeTrailing),@(NSLayoutAttributeBottom)] constant:calloutMargin]];
    
    calloutView.center = CGPointMake(location.x,location.y - (calloutHeight / 2.f) - (calloutMargin * 2));
    
    CGFloat calloutWidthHalf = calloutView.frame.size.width/2.f;
    UIBezierPath *trianglePath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, 30, 30)];
    [trianglePath applyTransform:CGAffineTransformMakeRotation(M_PI_4)];
    [trianglePath applyTransform:CGAffineTransformMakeTranslation(calloutWidthHalf,calloutView.frame.size.height-trianglePath.bounds.size.height/2.f)];

    CAShapeLayer *triangle = [CAShapeLayer layer];
    triangle.path = trianglePath.CGPath;
    triangle.fillColor = [UIColor blackColor].CGColor;
    [calloutView.layer addSublayer:triangle];
    [calloutView.layer insertSublayer:triangle atIndex:0];
    
    return calloutView;
}

- (void)showCalloutForDestinations:(NSArray *)locations atLocation:(CGPoint)location
{
    [self.calloutView removeFromSuperview];
    self.calloutView = nil;
    
    [self.locationNamesLabel removeFromSuperview];
    self.locationNamesLabel = nil;
    
    if (CGPointEqualToPoint(location, self.currentCalloutLocation))
    {
        self.currentCalloutLocation = CGPointZero;
        self.calloutSelectedDestination = nil;
        return;
    }
    else
    {
        self.currentCalloutLocation = location;
    }
    
    self.calloutView = [self createCalloutView:locations location:location];
    [self.mapFloorImageView addSubview:self.calloutView];
    
    [self didSelectDestination:locations];
}

- (void)didSelectDestination:(NSArray *)locations
{
    GAHDestination *firstLocation = [locations firstObject];
    if (firstLocation)
    {
        self.calloutSelectedDestination = firstLocation;
        
        if ([self.mapViewDelegate respondsToSelector:@selector(mapView:didSelectDestination:)])
        {
            [self.mapViewDelegate mapView:self didSelectDestination:firstLocation];
        }
    }
}

- (void)didPressLocationDetails:(id)sender
{
    if (self.mapViewDelegate && [self.mapViewDelegate respondsToSelector:@selector(mapView:didSelectDetails:)])
    {
        [self.mapViewDelegate mapView:self didSelectDetails:self.calloutSelectedDestination];
    }
}

#pragma mark - Map Item Visibility

- (void)showDestinationsOnFloor:(NSNumber *)visibleFloor
{
    [self.locationPlacer showDestinationsOnFloor:visibleFloor
                              destinationMarkers:self.buttonCollection
                              userLocationMarker:self.userLocationMarker];

}

- (void)hideDestinations
{
    [self.locationPlacer hideDestinations:self.buttonCollection];
}

- (void)resetZoomScale:(UIImageView *)mapImageView
{
    self.mapContainerScrollView.minimumZoomScale = [self.dataInitializer.mapDataSource scaleForImage:mapImageView.image insideView:mapImageView.superview];
}

#pragma mark - Destination Plotting Helpers

- (void)plotDestinationPoints:(NSArray *)destinations
            withBaseLocations:(NSArray *)baseLocations
{
    self.currentlyPlottedDestinations = destinations;
    [self.locationPlacer removeButtonsFromSuperview:self.buttonCollection];
    
    self.buttonCollection = [self.locationPlacer destinationMarkers:destinations withBaseLocations:baseLocations];
}

#pragma mark - Floor Selection Modal
- (void)showFloorSelectionView:(id)sender
{
    [self presentFloorSelection];
}

- (void)presentFloorSelection
{
    UIView *targetView;
    if (self.parentViewController)
    {
        targetView = self.parentViewController.view;
    }
    else
    {
        targetView = self.view;
    }
    
    if (self.floorSelector == nil)
    {
        self.floorSelector = [GAHSelectionModalView new];
        self.floorSelector.translatesAutoresizingMaskIntoConstraints = false;
        self.floorSelector.selectionModalDelegate = self;
        [self.floorSelector setupDefaultAppearance:false];
        
        self.floorSelector.containerTitle.text = @"Select a Floor";
        self.floorSelector.containerDescription.text = @"Please choose a floor to view locations";
        
        [self.floorSelector prepareData:self.dataInitializer.mapDataSource.mapImageData];
    }
    
    [targetView addSubview:self.floorSelector];
    
    [targetView addConstraints:[self.floorSelector pinSides:@[@(NSLayoutAttributeLeading),
                                                              @(NSLayoutAttributeTrailing),
                                                              @(NSLayoutAttributeBottom)]
                                                   constant:10]];
    [targetView addConstraint:[self.floorSelector pinToTopSuperview:64.f]];

}

- (UITableViewCell *)selectionModalTableView:(UITableView *)tableView configureCell:(UITableViewCell *)cell data:(id)rowData atIndexPath:(NSIndexPath *)indexPath
{
    cell.textLabel.font = [UIFont fontWithName:@"MyriadPro-Regular" size:15.f];
    
    CHAMapImage *mapImageData = (CHAMapImage *)rowData;
    cell.textLabel.text = [NSString stringWithFormat:@"%@",mapImageData.displayName];
    
    if ([cell respondsToSelector:@selector(layoutMargins)])
    {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if (mapImageData.floorNumber.integerValue == self.currentFloor.integerValue)
    {
        cell.selected = true;
    }
    else
    {
        cell.selected = false;
    }
    
    return cell;
}

- (void)selectionModalTableView:(UITableView *)tableView didSelectData:(id)rowData atIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    
    CHAMapImage *mapImageData = (CHAMapImage *)rowData;
    [self showFloorForMapImage:mapImageData];
    
    [self.floorSelector removeFromSuperview];
}

- (void)showFloorForMapImage:(CHAMapImage *)mapImage
{
    self.currentFloor = mapImage.floorNumber;
    [self hideDestinations];
    
    __weak __typeof(&*self)weakSelf = self;
    
    [self updateFloorImage:[mapImage fullMapImageURL]
                    center:CGPointZero
                 zoomScale:defaultZoomScale
         completionHandler:^
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [weakSelf showDestinationsOnFloor:mapImage.floorNumber];
            [weakSelf showUserLocation:weakSelf.dataInitializer.beaconManager.activeBeacon];
        });
    }];
    
    [self.calloutView removeFromSuperview];
}

#pragma mark - Constraint Setup
- (void)setupConstraints
{
    self.mapContainerScrollView.translatesAutoresizingMaskIntoConstraints = false;
    
    [self.mapContainerScrollView.superview addConstraints:
     [self.mapContainerScrollView pinSides:@[@(NSLayoutAttributeLeading),
                                             @(NSLayoutAttributeTrailing),
                                             @(NSLayoutAttributeBottom)]
                                  constant:0]];
    
    [self.mapContainerScrollView.superview addConstraint:[self.mapContainerScrollView pinToTopSuperview]];
    
    [self.mapContainerScrollView.superview addConstraints:@[[self.mapContainerScrollView alignCenterHorizontalSuperview]]];
    
    [self.mapFloorImageView.superview addConstraints:[self.mapFloorImageView pinToSuperviewBounds]];
    
    
}

static CGFloat buttonWidth = 40.f;
- (void)setupFloorSelectorConstraints
{
    self.floorSelectorContainer.translatesAutoresizingMaskIntoConstraints = false;
    self.floorSelectionButton.translatesAutoresizingMaskIntoConstraints = false;
    
    self.floorSelectionContainerHeight = [self.floorSelectorContainer height:buttonWidth];
    [self.floorSelectorContainer addConstraint:self.floorSelectionContainerHeight];
    [self.floorSelectorContainer addConstraint:[self.floorSelectorContainer width:buttonWidth]];
    [self.floorSelectorContainer.superview addConstraints:@[[self.floorSelectorContainer pinTrailing:5.f],
                                                            [self.floorSelectorContainer pinToBottomSuperview:5.f]]];
    
    [self.floorSelectionButton addConstraint:[self.floorSelectionButton height:buttonWidth]];
    [self.floorSelectionButton.superview addConstraints:[self.floorSelectionButton pinSides:@[@(NSLayoutAttributeBottom),
                                                                                              @(NSLayoutAttributeLeading),
                                                                                              @(NSLayoutAttributeTrailing)]
                                                                                   constant:0]];
}

@end