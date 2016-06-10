//
//  MTPCustomRootNavigationViewController.h
//  MeetingPlayiBeaconStarter
//
//  Created by John Pacheco on 4/3/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import <UIKit/UIKit.h>
// View Controller
#import "MTPBaseNavigationController.h"
#import "MTPBaseTabBarController.h"
#import "MTPBaseViewController.h"

#import "MTPLandingViewController.h"
#import "MTPViewControllerDataSource.h"
#import "MTPWebViewController.h"
#import "MTPLoginViewController.h"

// Managers
#import "MTPAlertManager.h"
#import "MTPLoginClient.h"
#import "MTPBeaconSightingManager.h"
#import "MDBeaconManager.h"
#import "MDMyConnectionManager.h"
#import "MTPSponsorManager.h"

// Helpers
#import "User+Helpers.h"
#import "MTPMenuItem.h"
#import "NSObject+EventDefaultsHelpers.h"
#import "EventKeys.h"
#import "MTPStoryboardIdentifiers.h"

@protocol MTPCustomViewControllerLoader <NSObject>
- (void)loadViewController:(MTPMenuItem *)menuItem
     controllerDataSources:(NSArray *)viewControllerDataSources;
@end

@protocol MTPMainMenuToggling <NSObject>
- (void)topViewControllerShouldToggleMenu:(id)sender;
@end

@interface MTPCustomRootNavigationViewController : UINavigationController <MTPAlertDelegate, MTPCustomViewControllerLoader>

@property (nonatomic, strong) NSManagedObjectContext *rootSavingManagedObjectContext;
@property (nonatomic, strong) MTPBeaconSightingManager *beaconSightingManager;

@property (nonatomic, strong) MTPAlertManager *alertManager;
@property (nonatomic, strong) MTPSessionManager *sessionManager;
@property (nonatomic, strong) MTPSponsorManager *sponsorManager;

@property (nonatomic, strong) MDMyConnectionManager *connectionManager;
@property (nonatomic, strong) User *currentUser;
@property (nonatomic, strong) NSMutableDictionary *loadedMenuItems;

- (void)didReceiveLoginNotification:(NSNumber *)userID;
- (void)topViewControllerShouldToggleMenu:(id)sender;

- (void)loadLogin;
- (void)loadLandingViewController;

- (UIViewController *)prepareViewController:(MTPMenuItem *)menuItem
                      controllerDataSources:(NSArray *)viewControllerDataSources;

- (MTPBaseViewController *)configureViewController:(MTPViewControllerDataSource *)dataSource;

- (MTPBaseTabBarController *)configureTabBarController:(NSInteger)selectedIndex
                             viewControllerDataSources:(NSArray *)viewControllerDataSources;

@end