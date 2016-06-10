//
//  MTPRemoteNotificationHandler.m
//  MeetingPlayiBeaconStarter
//
//  Created by John Pacheco on 4/3/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "MTPRemoteNotificationHandler.h"
#import "MTPCustomRootNavigationViewController.h"
#import "AppDelegate.h"
#import "SIAlertView.h"
#import "User+Helpers.h"
//#import "MTPAPIAddresses.h"
#import "NSString+MTPAPIAddresses.h"
#import "NSURLSession+MTPCategory.h"
#import "MTPAppSettingsKeys.h"

#import "GAHCouponView.h"
#import "GAHPromotionNetworkController.h"
#import "GAHPromotion.h"

@implementation MTPRemoteNotificationHandler

+ (instancetype)notificationHandler:(AppDelegate *)appDelegate
           rootNavigationController:(MTPCustomRootNavigationViewController *)rootNavigationController
{
    return [[MTPRemoteNotificationHandler alloc] initWithAppDelegate:appDelegate
                                            rootNavigationController:rootNavigationController];
}

- (instancetype)initWithAppDelegate:(AppDelegate *)appDelegate
           rootNavigationController:(MTPCustomRootNavigationViewController *)rootNavigationController
{
    self = [super init];
    if (self) {
        _appDelegate = appDelegate;
        _rootNavigationController = rootNavigationController;
        [self registerForNotifications];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registerDeviceID:) name:MTP_LoginNotification object:nil];
}

- (void)registerDeviceID:(NSNotification *)notification
{
    NSNumber *userID = [[notification userInfo] objectForKey:@"user_id"];
    NSString *deviceToken = [self.userDefaults objectForKey:MTP_APNSDeviceToken];
    
    if (userID && deviceToken)
    {
        NSDictionary *parameters = @{@"device_token":[NSString stringWithFormat:@"%@",deviceToken]};
        [self uploadDeviceToken:parameters userID:userID];
    }
}

- (void)launchWithOptions:(NSDictionary *)launchOptions
{
    NSDictionary *remoteNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (remoteNotification)
    {
        [self processNotification:remoteNotification];
    }
}

- (void)processNotification:(NSDictionary *)remoteNotification
{
    NSLog(@"%s [%s]: Line %i]\n"
          "%@",
          __FILE__,__PRETTY_FUNCTION__,__LINE__,
          remoteNotification);
    [self processUserInfo:remoteNotification];
}

- (void)processUserInfo:(NSDictionary*)userInfo
{
    NSLog(@"\n%s - line %d: userInfo %@",__PRETTY_FUNCTION__, __LINE__, userInfo);
    
    NSString *typeOfCommunication = [userInfo objectForKey:@"type"];
    if ([typeOfCommunication isEqualToString:@"connection"])
    {
//        [self processUserConnection:userInfo];
    }
    else if ([typeOfCommunication isEqualToString:@"notification"])
    {
        [self showAlert:userInfo];
    }
    else if ([typeOfCommunication isEqualToString:@"poll"])
    {
        [self loadPoll:userInfo ];
    }
    else if ([typeOfCommunication caseInsensitiveCompare:@"promotion"] == NSOrderedSame)
    {
        [self handleCoupon:userInfo];
    }
    else {
        [self showAlert:userInfo];
    }
}

- (void)handleCoupon:(NSDictionary *)userInfo
{
    NSString *promotionID = [userInfo objectForKey:@"promotionID"];
    if (promotionID.length > 0)
    {
//        NSMutableArray *receivedCoupons = [[NSUserDefaults standardUserDefaults] objectForKey:@"userPromotions"];
        
//        NSString *promoURL = [userInfo objectForKey:@"promotionURL"];
//        [GAHCouponView loadInView:self.rootNavigationController.topViewController.view urlRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:promoURL]] delegate:nil];
        
        // fetch promotion using promotionID
        GAHPromotionNetworkController *promotionFetcher = [GAHPromotionNetworkController new];
        [promotionFetcher fetchPromotion:promotionID successHandler:^(id promotionDetails) {
            // present promotion
            if ([promotionDetails isKindOfClass:[NSDictionary class]])
            {
                NSDictionary *promotion = [promotionDetails objectForKey:@"data"];
                NSString *promotionSlug = [promotion objectForKey:@"promotionID"];
                
                GAHPromotion *newPromotion;

                // get existing promotions from disk
                NSURL *promotionsSaveLocation = [GAHPromotion promotionsSavePath];
                NSMutableArray *receivedCoupons = [NSKeyedUnarchiver unarchiveObjectWithFile:[promotionsSaveLocation path]];
                if (receivedCoupons == nil)
                {
                    receivedCoupons = [NSMutableArray new];
                }
                // check if it already exists
                NSUInteger matchingPromotionIndex = [receivedCoupons indexOfObjectPassingTest:^BOOL(GAHPromotion * obj, NSUInteger idx, BOOL *stop) {
                    
                    if ([obj.promotionSlug caseInsensitiveCompare:promotionSlug] == NSOrderedSame)
                    {
                        *stop = true;
                        return true;
                    }
                    else
                    {
                        return false;
                    }
                }];
                
                if (matchingPromotionIndex == NSNotFound)
                {
                    newPromotion = [GAHPromotion promotionWithDictionary:promotion];
                    [receivedCoupons addObject:newPromotion];
                }
                else
                {
                    newPromotion = [receivedCoupons objectAtIndex:matchingPromotionIndex];
                    [newPromotion update:promotion];
                }
                
                if (newPromotion)
                {
                    if (promotionsSaveLocation && receivedCoupons)
                    {
                        if (![NSKeyedArchiver archiveRootObject:receivedCoupons toFile:[promotionsSaveLocation path]])
                        {
                            DLog(@"\nsave failed %@", receivedCoupons);
                        }
                    }

                    NSString *promoURL = newPromotion.details;
                    if (promoURL.length > 0)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            // added to main_queue in order to avoid this crash:
                            // bool _WebTryThreadLock(bool), 0x170206790: Tried to obtain the web lock from a thread other than the main thread or the web thread. This may be a result of calling to UIKit from a secondary thread. Crashing now...
                            NSURLRequest *couponRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:promoURL] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
                            [GAHCouponView loadInView:self.rootNavigationController.topViewController.view urlRequest:couponRequest delegate:nil];
                        });
                    }
                }
            }
            else
            {
                DLog(@"incorrect class for returned promotion: not a dictionary");
            }
        } failureHandler:^(NSURLResponse *response, NSError *networkError) {
            DLog(@"%@",networkError);
        }];
    }
}

- (void)showAlert:(NSDictionary *)userInfo
{
    NSString *title = [[userInfo objectForKey:@"custom"] objectForKey:@"title"];
    if (title.length > 0)
    {
        title = [[userInfo objectForKey:@"custom"] objectForKey:@"title"];
    }
    else
    {
        title = @"Conference Alert";
    }
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:title
                                                     andMessage:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]];
    
    [alertView addButtonWithTitle:@"OK"
                             type:SIAlertViewButtonTypeCancel
                          handler:nil];
    
    [alertView show];
}

- (void)loadPoll:(NSDictionary*)userInfo
{
    NSLog(@"\n%s - line %d",__PRETTY_FUNCTION__, __LINE__);
    if (![[userInfo allKeys] containsObject:@"target"])
    {
        NSLog(@"\n%s - line %d: doesn't contain target",__PRETTY_FUNCTION__, __LINE__);
        return;
    }
    
    if ([[userInfo objectForKey:@"target"] isEqualToString:@"app"])
    {
        if ([self.userDefaults boolForKey:kLoggedIn] == false)
        {
            NSLog(@"\n%s - line %d - not logged in",__PRETTY_FUNCTION__, __LINE__);
            return;
        }
        
        NSURL *pollURL = [NSURL URLWithString:[userInfo objectForKey:@"url"]];
        [self.rootNavigationController openPoll:pollURL realTimePoll:@(true)];
    }
    else
    {
        NSLog(@"\n%s - line %d",__PRETTY_FUNCTION__, __LINE__);
        NSURL *url = [NSURL URLWithString:[userInfo objectForKey:@"url"]];
        [self.appDelegate application:[UIApplication sharedApplication] openURL:url sourceApplication:nil annotation:nil];
    }
}

#pragma mark - API Service
- (void)uploadDeviceToken:(NSDictionary *)parameters
{
    [self uploadDeviceToken:parameters userID:nil];
}

- (void)uploadDeviceToken:(NSDictionary *)parameters userID:(NSNumber *)userID
{
    NSNumber *loggedInUserID;
    if (self.rootNavigationController.currentUser.user_id)
    {
        loggedInUserID = self.rootNavigationController.currentUser.user_id;
    }
    else
    {
        loggedInUserID = userID;
    }
#ifdef DEBUG
    NSLog(@"dont upload device token");
#else
//    NSLog(@"%s\n[%s]: Line %i] %@",__FILE__,__PRETTY_FUNCTION__,__LINE__,
//          @"got here");
    if (loggedInUserID)
    {
        NSString *deviceTokenUploadURLString = [NSString stringWithFormat:[NSString userDevice],loggedInUserID];
        
        NSMutableURLRequest *deviceTokenUploadRequest = [NSURLSession defaultRequestMethod:@"PUT"
                                                                                       URL:deviceTokenUploadURLString
                                                                                parameters:parameters];
        
        [[[NSURLSession sharedSession] dataTaskWithRequest:deviceTokenUploadRequest
                                         completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
          {
              id responseObject = [NSURLSession serializeJSONData:data response:response error:error];
              NSLog(@"\ndevice token upload response %@", responseObject);
          }] resume];
    }
#endif
}

@end
