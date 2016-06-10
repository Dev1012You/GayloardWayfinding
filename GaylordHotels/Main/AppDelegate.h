//
//  AppDelegate.h
//  GaylordHotels
//
//  Created by John Pacheco on 4/27/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)saveContext;

@end

@interface AppDelegate (RemoteNotificationRegistration)

- (void)registerForRemoteNotifications;

@end