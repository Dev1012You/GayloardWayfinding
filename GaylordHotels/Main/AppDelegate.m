//
//  AppDelegate.m
//  GaylordHotels
//
//  Created by John Pacheco on 4/27/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "AppDelegate.h"

#import "MTPCustomRootNavigationViewController.h"
#import "GAHRootNavigationController.h"
// Managers
#import "MTPCoreDataInitializationHelper.h"
#import "MTPApplicationDefaultsManager.h"
#import "MTPRemoteNotificationHandler.h"
#import "MTPAlertManager.h"

//#import "MTPAPIDataInitializer.h"
#import "GAHAPIDataInitializer.h"
#import "MTPGimbalInitializer.h"
#import "MDBeaconManager.h"

#import "NSObject+EventDefaultsHelpers.h"
#import "AFNetworkReachabilityManager.h"
#import "MTPAppSettingsKeys.h"

// Services
#import <Gimbal/Gimbal.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <Parse/Parse.h>

@interface AppDelegate ()
@property (nonatomic, strong) MTPCustomRootNavigationViewController *navigationController;
@property (nonatomic, strong) MTPCoreDataInitializationHelper *coreDataHelper;
@property (nonatomic, strong) MTPApplicationDefaultsManager *defaultsManager;
@property (nonatomic, strong) MTPRemoteNotificationHandler *notificationHandler;

@property (nonatomic, strong) MTPGimbalInitializer *gimbalInitializer;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.navigationController = (MTPCustomRootNavigationViewController *)self.window.rootViewController;

    self.coreDataHelper = [[MTPCoreDataInitializationHelper alloc]
                           initWithManagedObjectModelName:@"GaylordHotels"
                           sqliteStoreName:@"GaylordHotels"];
    
    self.defaultsManager = [MTPApplicationDefaultsManager defaultsManager:self];
    NSString *apiKey = [[self.defaultsManager.userDefaults objectForKey:MTP_BeaconOptions] objectForKey:MTP_GimbalAPIKey];
    [Gimbal setAPIKey:apiKey
              options:nil];
    
    self.gimbalInitializer = [MTPGimbalInitializer new];
    self.navigationController.beaconSightingManager = self.gimbalInitializer.beaconSightingManager;
    [self.gimbalInitializer.beaconSightingManager.beaconManager getEventBeacons];

//    // alert manager will use the navigation controllers session manager that was initialized in
//    // the api initializer to show session details
//    self.navigationController.alertManager = [MTPAlertManager alertManager:self.navigationController];
    
    self.notificationHandler = [MTPRemoteNotificationHandler notificationHandler:self
                                                        rootNavigationController:self.navigationController];
    [self registerForRemoteNotifications];
    
//    self.navigationController.rootSavingManagedObjectContext = [self.coreDataHelper managedObjectContext];

    [self.notificationHandler launchWithOptions:launchOptions];
    
    [Fabric with:@[[Crashlytics class]]];
    [Parse setApplicationId:@"SpCfSbvnfsh1UD9nPtmDvcfc162hNxLD1sTPh9ih"
                  clientKey:@"vN3y5tjX6EOOCgM5ych8yivAXMaPDeUqasj8XMVj"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MTP_StartRangingBeacons" object:nil];
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Core Data Saving support
- (void)saveContext {
    
    NSManagedObjectContext *managedObjectContext = self.coreDataHelper.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([self.navigationController isKindOfClass:[GAHRootNavigationController class]])
    {
        if ([[url host] isEqualToString:@"showMapLocation"])
        {
            GAHRootNavigationController *rootNavigationController = (GAHRootNavigationController *)self.navigationController;
            [rootNavigationController openMapLocationFromURL:url];
        }
        else
        {
            DLog(@"\nno showMapLocation found");
        }
    }
    else
    {
        DLog(@"\nnavigation controller is nil or not a GAHRootNav");

    }
    
    return true;
}

@end


@implementation AppDelegate (RemoteNotificationRegistration)

#pragma mark - Remote Notification Registration
- (void)registerForRemoteNotifications
{
#ifdef DEBUG
    NSString *deviceToken = [self.userDefaults objectForKey:MTP_APNSDeviceToken];
    NSLog(@"deviceToken %@",deviceToken);
#else
    if ([[[UIDevice currentDevice] systemVersion] compare:@"8.0"] == NSOrderedAscending) {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeBadge)];
    } else {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
#endif
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSLog(@"%s [%s]: Line %i]\nMy token is %@",__FILE__,__PRETTY_FUNCTION__,__LINE__,deviceToken);
    [[NSUserDefaults standardUserDefaults] setValue:deviceToken forKey:MTP_APNSDeviceToken];
    
//    NSDictionary *parameters = @{@"device_token":[NSString stringWithFormat:@"%@",deviceToken]};
//    [self.notificationHandler uploadDeviceToken:parameters];
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"%s [%s]: Line %i]\nFailed to get token, error: %@",__FILE__,__PRETTY_FUNCTION__,__LINE__,error);
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
    if (userInfo)
    {
        [self.notificationHandler processUserInfo:userInfo];
    }
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    if (notification.userInfo)
    {
        [self.notificationHandler processUserInfo:notification.userInfo];
    }
}

@end