//
//  GAHMapViewController.h
//  GaylordHotels
//
//  Created by MeetingPlay on 4/29/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "MTPBaseViewController.h"
#import "CHARoute.h"
#import "GAHMapDataSource.h"
#import "GAHBaseHeaderStyleViewController.h"

@class GAHMapViewController, DestinationButton, GAHDestination, CHARouteOverlay, GAHCategoriesViewController, GAHPropertyCategory, GAHAPIDataInitializer, GAHNodeMarker, MBProgressHUD, GAHLocationPlacement, CHADestination, GAHSelectionModalView;

typedef NS_ENUM(NSUInteger, GAHMapViewSize)
{
    GAHMapViewSizeZero = 0,
    GAHMapViewSizeSmall,
    GAHMapViewSizeMedium,
    GAHMapViewSizeLarge,
    GAHMapViewSizeFullScreen,
};

#pragma mark Map View Delegate Protocol
@protocol GAHMapViewDelegate <NSObject>
@optional
- (void)mapViewWillToggleSize:(GAHMapViewSize)mapSize;
- (void)mapViewDidToggleSize:(GAHMapViewSize)mapSize;

- (void)mapView:(GAHMapViewController *)mapView didSelectDestination:(GAHDestination *)selectedDestination;
- (void)mapView:(GAHMapViewController *)mapView didSelectDetails:(GAHDestination *)selectedDestination;

- (void)changeMapContainerConstraints:(GAHMapViewSize)targetMapSize;
@end

#pragma mark - GAHMapViewController Interface
@interface GAHMapViewController : MTPBaseViewController <UIScrollViewDelegate,GAHAPIDataInitializerDelegate>

extern CGFloat buttonSize;
extern CGFloat defaultZoomScale;

@property (nonatomic, weak) id <CHARouteDirectionDisplayDelegate> directionDisplayDelegate;
@property (nonatomic, weak) id <GAHMapViewDelegate> mapViewDelegate;

@property (nonatomic, strong) GAHAPIDataInitializer *dataInitializer;

// destinations
@property (nonatomic, strong) NSMutableDictionary *buttonCollection;
@property (strong, nonatomic) CALayer *buttonOverlay;
// user location
@property (nonatomic, strong) NSNumber *currentUserLocationFloor;
@property (nonatomic, strong) GAHNodeMarker *userLocationMarker;
@property (nonatomic, strong) NSTimer *userLocationUpdateTimer;

// map container
@property (nonatomic, assign) GAHMapViewSize currentMapContainerSize;
@property (weak, nonatomic) IBOutlet UIScrollView *mapContainerScrollView;
@property (weak, nonatomic) IBOutlet UIImageView *mapFloorImageView;
@property (nonatomic, assign) BOOL animatingMapContainer;

// floor selection
@property (weak, nonatomic) IBOutlet UIView *floorSelectorContainer;
@property (weak, nonatomic) IBOutlet UIButton *floorSelectionButton;
@property (nonatomic, strong) GAHSelectionModalView *floorSelector;
@property (nonatomic, strong) NSNumber *currentFloor;

// callout items
@property (nonatomic, assign) CGPoint currentCalloutLocation;
@property (nonatomic, strong) UIView *calloutView;
@property (nonatomic, strong) UILabel *locationNamesLabel;

// map Helper
@property (nonatomic, strong) MBProgressHUD *loadingHUD;
@property (nonatomic, strong) GAHLocationPlacement *locationPlacer;

#pragma mark - Instance Methods

- (void)showUserLocation:(MDCustomTransmitter *)activeBeacon;
- (void)cancelTimer;

- (void)loadMap:(BOOL)animated;
- (void)loadMapZoomToDestination:(GAHDestination *)destination zoomScale:(CGFloat)zoomScale animated:(BOOL)animated completionHandler:(void (^)(void))completionHandler;

- (void)zoomToPoint:(CGPoint)zoomCenter zoomScale:(CGFloat)mapScale;
- (void)zoomDestination:(GAHDestination *)destination mapImageData:(CHAMapImage *)mapImage map:(UIImage *)image zoomScale:(CGFloat)zoomScale;

- (NSNumber *)retrieveCurrentFloor:(NSString *)locationSlug;

- (void)showFloorForMapImage:(CHAMapImage *)mapImage;
- (void)updateFloorImage:(NSURL *)floorMapImageURL center:(CGPoint)viewCenter zoomScale:(CGFloat)zoomScale completionHandler:(void(^)(void))completionHandler;

- (void)resetZoomScale:(UIImageView *)mapImageView;

- (void)setupFloorSelectorConstraints;

#pragma mark Destination Plotting Helpers

- (void)loadDestinations:(NSArray *)meetingPlayDestinations;

- (void)plotDestinationPoints:(NSArray *)destinations withBaseLocations:(NSArray *)baseLocations;

- (void)showDestinationsOnFloor:(NSNumber *)visibleFloor;

@end






