//
//  GAHRootNavigationController.m
//  GaylordHotels
//
//  Created by MeetingPlay on 4/28/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "GAHRootNavigationController.h"
#import "GAHBaseNavigationController.h"
#import "GAHBaseViewController.h"
#import "GAHBaseHeaderStyleViewController.h"

#import "GAHDirectionsViewController.h"
#import "GAHExploreMainViewController.h"
#import "GAHLandingViewController.h"
#import "GAHLocationSearchViewController.h"
#import "GAHMainMenuViewController.h"
#import "GAHMapViewController.h"
#import "GAHMeetingsLandingViewController.h"
#import "GAHNotificationsViewController.h"
#import "GAHUserSettingsViewController.h"
#import "GAHGeneralInfoViewController.h"

#import "GAHWayfindingViewController.h"
#import "GAHWayfindingMapViewController.h"

#import "GAHDestination.h"
#import "GAHDataSource.h"
#import "GAHAPIDataInitializer.h"
#import "GAHStoryboardIdentifiers.h"
#import "MDCustomTransmitter+NetworkingHelper.h"

#import "CHADestination.h"
#import "MBProgressHUD.h"
#import "NSMutableURLRequest+MTPCategory.h"
#import "NSURLSession+MTPCategory.h"
#import "NSString+MTPAPIAddresses.h"

@interface GAHRootNavigationController ()
@end      

@implementation GAHRootNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationBarHidden = true;
    
    self.apiInitializer = [GAHAPIDataInitializer new];
    self.apiInitializer.beaconManager = self.beaconSightingManager.beaconManager;

    [self startAPIDataFetching];
    
    MTPMenuItem *homeItem = [MTPMenuItem menuItemFromDictionary:[[self.userDefaults objectForKey:@"MTP_HomeScreen"] firstObject]];

    [self loadViewController:homeItem
       controllerDataSources:[self extractViewControllerDataSources:homeItem]];
    
    [self registerNotifications];
    
    id topViewController = self.topViewController;
    if ([topViewController respondsToSelector:@selector(setDataInitializer:)])
    {
        [topViewController setDataInitializer:self.apiInitializer];
    }
}

- (void)registerNotifications
{
    DLog(@"\nregister for notifications");
}

- (void)startAPIDataFetching
{
    __weak __typeof(&*self)weakSelf = self;
    [self.apiInitializer fetchInitialAPIData:^(GAHMapDataSource *mapDataSource, NSError *fetchError)
     {
         if (mapDataSource)
         {
             weakSelf.mapDataSource = mapDataSource;
         }
     }];
    
    [self.apiInitializer fetchMeetingPlayLocations:^(NSArray *locations,NSError *fetchError)
     {
         weakSelf.destinations = locations;
         
         if (![GAHDestination archiveDestinationCollection:locations])
         {
             [MBProgressHUD hideAllHUDsForView:self.view animated:true];
         }
     }];
    
    
    [self.beaconSightingManager.beaconManager getEventBeacons:^(NSArray *fetchedBeacons)
    {
        NSMutableURLRequest *mapsRequest = [NSMutableURLRequest defaultRequestMethod:@"GET" URL:[NSString locationMaps] parameters:nil];
        [[[NSURLSession sharedSession] dataTaskWithRequest:mapsRequest
                                         completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
          {
              if (error)
              {
                  DLog(@"\nerror %@", error);
              }
              else
              {
                  id responseObject = [NSURLSession serializeJSONData:data response:response error:error];
                  if ([responseObject isKindOfClass:[NSDictionary class]])
                  {
                      NSMutableDictionary *maps = [NSMutableDictionary new];
                      NSArray *mapObjects = [[responseObject objectForKey:@"data"] objectForKey:@"beacons"];
                      for (NSDictionary *mapObject in mapObjects)
                      {
                          [maps setObject:mapObject forKey:[mapObject objectForKey:@"mapid"]];
                      }
                      self.apiInitializer.meetingPlayMaps = maps;
                  }
              }
          }] resume];
    }];
}

- (GAHMapViewController *)sharedMapViewController
{
    UIStoryboard *currentStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    GAHMapViewController *sharedMapViewController = [currentStoryboard instantiateViewControllerWithIdentifier:GAHMapViewControllerIdentifier];
    sharedMapViewController.view.translatesAutoresizingMaskIntoConstraints = false;
    
    sharedMapViewController.dataInitializer = self.apiInitializer;
    
    [sharedMapViewController loadMap:true];
    
    sharedMapViewController.floorSelectorContainer.hidden = false;
    [sharedMapViewController setupFloorSelectorConstraints];
    
    sharedMapViewController.mapContainerScrollView.zoomScale = 2.0;

    return sharedMapViewController;
}

#pragma mark Override Super Class Methods

- (void)loadViewController:(MTPMenuItem *)menuItem controllerDataSources:(NSArray *)viewControllerDataSources
{
    GAHBaseViewController *vc = (GAHBaseViewController *)[self configureViewController:viewControllerDataSources.firstObject];
    
    vc.rootNavigationController = self;
    
    self.viewControllers = @[vc];
}

- (GAHBaseHeaderStyleViewController *)configureViewController:(MTPViewControllerDataSource *)dataSource
{
    switch (dataSource.dataSourceType)
    {
        case MTPDisplayStyleNone:
        {
            GAHLandingViewController *landing =
            [GAHLandingViewController loadDestinations:self.destinations
                                         mapDataSource:self.mapDataSource
                                        withStoryboard:self.storyboard
                                         andIdentifier:GAHLandingViewControllerIdentifier];
            landing.dataInitializer = self.apiInitializer;
            landing.directionsLoader = self;
            
            return landing;
        }
        case MTPDisplayStyleExplore:
        {
            GAHExploreMainViewController *baseViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:GAHExploreMainViewControllerIdentifier];
            
            baseViewController.rootNavigationController = self;
            baseViewController.dataInitializer = self.apiInitializer;
            baseViewController.directionsLoader = self;
            
            baseViewController.beaconManager = self.beaconSightingManager.beaconManager;
            
            return baseViewController;
        }
        case MTPDisplayStyleExploreDetails:
        {
            return nil;
        }
        case MTPDisplayStyleEvents:
        {
            GAHMeetingsLandingViewController *landings = [[UIStoryboard storyboardWithName:@"GAHMeetingsLandingViewController" bundle:nil] instantiateViewControllerWithIdentifier:@"GAHMeetingsLandingViewController"];
            landings.dataInitializer = self.apiInitializer;
            return landings;
        }
        case MTPDisplayStyleNotifications:
        {
            GAHNotificationsViewController *notifications = [[UIStoryboard storyboardWithName:@"Notifications" bundle:nil] instantiateViewControllerWithIdentifier:@"GAHNotificationsViewController"];
            notifications.dataInitializer = self.apiInitializer;
            return notifications;
        }
        case MTPDisplayStyleGeneralInformation:
        {
            GAHGeneralInfoViewController *generalInfo = [self.storyboard instantiateViewControllerWithIdentifier:@"GAHGeneralInfoViewController"];
            generalInfo.generalInfoURL = @"http://deploy.meetingplay.com/gaylord/general-information/";
            generalInfo.dataInitializer = self.apiInitializer;
            return generalInfo;
        }
        case MTPDisplayStyleUserSettings:
        {
            GAHUserSettingsViewController *userSettings = [[UIStoryboard storyboardWithName:@"GAHUserSettingsViewController" bundle:nil] instantiateInitialViewController];
            userSettings.dataInitializer = self.apiInitializer;
            return userSettings;
        }
        case MTPDisplayStyleSearch:
        {
            GAHLocationSearchViewController *locationSearch =
            [GAHLocationSearchViewController loadDestinations:self.destinations
                                         mapDataSource:self.mapDataSource
                                        withStoryboard:self.storyboard
                                         andIdentifier:GAHLocationSearchViewControllerIdentifier];
            
            locationSearch.dataInitializer = self.apiInitializer;
            locationSearch.configurationDataSource = dataSource;
            locationSearch.contentDataSource.meetingPlayDestinations = self.apiInitializer.meetingPlayLocations;
            locationSearch.directionsLoader = self;
            
            return locationSearch;
        }
        default:
            break;
    }
    return nil;
}

#pragma mark - Protocol Conformance
- (void)topViewControllerShouldToggleMenu:(id)sender
{
    if ([self.topViewController respondsToSelector:@selector(topViewControllerShouldToggleMenu:)])
    {
        [self.topViewController performSelectorOnMainThread:@selector(topViewControllerShouldToggleMenu:)
                                                 withObject:sender
                                              waitUntilDone:true];
    }
}

- (void)loadWayfindingStart:(CHADestination *)startPoint destination:(GAHDestination *)destinationPoint
{
    __weak __typeof(&*self)weakSelf = self;
    void (^loadWayfindingLocations)(CHADestination *start, GAHDestination *destination) = ^(CHADestination *start, GAHDestination *destination)
    {
        if (start && destination)
        {
            GAHWayfindingViewController *wayfindingViewController = [weakSelf persistentWayfindingSession];
            
            [wayfindingViewController loadWayfindingWithStart:start
                                               andDestination:destination
                                                     animated:true];
            
            [weakSelf presentViewController:wayfindingViewController
                                   animated:true
                                 completion:^(void)
             {
                 if (!wayfindingViewController.firstLoad)
                 {
                     [wayfindingViewController loadWayfindingWithStart:start
                                                        andDestination:destination
                                                              animated:true];
                 }
             }];
        }
        else
        {
            SIAlertView *alert = [[SIAlertView alloc] initWithTitle:@"Wayfinding Error" andMessage:@"Sorry, there was an error calculating the wayfinding route. Make sure your current location is not the same as the destination."];
            [alert addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alertView) {
                DLog(@"\nalert");
            }];
            [alert show];
            return;
        }
    };
    
    if (startPoint)
    {
        if (loadWayfindingLocations)
        {
            loadWayfindingLocations(startPoint,destinationPoint);
        }
    }
    else
    {
        [MDCustomTransmitter fetchLocationForBeacon:self.beaconSightingManager.beaconManager.activeBeacon.identifier
                                  completionHandler:^(NSString *locationSlug)
         {
             __block GAHDestination *currentClosestDestination = nil;
             [weakSelf.destinations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
              {
                  if ([[obj slug] isEqualToString:locationSlug])
                  {
                      currentClosestDestination = obj;
                      *stop = true;
                  }
              }];
             
             if (loadWayfindingLocations)
             {
                 loadWayfindingLocations(currentClosestDestination,destinationPoint);
             }
         }];
    }
}


- (GAHDestination *)randomStartPoint:(NSArray *)destinations fromDestination:(GAHDestination *)destination
{
    GAHDestination *startPoint = [self.destinations objectAtIndex:(arc4random_uniform(89) % self.destinations.count)];
    return startPoint;
}

#pragma mark - Initial Setup

- (GAHWayfindingViewController *)persistentWayfindingSession
{
    GAHWayfindingMapViewController *mapViewController = (GAHWayfindingMapViewController *)[[UIStoryboard storyboardWithName:@"Wayfinding" bundle:nil] instantiateViewControllerWithIdentifier:GAHWayfindingMapViewControllerIdentifier];
    mapViewController.dataInitializer = self.apiInitializer;
    
    GAHWayfindingViewController *persistentWayfindingSession = [GAHWayfindingViewController wayfindingMapView:mapViewController];
    persistentWayfindingSession.beaconManager = self.beaconSightingManager.beaconManager;
    persistentWayfindingSession.dataInitializer = self.apiInitializer;
    persistentWayfindingSession.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;

    return persistentWayfindingSession;
}







- (BOOL)shouldAutorotate
{
    return true;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)openMapLocationFromURL:(NSURL *)url
{
    if ([self.topViewController isKindOfClass:[GAHBaseViewController class]])
    {
        GAHBaseViewController *topViewController = (GAHBaseViewController *)self.topViewController;
        [topViewController showDestination:url];
    }
}


@end
