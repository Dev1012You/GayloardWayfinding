//
//  AppDelegate.m
//  MeetingPlayiBeaconStarter
//
//  Created by Michael Thongvanh on 4/3/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import "AppDelegate.h"
#import "MTPCustomRootNavigationViewController.h"
// Managers
#import "MTPCoreDataInitializationHelper.h"
#import "MTPApplicationDefaultsManager.h"
#import "MTPRemoteNotificationHandler.h"
#import "MTPAlertManager.h"

#import "MTPAPIDataInitializer.h"
#import "MTPGimbalInitializer.h"

#import "NSObject+EventDefaultsHelpers.h"

// Services
#import <Gimbal/Gimbal.h>

@interface AppDelegate ()
@property (nonatomic, strong) MTPCustomRootNavigationViewController *navigationController;
@property (nonatomic, strong) MTPCoreDataInitializationHelper *coreDataHelper;
@property (nonatomic, strong) MTPApplicationDefaultsManager *defaultsManager;
@property (nonatomic, strong) MTPRemoteNotificationHandler *notificationHandler;
@property (nonatomic, strong) MTPAPIDataInitializer *apiInitializer;
@property (nonatomic, strong) MTPGimbalInitializer *gimbalInitializer;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.navigationController = (MTPCustomRootNavigationViewController *)self.window.rootViewController;

    self.coreDataHelper = [[MTPCoreDataInitializationHelper alloc]
                           initWithManagedObjectModelName:@"MeetingPlayiBeaconStarter"
                           sqliteStoreName:@"MeetingPlayiBeaconStarter"];
    
    self.defaultsManager = [MTPApplicationDefaultsManager defaultsManager:self];
    [Gimbal setAPIKey:[self.defaultsManager.userDefaults objectForKey:MTP_GimbalAPIKey] options:nil];
    self.gimbalInitializer = [MTPGimbalInitializer new];
    self.navigationController.beaconSightingManager = self.gimbalInitializer.beaconSightingManager;

    self.apiInitializer = [MTPAPIDataInitializer dataInitializer:self.coreDataHelper.managedObjectContext];
    [self.apiInitializer fetchInitialAPIData];
    // navigation controller needs the session manager that was initialized in the API Initializer
    self.navigationController.sessionManager = self.apiInitializer.sessionManager;
    // alert manager will use the navigation controllers session manager that was initialized in
    // the api initializer to show session details
    self.navigationController.alertManager = [MTPAlertManager alertManager:self.navigationController];
    
    self.notificationHandler = [MTPRemoteNotificationHandler notificationHandler:self
                                                        rootNavigationController:self.navigationController];
    [self registerForRemoteNotifications];
    
    self.navigationController.rootSavingManagedObjectContext = [self.coreDataHelper managedObjectContext];
    self.navigationController.sponsorManager = self.apiInitializer.sponsorManager;
    
    [self.notificationHandler launchWithOptions:launchOptions];
    
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

@end

@implementation AppDelegate (RemoteNotificationRegistration)

#pragma mark - Remote Notification Registration
- (void)registerForRemoteNotifications
{
#ifdef DEBUG
    // NSLog(@"\ndont register device");
#else
    if ([[[UIDevice currentDevice] systemVersion] compare:@"8.0"] == NSOrderedAscending) {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeBadge)];
    } else {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
#endif
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSLog(@"%s [%s]: Line %i]\nMy token is %@",__FILE__,__PRETTY_FUNCTION__,__LINE__,deviceToken);
    [[NSUserDefaults standardUserDefaults] setValue:deviceToken forKey:MTP_APNSDeviceToken];
    
    NSDictionary *parameters = @{@"device_token":[NSString stringWithFormat:@"%@",deviceToken]};
    [self.notificationHandler uploadDeviceToken:parameters];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error {
    NSLog(@"%s [%s]: Line %i]\nFailed to get token, error: %@",__FILE__,__PRETTY_FUNCTION__,__LINE__,error);
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo {
    if (userInfo) {
        [self.notificationHandler processUserInfo:userInfo];
    }
}

@end
