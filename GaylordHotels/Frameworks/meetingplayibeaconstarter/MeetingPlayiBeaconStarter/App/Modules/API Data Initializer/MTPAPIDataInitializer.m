//
//  MTPAPIDataInitializer.m
//  MeetingPlayiBeaconStarter
//
//  Created by John Pacheco on 4/7/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "MTPAPIDataInitializer.h"
#import "MTAPIClient.h"
//#import "MTPAPIAddresses.h"
#import "NSString+MTPAPIAddresses.h"

#import "User+Helpers.h"
#import "NSManagedObject+Helpers.h"
#import "MDMyConnectionManager.h"
#import "MDBeaconManager.h"

#import "MTPSession.h"
#import "MTPSessionManager.h"

#import "Sponsor+Helpers.h"
#import "MTPSponsorManager.h" 

#import "NSObject+EventDefaultsHelpers.h"
#import "EventKeys.h"
#import "MTPAppSettingsKeys.h"

#import <CoreData/CoreData.h>

@interface MTPAPIDataInitializer ()
@property (nonatomic, strong) NSManagedObjectContext *scratchContext;
@property (nonatomic, strong) NSTimer *sessionUpdateTimer;
@end

@implementation MTPAPIDataInitializer

+ (instancetype)dataInitializer:(NSManagedObjectContext *)rootObjectContext
{
    return [[MTPAPIDataInitializer alloc] init:rootObjectContext];
}

- (instancetype)init:(NSManagedObjectContext *)managedObjectContext
{
    self = [super init];
    if (self) {
        _sessionManager = [[MTPSessionManager alloc] init];
        _beaconManager = [[MDBeaconManager alloc] init];
        _beaconManager.sessionManager = _sessionManager;
        _rootObjectContext = managedObjectContext;
        _scratchContext = _rootObjectContext;
        _sponsorManager = [[MTPSponsorManager alloc] initManagedObjectContext:_rootObjectContext];
        _myConnectionManager = [MDMyConnectionManager connectionManager:_rootObjectContext];
    }
    
    return self;
}

- (void)dealloc
{
    [self.sessionUpdateTimer invalidate];
}

- (void)fetchInitialAPIData
{
    [self fetchDrawingTypes];
    
    [self fetchAllUsers];
//    [self fetchAllSponsors];
    [self fetchAllSessions];
//    [self fetchAllBeacons];
    
    [[NSRunLoop currentRunLoop] addTimer:self.sessionUpdateTimer forMode:NSRunLoopCommonModes];
    [self.sessionUpdateTimer fire];
}

- (NSManagedObjectContext *)createScratchContext:(NSManagedObjectContext *)rootContext
{
    NSManagedObjectContext *scratchContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    scratchContext.parentContext = rootContext;
    
    return scratchContext;
}

- (void)fetchDrawingTypes
{
    if ([[self.userDefaults objectForKey:MTP_EventConnectionGame] boolValue])
    {
        NSArray *drawingTypes = [[NSUserDefaults standardUserDefaults] objectForKey:kDrawingTypesUserDefaultsKey];
        if (drawingTypes.count > 0) {
            return;
        }
        [[MTAPIClient sharedClient] GET:[NSString drawingTypes] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            id allDrawingTypes = [responseObject objectForKey:@"data"];
            
            if (allDrawingTypes && [allDrawingTypes isKindOfClass:[NSArray class]]) {
                [[NSUserDefaults standardUserDefaults] setObject:allDrawingTypes forKey:kDrawingTypesUserDefaultsKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
            } else {
                DLog(@"\nDrawing types or type of data failed\n%@", allDrawingTypes);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DLog(@"\nError occurred %ld: %@", error.code, error.localizedDescription);
        }];
    }
    else
    {
        DLog(@"\nConnection game is disabled");
    }
}

- (void)fetchAllUsers
{
    __weak __typeof(&*self)weakSelf = self;
    [self sendAPI:[NSString userCollection] completionHandler:^(NSData *data, NSDictionary *responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSArray *allUsers = [NSArray array];
            allUsers = [User createUsers:[responseObject objectForKey:@"data"] context:weakSelf.rootObjectContext];
            NSString *responsePhotoUrl = [[responseObject objectForKey:@"info"] objectForKey:kResponsePhotoUrl];
            [[NSUserDefaults standardUserDefaults] setObject:responsePhotoUrl forKey:kProfileImageUrl];
            
            if (allUsers) {
                DLog(@"\nsuccessful allUsers processing");
                [User saveToPersistentStore:weakSelf.rootObjectContext];
            }
        } else {
            DLog(@"\ninvalid type: missing dictionary keys");
        }
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:kFetchUsersUpdate];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }];
}

- (void)fetchAllSponsors
{
    __weak __typeof(&*self)weakSelf = self;
    [self sendAPI:[NSString sponsorsAll] completionHandler:^(NSData *data, NSDictionary *responseObject) {
        NSArray *allSponsors = [[responseObject objectForKey:@"data"] objectForKey:@"sponsors"];
        if ([weakSelf.sponsorManager processRemoteSponsorData:allSponsors]) {
            NSLog(@"Successfully processed Sponsors");
        }
        NSString *sponsorProfileUrl = [[responseObject objectForKey:@"data"] objectForKey:@"logo"];
        [[NSUserDefaults standardUserDefaults] setObject:sponsorProfileUrl forKey:kSponsorLogoUrl];
    }];
}

- (void)fetchAllSessions
{
    __weak __typeof(&*self)weakSelf = self;
    
    NSError *sessionRequestSerializationError = nil;
    NSMutableURLRequest *sessionRequest = [[[MTAPIClient sharedClient] requestSerializer] requestWithMethod:@"GET" URLString:[NSString sessionsAll] parameters:nil error:&sessionRequestSerializationError];
    if (sessionRequestSerializationError)
    {
        NSLog(@"%s\n[%s]: Line %i] Session Serialization Error %@",__FILE__,__PRETTY_FUNCTION__,__LINE__,
              sessionRequestSerializationError);
    }
    else
    {
        sessionRequest.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        AFHTTPRequestOperation *operation = [[MTAPIClient sharedClient] HTTPRequestOperationWithRequest:sessionRequest success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSArray *allSessions = [[responseObject objectForKey:@"data"] objectForKey:@"sessions"];
            [allSessions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
             {
                 MTPSession *session = [[MTPSession alloc] init];
                 [session fillValuesFromResponseObject:obj];
                 [weakSelf.sessionManager addSession:session];
             }];
            [weakSelf fetchSessionBeacons];
            [weakSelf.userDefaults setObject:[NSDate date]
                                      forKey:kLastSessionUpdate];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DLog(@"\nfailed");
        }];
        
        [[[MTAPIClient sharedClient] operationQueue] addOperation:operation];
    }
}

- (void)fetchSessionBeacons {
    /*
     [[MTAPIClient sharedClient] GET:SESSIONS_BEACONS parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
     NSArray *allSessions = [[responseObject objectForKey:@"data"] objectForKey:@"sessions"];
     [allSessions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
     MDSSession *session = [[MDSessionManager sharedManager] getSession:[obj objectForKey:@"session_id"]];
     session.beaconId = [obj objectForKey:@"beacon_id"];
     }];
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
     DLog(@"\nfailed");
     }];
     */
}

- (void)fetchConnected
{
    [self.sponsorManager fetchConnectedSponsors:nil];
    [self.myConnectionManager updateConnectionsFromApi];
}

- (void)sendAPI:(NSString *)apiRequestURL completionHandler:(void (^)(NSData *data, NSDictionary *responseObject))completionHandler {
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:apiRequestURL]];
    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest setAllHTTPHeaderFields:@{@"accept": @"application/json",
                                         @"X-Authentication-Token": [[self.userDefaults objectForKey:MTP_NetworkOptions] objectForKey:MTP_XAuthToken]}];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            DLog(@"\nrequest error %@\nresponse %@\nrequest %@", error.localizedDescription,response,urlRequest);
        } else {
            NSError *serializationError;
            id responseObject = [NSJSONSerialization JSONObjectWithData:data
                                                                options:NSJSONReadingAllowFragments
                                                                  error:&serializationError];
            if (serializationError) {
                DLog(@"\nserialization of all sponsors request error: %@\n response %@\nrequest %@", serializationError.localizedDescription,response,urlRequest);
                return;
            }
            
            if ([responseObject isKindOfClass:[NSDictionary class]] == false) {
                DLog(@"\nNot a Dictionary");
                return;
            }
            
            NSArray *allKeys = [responseObject allKeys];
            if ([allKeys containsObject:@"data"] == false) {
                DLog(@"\ndoesnt contain data key");
                return;
            }
            
            if (completionHandler) {
                completionHandler(data,responseObject);
            }
        }
    }] resume];
}

- (void)updateSessionInformation
{
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
    {
        NSDate *lastSessionUpdate = [self.userDefaults objectForKey:kLastSessionUpdate];
        if (!lastSessionUpdate) {
            lastSessionUpdate = [NSDate date];
            [self.userDefaults setObject:lastSessionUpdate forKey:kLastSessionUpdate];
        }
        NSTimeInterval thirtyMinutes = 30 * 60;
        
        NSTimeInterval lastUpdateTimeInterval = [[NSDate date] timeIntervalSinceDate:lastSessionUpdate];
        if (lastUpdateTimeInterval > thirtyMinutes)
        {
            [self fetchAllSessions];
#ifdef DEBUG
            UILocalNotification *localNotification = [[UILocalNotification alloc] init];
            localNotification.alertBody = [NSString stringWithFormat:@"Refreshed session information on %@",[NSDate date]];
            [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
#endif
        }
    }
}

- (NSTimer *)sessionUpdateTimer
{
    if (!_sessionUpdateTimer)
    {
        _sessionUpdateTimer = [NSTimer timerWithTimeInterval:(20 * 60)
                                                      target:self
                                                    selector:@selector(updateSessionInformation)
                                                    userInfo:nil
                                                     repeats:true];
        if ([_sessionUpdateTimer respondsToSelector:@selector(tolerance)])
        {
            [_sessionUpdateTimer setTolerance:10];
        }
    }
    
    return _sessionUpdateTimer;
}

@end
