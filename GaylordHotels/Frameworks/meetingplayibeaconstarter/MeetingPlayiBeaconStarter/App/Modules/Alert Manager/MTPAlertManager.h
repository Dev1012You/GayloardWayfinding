//
//  MTPAlertManager.h
//  MeetingPlayiBeaconStarter
//
//  Created by John Pacheco on 4/9/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTPSessionManager.h"
#import "MTPSession.h"
#import "SIAlertView.h"
#import "EventKeys.h"

@class MTPCustomRootNavigationViewController;

@protocol MTPAlertDelegate <NSObject>
@required
- (void)openPoll:(NSURL *)destinationUrl
   realTimePoll:(NSNumber *)realTimePoll;
- (void)openSessionDetails:(NSString *)scheduleID;
@end

@interface MTPAlertManager : NSObject

@property (nonatomic, weak) MTPCustomRootNavigationViewController *rootNavigationController;
@property (assign, nonatomic, getter = isShowingAlert) BOOL showingAlert;
@property (strong, nonatomic) UILocalNotification *localNotification;
@property (assign, nonatomic, getter = isShowingLocalNotification) BOOL showingLocalNotification;
@property (assign, nonatomic, getter = inBackgroundMode) BOOL backgroundMode;

+ (instancetype)alertManager:(MTPCustomRootNavigationViewController *)rootNavigationController;
- (instancetype)initWith:(MTPCustomRootNavigationViewController *)rootNavigationController NS_DESIGNATED_INITIALIZER;

- (void)showAlertForBeaconID:(NSString *)beaconID withContent:(NSDictionary *)content forEvent:(NSString *)eventType;

@end
