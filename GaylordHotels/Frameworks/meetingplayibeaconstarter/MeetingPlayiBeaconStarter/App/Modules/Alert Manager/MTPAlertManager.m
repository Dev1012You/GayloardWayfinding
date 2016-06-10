//
//  MTPAlertManager.m
//  MeetingPlayiBeaconStarter
//
//  Created by John Pacheco on 4/9/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "MTPAlertManager.h"
#import "MTPCustomRootNavigationViewController.h"

@implementation MTPAlertManager

#pragma mark - Initial Setup
+ (instancetype)alertManager:(MTPCustomRootNavigationViewController *)rootNavigationController
{
    return [[MTPAlertManager alloc] initWith:rootNavigationController];
}

- (instancetype)initWith:(MTPCustomRootNavigationViewController *)rootNavigationController
{
    self = [super init];
    if (self) {
        _rootNavigationController = rootNavigationController;
        [self registerForNotifications];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Methods
- (void)showAlertForBeaconID:(NSString *)beaconID
                 withContent:(NSDictionary *)content
                    forEvent:(NSString *)eventType
{
    if ([eventType isEqualToString:kEventTypePoll])
    {
        [self showPollAlert:content beacon:beaconID];
    }
    else if ([eventType isEqualToString:kEventTypeSession])
    {
        [self showSessionCheckInAlert:content beacon:beaconID];
    }
    else if ([eventType isEqualToString:kEventTypeSessionPoll])
    {
        [self showSessionPollAlert:content beacon:beaconID];
    }
    else
    {
        NSLog(@"%s [%s]: Line %i]\nEvent type unknown %@",
              __FILE__,__PRETTY_FUNCTION__,__LINE__,
              eventType);
    }
}

- (void)showPollAlert:(NSDictionary*)pollInformation
               beacon:(NSString*)beaconID
{
    // dictionary should have
    // title
    // url
    // endpoint
    
    NSString *alertTitle = [pollInformation objectForKey:@"title"];
    NSString *alertMessage = [NSString stringWithFormat:@"You've discovered a new poll. Hit \"Take Now\" to participate in the poll, or \"Take Later\" to save it to the poll zone."];
    NSNumber *realTimePoll = [pollInformation objectForKey:@"realTimePoll"] ? [pollInformation objectForKey:@"realTimePoll"] : nil;
    
    if (self.inBackgroundMode)
    {
        if (self.localNotification) {
            self.localNotification.alertBody = [NSString stringWithFormat:@"You've discovered a poll titled \"%@\"",alertTitle];
            self.localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
            [[UIApplication sharedApplication] scheduleLocalNotification:self.localNotification];
        }
    }
    else
    {
        NSString *targetURL = [pollInformation objectForKey:@"url"];;
        __weak __typeof(&*self)weakSelf = self;

        SIAlertView *alert = [[SIAlertView alloc] initWithTitle:alertTitle.capitalizedString
                                                     andMessage:alertMessage];
        [alert addButtonWithTitle:@"Take Later"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alertView)
        {
            [weakSelf resetManagerState];
        }];
        
        [alert addButtonWithTitle:@"Take Now"
                             type:SIAlertViewButtonTypeCancel
                          handler:^(SIAlertView *alertView)
        {
            if (weakSelf.rootNavigationController &&
                [weakSelf.rootNavigationController respondsToSelector:@selector(openPoll:realTimePoll:)])
            {
                [weakSelf.rootNavigationController openPoll:[NSURL URLWithString:targetURL]
                                               realTimePoll:realTimePoll];
            }
            [weakSelf resetManagerState];
        }];
        
        [alert show];
    }
}

- (void)showSessionCheckInAlert:(NSDictionary *)sessionInfo
                         beacon:(NSString *)beaconID
{
    NSLog(@"\n[%s] %s on line %d: session check-in dictionary %@", __FILE__,__PRETTY_FUNCTION__,__LINE__,sessionInfo);
    
    NSString *alertMessage = [NSString stringWithFormat:@"You've arrived at a session check-in. Hit \"Check Info\" to see the session's details."];
    
    NSString *sessionID = [[sessionInfo objectForKey:@"endpoint"] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/abcdefghijklmnopqrstuvwxyz"]];
    MTPSession *session = [self.rootNavigationController.sessionManager getSession:@(sessionID.integerValue)];
    
    if (self.inBackgroundMode)
    {
        if (self.localNotification) {
            self.localNotification.alertBody = [NSString stringWithFormat:@"You've discovered the session check-in \"%@\"",session.sessionTitle];
            self.localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
            [[UIApplication sharedApplication] scheduleLocalNotification:self.localNotification];
        }
    }
    else
    {
        NSLog(@"\n[%s] %s on line %d: session info %@", __FILE__,__PRETTY_FUNCTION__,__LINE__,sessionInfo);
        __weak __typeof(&*self)weakSelf = self;

        SIAlertView *alert = [[SIAlertView alloc] initWithTitle:session.sessionTitle.capitalizedString
                                                     andMessage:alertMessage];
        [alert addButtonWithTitle:@"Dismiss"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alertView)
        {
            [weakSelf resetManagerState];
        }];
        
        [alert addButtonWithTitle:@"Check Info"
                             type:SIAlertViewButtonTypeCancel
                          handler:^(SIAlertView *alertView)
        {
            if (weakSelf.rootNavigationController
                && [weakSelf.rootNavigationController respondsToSelector:@selector(openSessionDetails:)])
            {
                [weakSelf.rootNavigationController openSessionDetails:[NSString stringWithFormat:@"%@",
                                                                       session.schedule_id]];
                
                NSLog(@"\n[%s] %s on line %d: pressed check info %@",
                      __FILE__,__PRETTY_FUNCTION__,__LINE__,[NSString stringWithFormat:@"%@",session.schedule_id]);
            }
            [weakSelf resetManagerState];
        }];
        [alert show];
    }
}

- (void)showSessionPollAlert:(NSDictionary *)sessionPollDetails
                         beacon:(NSString *)beaconID
{
    DLog(@"\n[%s] %s on line %d: session check-in dictionary %@", __FILE__,__PRETTY_FUNCTION__,__LINE__,sessionPollDetails);
    
    NSString *alertMessage = [NSString stringWithFormat:@"You've discovered a poll. Hit \"Take Now\" to complete the poll, or \"Take Later\" to access it later."];
    
    if (self.inBackgroundMode)
    {
        if (self.localNotification) {
            NSString *pollTitle = [sessionPollDetails objectForKey:@"title"];
            if (pollTitle.length > 0)
            {
                self.localNotification.alertBody = [NSString stringWithFormat:@"You've discovered a poll titled \"%@\"!",pollTitle];
            }
            else
            {
                self.localNotification.alertBody = [NSString stringWithFormat:@"You've discovered a session poll!"];
            }
            self.localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
            [[UIApplication sharedApplication] scheduleLocalNotification:self.localNotification];
        }
    }
    else
    {
        DLog(@"\n[%s] %s on line %d: session info %@", __FILE__,__PRETTY_FUNCTION__,__LINE__,sessionPollDetails);
        __weak __typeof(&*self)weakSelf = self;
        
        SIAlertView *alert = [[SIAlertView alloc] initWithTitle:[[sessionPollDetails objectForKey:@"title"] capitalizedString]
                                                     andMessage:alertMessage];
        [alert addButtonWithTitle:@"Take Later"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alertView)
         {
             [weakSelf resetManagerState];
         }];
        
        [alert addButtonWithTitle:@"Take Now"
                             type:SIAlertViewButtonTypeCancel
                          handler:^(SIAlertView *alertView)
         {
             if (weakSelf.rootNavigationController
                 && [weakSelf.rootNavigationController respondsToSelector:@selector(openPoll:realTimePoll:)])
             {
                 [weakSelf.rootNavigationController openPoll:[NSURL URLWithString:[sessionPollDetails objectForKey:@"url"]] realTimePoll:@(0)];
                 
                 DLog(@"\n[%s] %s on line %d: pressed check info %@",
                       __FILE__,__PRETTY_FUNCTION__,__LINE__,[NSString stringWithFormat:@"%@",sessionPollDetails]);
             }
             [weakSelf resetManagerState];
         }];
        [alert show];
    }
}

- (void)resetManagerState
{
    self.showingAlert = NO;
}

- (UILocalNotification *)localNotification
{
    if (!_localNotification)
    {
        _localNotification = [[UILocalNotification alloc] init];
        _localNotification.alertBody = @"You've discovered a new check-in! Check your agenda to see the poll.";
    }
    return _localNotification;
}

#pragma mark - Protocol Conformance

#pragma mark - UINotifications
- (void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(returnFromBackground)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
}

- (void)didEnterBackground
{
    self.backgroundMode = YES;
    [self.userDefaults setBool:YES forKey:kBackgroundMode];
}

- (void)returnFromBackground
{
    self.backgroundMode = NO;
    [self.userDefaults setBool:NO forKey:kBackgroundMode];
}
@end
