//
//  MTPRemoteNotificationHandler.h
//  MeetingPlayiBeaconStarter
//
//  Created by John Pacheco on 4/3/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AppDelegate, MTPCustomRootNavigationViewController;

@interface MTPRemoteNotificationHandler : NSObject

@property (nonatomic, weak) AppDelegate *appDelegate;
@property (nonatomic, weak) MTPCustomRootNavigationViewController *rootNavigationController;

+ (instancetype)notificationHandler:(AppDelegate *)appDelegate
           rootNavigationController:(MTPCustomRootNavigationViewController *)rootNavigationController;
- (instancetype)initWithAppDelegate:(AppDelegate *)appDelegate
           rootNavigationController:(MTPCustomRootNavigationViewController *)rootNavigationController NS_DESIGNATED_INITIALIZER;

- (void)launchWithOptions:(NSDictionary *)launchOptions;
- (void)processUserInfo:(NSDictionary*)userInfo;

- (void)uploadDeviceToken:(NSDictionary *)parameters;
- (void)uploadDeviceToken:(NSDictionary *)parameters userID:(NSNumber *)userID;

@end
