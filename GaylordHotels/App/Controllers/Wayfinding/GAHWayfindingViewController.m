//
//  GAHWayfindingViewController.m
//  GaylordHotels
//
//  Created by MeetingPlay on 5/12/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "GAHWayfindingViewController.h"
#import "UIView+AutoLayoutHelper.h"
#import "GAHStoryboardIdentifiers.h"
#import "GAHDestination.h"

#import "GAHAPIDataInitializer.h"
#import "GAHWayfindingMapViewController.h"
#import "MTPBaseNavigationController.h"
#import "GAHDirectionsViewController.h"

#import "CHARouteOverlay.h"
#import "CHAFloorPathInfo.h"
#import "CHAMapLocation.h"
#import "CHADestination.h"
#import "CHADestination+HelperMethods.h"
#import "GAHLocationPlacement.h"

#import "UIViewController+GAHWayfindingRouteRequests.h"
#import "MBProgressHUD.h"

@interface GAHWayfindingViewController () <GAHDirectionsParsingDelegate>
@property (nonatomic, strong) NSLayoutConstraint *toggleContainerHeight;
@property (nonatomic, assign, getter = isAnimatingDirectionsContainer) BOOL animatingDirectionsContainer;
@property (nonatomic, assign) BOOL routeRequestInProgress;
@end

@implementation GAHWayfindingViewController
#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.firstLoad = true;
    self.mapViewController.view.translatesAutoresizingMaskIntoConstraints = false;
    
    [self.refreshButton addTarget:self
                           action:@selector(refreshDirections:)
                 forControlEvents:UIControlEventTouchUpInside];
    
    [self addChildViewController:self.mapViewController];
    [self.mapContainer addSubview:self.mapViewController.view];
    
    self.directionsViewController = [self findDirectionsViewController:self.childViewControllers];
    self.directionsViewController.directionsDelegate = self;
    
    [self setupConstraints];
    
    self.toggleDirectionsContainer.backgroundColor = UIColorFromRGB(0xcac0b6);
    
    [self setupToggleDirectionsButton:self.toggleDirectionsButton];
    [self setupWayfindingHeader];
    
    [self.view bringSubviewToFront:self.wayfindingMapKeyContainer];
    [self.view bringSubviewToFront:self.statusBarBackground];
    [self.view bringSubviewToFront:self.toggleDirectionsContainer];
    
    [self setupNotifications];
}

- (GAHDirectionsViewController *)findDirectionsViewController:(NSArray *)viewControllerCollection
{
    GAHDirectionsViewController *directions = nil;
    for (id viewController in viewControllerCollection)
    {
        if ([viewController isKindOfClass:[MTPBaseNavigationController class]])
        {
            id topViewController = [viewController topViewController];
            if ([topViewController isKindOfClass:[GAHDirectionsViewController class]])
            {
                directions = (GAHDirectionsViewController *)topViewController;
            }
        }
    }
    return directions;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

#pragma mark - Protocol Conformance
- (void)directionsView:(GAHDirectionsViewController *)directionsView didParseDirections:(GAHDirectionsDataSource *)directions
{
    if (self.mapViewController)
    {
        
    }
}


#pragma mark - IBActions
- (IBAction)hideDirections:(id)sender
{
    if ([sender isKindOfClass:[UIButton class]])
    {
        [self.mapViewController.userLocationUpdateTimer invalidate];
        self.mapViewController.userLocationUpdateTimer = nil;
        
        BOOL directionsVisible = self.toggleContainerHeight.constant > (toggleButtonHeight + 20) ? true : false;
        if (directionsVisible)
        {
            [self toggleDirectionsList:nil];
        }
        
        [self.presentingViewController dismissViewControllerAnimated:true
                                                          completion:nil];
    }
}

- (IBAction)refreshDirections:(id)sender
{
    BOOL directionsVisible = self.toggleContainerHeight.constant > (toggleButtonHeight + 20) ? true : false;
    if (!directionsVisible)
    {
        return;
        
        [self loadWayfindingWithStart:self.mapViewController.start
                       andDestination:self.mapViewController.destination
                             animated:true];
    }
}

static CGFloat const toggleButtonHeight = 40.f;
- (IBAction)toggleDirectionsList:(id)sender
{
    if (!self.isAnimatingDirectionsContainer)
    {
        CGFloat newConstantHeight = 0;
        BOOL directionsVisible = self.toggleContainerHeight.constant > (toggleButtonHeight + 20) ? true : false;
        newConstantHeight = directionsVisible ? toggleButtonHeight + 20.f : self.view.frame.size.height / 1.5f;
                
        [self.view layoutIfNeeded];
        self.toggleContainerHeight.constant = newConstantHeight;
        [UIView animateWithDuration:0.3f
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             [self.view layoutIfNeeded];
                         } completion:^(BOOL finished) {
                             
                             self.animatingDirectionsContainer = !finished;
                             
                             [self.toggleDirectionsButton setTitle:[self buttonTextForDirectionsVisible:directionsVisible]
                                                          forState:UIControlStateNormal];
                             
                             BOOL directionsDidShow = !directionsVisible;
                             if (directionsDidShow) {
                                 [self.directionsViewController.directionsCollectionView reloadData];
                             }
                         }];
    }
}

#pragma mark - Helper Methods
- (void)loadDirections:(id)directionSet
{
    NSLog(@"%s\n[%s]: Line %i] %@",__FILE__,__PRETTY_FUNCTION__,__LINE__,
          directionSet);
}

- (void)loadWayfindingWithStart:(CHADestination *)startPoint
                     andDestination:(GAHDestination *)destinationPoint
                           animated:(BOOL)animated
{
    self.mapViewController.destination = destinationPoint;
    [self fetchRoute:startPoint destination:destinationPoint];
}

- (void)fetchRoute:(CHADestination *)startPoint destination:(GAHDestination *)destinationPoint
{
    CHADestination *start = startPoint;
    CHADestination *destination;
    
    // finding matching Wayfinding destinations from MeetingPlay destinations
    NSArray *destinationIdentifiers = [CHADestination identifiersForWayfindingLocations:self.dataInitializer.mapDataSource.mapDestinations];
    NSIndexSet *matchingIndexes = matchingIndexes = [CHADestination indexesOfWayfindingBasePointsForMeetingPlaySlug:destinationPoint.wfpName
                                                                                          wayfindingDataIdentifiers:destinationIdentifiers];
    
    if (matchingIndexes.count > 0)
    {
        destination = [self.dataInitializer.mapDataSource.mapDestinations objectAtIndex:[matchingIndexes firstIndex]];
    }
    
    // send navigation request for destinations
    if (start && destination)
    {
        __weak __typeof(&*self)weakSelf = self;
        [self sendRouteRequestFromStart:start
                            destination:destination
                          requestStatus:self.routeRequestInProgress
                         successHandler:^(CHARoute *fetchedRoute)
         {
             CHARouteOverlay *routeOverlay = [weakSelf constructRouteOverlay:fetchedRoute
                                                                forImageView:weakSelf.mapViewController.mapFloorImageView];
             routeOverlay = [routeOverlay renderRouteWithPoints:routeOverlay.routePoints];
             
             // load directions
             weakSelf.directionsViewController.start = start;
             weakSelf.directionsViewController.destination = destinationPoint;
             
             [weakSelf.directionsViewController setMeetingPlayDestinations:weakSelf.dataInitializer.meetingPlayLocations];
             [weakSelf.directionsViewController setWayfindingDestinations:weakSelf.dataInitializer.mapDataSource.mapDestinations];
             weakSelf.directionsViewController.dataInitializer = weakSelf.dataInitializer;
             
             [weakSelf.directionsViewController map:weakSelf.mapViewController.mapFloorImageView
                                      didFetchRoute:fetchedRoute];
             
             // load map points
             [weakSelf.mapViewController loadRoutePaths:routeOverlay];
             [weakSelf.mapViewController setRoute:fetchedRoute];
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 weakSelf.mapViewController.currentFloor = start.floorNumber;
                 
                 [weakSelf.mapViewController resetMapView];
                 [weakSelf.mapViewController loadMapZoomToDestination:start animated:true];
             });
             
             weakSelf.routeRequestInProgress = false;
             [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:true];
             
         } errorHandler:^(NSError *error) {
             
             SIAlertView *routeFetchError = [[SIAlertView alloc] initWithTitle:@"Route Calculation Problem" andMessage:@"We couldn't calculate your route directions at the moment. Please check your internet connection and try again."];
             [routeFetchError addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alertView)
              {
                  [weakSelf.presentingViewController dismissViewControllerAnimated:true completion:nil];
              }];
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:true];
                 [routeFetchError show];
             });
         }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self resetDirections];
        });
    }
    else
    {
        [self.mapViewController loadMap:true];
    }
}
- (void)resetDirections
{
    [self.mapViewController.locationPlacer removeButtonsFromSuperview:self.mapViewController.buttonCollection];
    [self.mapViewController clearRoutes];
    [self.directionsViewController clearDirections];
}

- (CHARouteOverlay *)constructRouteOverlay:(CHARoute *)route forImageView:(UIImageView *)imageView
{
    NSMutableDictionary *mapPoints = [NSMutableDictionary new];
    
    [route.floorPathInfo enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         // obj contains a floor number and path nodes
         // for each path node add it to map points
         if ([obj isKindOfClass:[CHAFloorPathInfo class]])
         {
             NSMutableArray *floorPoints = [NSMutableArray new];
             
             [[(CHAFloorPathInfo *)obj pathNodes] enumerateObjectsUsingBlock:^(CHAMapLocation *mapLocation, NSUInteger idx, BOOL *stop)
              {
                  CGPoint mapPoint = [mapLocation floorLocation];
                  
                  NSValue *mapPointValue = [NSValue valueWithCGPoint:mapPoint];
                  if (mapPointValue)
                  {
                      [floorPoints addObject:mapPointValue];
                  }
              }];
             
             [mapPoints setObject:floorPoints
                           forKey:[(CHAFloorPathInfo *)obj floorNumber]];
         }
     }];
    
    [self.mapViewController.routeOverlay resetOverlay];
    
    CHARouteOverlay *routeOverlay = [CHARouteOverlay routeOverlay:mapPoints
                                                          onLayer:imageView.layer];
    routeOverlay.routeSegmentColor = [UIColor darkGrayColor];
    routeOverlay.routeSegmentColor = UIColorFromRGB(0x002C77);
    
    routeOverlay.segmentWidth = 5.f;
    
    return routeOverlay;
}

#pragma mark - Initial Setup
+ (instancetype)wayfindingMapView:(GAHWayfindingMapViewController *)mapView
{
    return [[GAHWayfindingViewController alloc] initWithMap:mapView];
}

- (instancetype)initWithMap:(GAHWayfindingMapViewController *)mapView
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Wayfinding" bundle:nil];
    NSAssert(mainStoryboard, @"Wayfinding storyboard returned nil. There should be a storyboard named Wayfinding that contains this view controller.");
    
    self = [mainStoryboard instantiateViewControllerWithIdentifier:GAHWayfindingViewControllerIdentifier];
    
    if (self)
    {
        _mapViewController = mapView;
    }
    
    return self;
}

- (void)setupToggleDirectionsButton:(UIButton *)buttonSetup
{
    buttonSetup.backgroundColor = kBlueGaylord;
    [buttonSetup setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [buttonSetup.titleLabel setFont:[UIFont fontWithName:@"MyriadPro-Regular" size:18.f]];
    [buttonSetup.titleLabel setAdjustsFontSizeToFitWidth:true];
    [buttonSetup.titleLabel setMinimumScaleFactor:0.5f];
    
    [buttonSetup setTitle:[self buttonTextForDirectionsVisible:true] forState:UIControlStateNormal];
    
    [buttonSetup addTarget:self
                    action:@selector(toggleDirectionsList:)
          forControlEvents:UIControlEventTouchUpInside];
}

- (NSString *)buttonTextForDirectionsVisible:(BOOL)visible
{
    return visible ? @"list steps".uppercaseString : @"minimize steps".uppercaseString;
}

- (void)setupWayfindingHeader
{
    NSArray *wayfindingLabels = @[self.refreshButton.titleLabel,
                                  self.userDestinationKeyIcon,
                                  self.hideWayfindingButton.titleLabel,
                                  self.userLocationKeyIcon];
    
    for (UILabel *label in wayfindingLabels)
    {
        label.font = [UIFont fontWithName:@"FontAwesome"
                                     size:14.f];
    }
    
    [self.refreshButton setTitle:@"\uf021" forState:UIControlStateNormal];
    [self.hideWayfindingButton setTitle:@"\uf00d" forState:UIControlStateNormal];
    self.userLocationKeyIcon.text = @"\uf007";
    self.userDestinationKeyIcon.text = @"\uf11e";
    
    for (UILabel *label in @[self.userLocationKeyLabel,self.userDestinationKeyLabel])
    {
        label.font = [UIFont fontWithName:@"MyriadPro-Regular" size:14.f];
        label.numberOfLines = 0;
        label.lineBreakMode = NSLineBreakByClipping;
        label.adjustsFontSizeToFitWidth = true;
        label.minimumScaleFactor = 0.5f;
    }
    self.userLocationKeyLabel.text = @"Your Location";
    self.userDestinationKeyLabel.text = @"Your Destination";
}

- (void)setupNotifications
{

}

#pragma mark - Auto Layout Setup
- (void)setupConstraints
{
    [self.view addConstraints:[self.mapContainer stackAboveView:self.toggleDirectionsContainer]];
    
    self.toggleContainerHeight = [self.toggleDirectionsContainer height:(toggleButtonHeight + 20.f)];
    self.toggleContainerHeight.priority = 750;
    [self.toggleDirectionsContainer addConstraint:self.toggleContainerHeight];
    
    [self.toggleDirectionsButton addConstraint:[self.toggleDirectionsButton height:toggleButtonHeight]];
    [self.toggleDirectionsButton.superview addConstraint:[self.toggleDirectionsButton alignCenterHorizontalSuperview]];
    [self.toggleDirectionsButton.superview
     addConstraints:[self.toggleDirectionsButton pinSides:@[@(NSLayoutAttributeTop),
                                                            @(NSLayoutAttributeLeading),
                                                            @(NSLayoutAttributeTrailing)]
                                                 constant:10.f]];
    // directions list collection view
    [self.toggleDirectionsButton.superview
     addConstraint:[self.toggleDirectionsButton pinSide:NSLayoutAttributeBottom
                                                 toView:self.directionsContainer
                                         secondViewSide:NSLayoutAttributeTop
                                               constant:-10.f]];
    
    [self.directionsContainer.superview
     addConstraints:[self.directionsContainer pinSides:@[@(NSLayoutAttributeBottom),
                                                         @(NSLayoutAttributeLeading),
                                                         @(NSLayoutAttributeTrailing)]
                                              constant:0]];
    
    // wayfinding map key
    [self.wayfindingMapKeyContainer.superview addConstraint:[self.wayfindingMapKeyContainer pinSide:NSLayoutAttributeTop
                                                                                             toView:self.statusBarBackground
                                                                                     secondViewSide:NSLayoutAttributeBottom]];
    [self.wayfindingMapKeyContainer.superview addConstraints:[self.wayfindingMapKeyContainer pinSides:@[@(NSLayoutAttributeLeading),
                                                                                                        @(NSLayoutAttributeTrailing)]
                                                                                             constant:0]];
    [self.wayfindingMapKeyContainer addConstraint:[self.wayfindingMapKeyContainer height:toggleButtonHeight]];
    
    [self.mapViewController.view.superview addConstraints:[self.mapViewController.view pinToSuperviewBounds]];
}

- (BOOL)shouldAutorotate
{
    return true;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}








@end
