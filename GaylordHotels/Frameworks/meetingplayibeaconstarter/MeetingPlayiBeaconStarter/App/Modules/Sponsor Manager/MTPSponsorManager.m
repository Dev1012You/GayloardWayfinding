//
//  MTPSponsorManager.m
//  MeetingPlayiBeaconStarter
//
//  Created by John Pacheco on 4/7/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "MTPSponsorManager.h"
#import "Sponsor+Helpers.h"
#import "User+Helpers.h"
//#import "MTPAPIAddresses.h"
#import "NSString+MTPAPIAddresses.h"
#import "EventKeys.h"
#import "NSObject+EventDefaultsHelpers.h"
#import "MTPAppSettingsKeys.h"

@interface MTPSponsorManager()
@property (nonatomic, strong) User *currentUser;
@end

@implementation MTPSponsorManager

- (instancetype)initManagedObjectContext:(NSManagedObjectContext *)rootSponsorContext
{
    self = [super init];
    
    if (self) {
        _allSponsors = [NSMutableSet new];
        _rootSponsorContext = rootSponsorContext;
        _sponsorScratchContext = rootSponsorContext;
        _currentUser = [User currentUser:_sponsorScratchContext];
        [_allSponsors addObjectsFromArray:[rootSponsorContext executeFetchRequest:[NSFetchRequest fetchRequestWithEntityName:@"Sponsor"] error:nil]];
    }
    
    return self;
}

- (NSManagedObjectContext *)sponsorScratchContext
{
    if (_sponsorScratchContext) {
        return _sponsorScratchContext;
    }
    
    NSParameterAssert(_rootSponsorContext != nil);
    
    _sponsorScratchContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    _sponsorScratchContext.parentContext = _rootSponsorContext;
    
    return _sponsorScratchContext;
}

- (NSArray *)processRemoteSponsorData:(NSArray *)sponsorAPIData
{
    NSMutableSet *existingSponsors = [NSMutableSet setWithArray:[self findAll:self.sponsorScratchContext]];
    NSLog(@"existing sponsors %@",@(existingSponsors.count));
    
    NSMutableArray *processedSponsorObjects = [NSMutableArray new];
    for (NSDictionary *sponsorDictionary in sponsorAPIData) {
        if ([sponsorDictionary objectForKey:@"sponsor_id"]) {
            NSNumber *sponsorID = [sponsorDictionary objectForKey:@"sponsor_id"];
            Sponsor *sponsor = [self getSponsor:sponsorID];
            if (!sponsor) {
                sponsor = [NSEntityDescription insertNewObjectForEntityForName:@"Sponsor"
                                                        inManagedObjectContext:self.sponsorScratchContext];
                [self addSponsor:sponsor];
            }
            [Sponsor populateSponsor:sponsor withJSON:sponsorDictionary];
            [processedSponsorObjects addObject:sponsor];
        }
    }
    [self.sponsorScratchContext save:nil];
    return processedSponsorObjects;
}

- (void)receiveAPIConnectedSponsors:(NSArray *)sponsorAPIData {
    
    NSArray *connectedSponsors = [self processRemoteSponsorData:sponsorAPIData];
    for (Sponsor *sponsor in connectedSponsors) {
        sponsor.connectionStatus = kMyConnectionConnected;
    }
    [self save];
    
}

- (void)addSponsor:(Sponsor *)sponsor {
    if (sponsor)
    {
        [self.allSponsors addObject:sponsor];
    }
}

- (Sponsor*)getSponsor:(NSNumber *)sponsorID {
        NSArray *allSponsors = [self.allSponsors allObjects];
//    NSArray *allSponsors = [self findAll:self.sponsorScratchContext];
    Sponsor *matchingSponsor = nil;
    
    for (Sponsor *sponsor in allSponsors)
    {
        if ([sponsor.sponsor_id isEqualToNumber:sponsorID]) {
            matchingSponsor = sponsor;
        }
    }
    return matchingSponsor;
}

- (NSArray *)connectedSponsors {
    NSArray *connectedSponsors = [NSArray array];
    NSArray *allSponsors = [self findAll:self.sponsorScratchContext];
    for (Sponsor *sponsor in allSponsors)
    {
        if ([sponsor.connectionStatus isEqualToString:kMyConnectionConnected] ||
            [sponsor.connectionStatus isEqualToString:kMyConnectionPending])
        {
            connectedSponsors = [connectedSponsors arrayByAddingObject:sponsor];
        }
    }
    return connectedSponsors;
}

- (void)nearbySponsors:(void (^)(NSArray *fetchedSponsors))completionHandler {
    [self fetchNearbySponsors:^(NSArray *nearbySponsors) {
        if (completionHandler) {
            completionHandler(nearbySponsors);
        }
    }];
}

- (NSString*)connectionStatus:(NSNumber*)sponsorID {
    NSString *connectionStatus = nil;
    
    if (sponsorID) {
        Sponsor *matchingSponsor = [self getSponsor:sponsorID];
        if (matchingSponsor) {
            connectionStatus = matchingSponsor.connectionStatus;
        }
        else
        {
            connectionStatus = kMyConnectionNotConnected;
        }
    } else {
        connectionStatus = kMyConnectionConnected;
    }
    return connectionStatus;
}

- (void)updateSponsor:(Sponsor*)sponsor connectionStatus:(NSString*)newConnectionStatus {
    sponsor.connectionStatus = newConnectionStatus;
}

- (void)fetchConnectedSponsors:(void (^)())completionHandler {
    if (self.currentUser.user_id == nil) {
        NSAssert(self.currentUser.user_id == nil, @"Local User ID should not be nil");
        return;
    }
    
    NSString *fetchSponsorsURL = [NSString stringWithFormat:[NSString userSponsorsGet],self.currentUser.user_id];
    
    __weak __typeof(&*self)weakSelf = self;
    [self sendAPIRequest:fetchSponsorsURL success:^(NSData *data, NSURLResponse *response) {
        NSDictionary *connectedSponsors = [weakSelf serializeData:data response:response];
        [weakSelf resetConnections];
        if (connectedSponsors) {
            NSArray *allSponsors = [[connectedSponsors objectForKey:@"data"] objectForKey:@"users"];
            [weakSelf receiveAPIConnectedSponsors:allSponsors];
        }
        if (completionHandler) {
            completionHandler();
        }
    }];
}

- (void)fetchNearbySponsors:(void (^)(NSArray *nearbySponsors))completionHandler {
    NSString *fetchNearbySponsorsURL = [NSString stringWithFormat:[NSString userSponsorsNearby],self.currentUser.user_id];
    
    __weak __typeof(&*self)weakSelf = self;
    [self sendAPIRequest:fetchNearbySponsorsURL success:^(NSData *data, NSURLResponse *response) {
        NSDictionary *serializedSponsors = [weakSelf serializeData:data response:response];
        NSArray *nearbySponsors = [weakSelf processRemoteSponsorData:[[serializedSponsors objectForKey:@"data"] objectForKey:@"sponsors"]];
        if (completionHandler) {
            completionHandler(nearbySponsors);
        }
    }];
}

- (void)fetchAllSponsors:(void(^)(NSArray *allSponsors))completionHandler {
    NSString *fetchAllSponsorsURL = [NSString sponsorsAll];
    
    __weak __typeof(&*self)weakSelf = self;
    [self sendAPIRequest:fetchAllSponsorsURL success:^(NSData *data, NSURLResponse *response) {
        NSDictionary *serializedSponsors = [weakSelf serializeData:data response:response];
        [weakSelf processRemoteSponsorData:[[serializedSponsors objectForKey:@"data"] objectForKey:@"sponsors"]];
        if (completionHandler) {
            completionHandler(weakSelf.allSponsors.allObjects);
        }
    }];
}

- (void)sendAPIRequest:(NSString *)apiURL success:(void(^)(NSData *data,NSURLResponse *response))successHandler {
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:apiURL]];
    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest setAllHTTPHeaderFields:@{@"Content-Type":@"application/json",
                                         @"X-Authentication-Token":[[self.userDefaults objectForKey:MTP_NetworkOptions] objectForKey:MTP_XAuthToken]}];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
//            DLog(@"\nrequest error %@\nresponse %@\nrequest %@", error.localizedDescription,response,urlRequest);
            NSLog(@"\nrequest error %@\nresponse %@\nrequest %@", error.localizedDescription,response,urlRequest);
        } else {
            if (successHandler) {
                successHandler(data,response);
            }
        }
    }] resume];
}

- (NSDictionary *)serializeData:(NSData *)remoteData response:(NSURLResponse *)response {
    NSError *serializationError;
    id responseObject = [NSJSONSerialization JSONObjectWithData:remoteData
                                                        options:NSJSONReadingAllowFragments
                                                          error:&serializationError];
    if (serializationError) {
//        DLog(@"\nserialization of all sponsors request error: %@\n response %@", serializationError.localizedDescription,response);
        NSLog(@"\nserialization of all sponsors request error: %@\n response %@", serializationError.localizedDescription,response);
        return nil;
    }
    
    if ([responseObject isKindOfClass:[NSDictionary class]] == false) {
//        DLog(@"\nNot a Dictionary");
        NSLog(@"\nNot a Dictionary");
        return nil;
    }
    
    NSArray *allKeys = [responseObject allKeys];
    if ([allKeys containsObject:@"data"] == false) {
//        DLog(@"\ndoesnt contain data key");
        NSLog(@"\ndoesnt contain data key");
        return nil;
    }
    
    return responseObject;
}

- (void)resetConnections {
    NSArray *allSponsors = [self findAll:self.sponsorScratchContext];
    for (Sponsor *sponsor in allSponsors) {
        sponsor.connectionStatus = kMyConnectionNotConnected;
    }
}

- (void)save {
    __block NSError *saveError = nil;
    [self.sponsorScratchContext performBlockAndWait:^{
        if (![self.sponsorScratchContext save:&saveError]) {
            NSLog(@"%s [%s]: Line %i]\n"
                  "%@",
                  __FILE__,__PRETTY_FUNCTION__,__LINE__,
                  saveError);
        }
    }];
}

- (NSArray *)findAll:(NSManagedObjectContext *)managedObjectContext
{
    NSFetchRequest *allSponsorsFetch = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([Sponsor class])];
    [allSponsorsFetch setPredicate:[NSPredicate predicateWithFormat:@"%K != nil",@"sponsor_id"]];
    
    NSArray *results;
    NSError *fetchError = nil;
    
    results = [managedObjectContext executeFetchRequest:allSponsorsFetch error:&fetchError];
    if (!results) {
        if (fetchError) {
            NSLog(@"%s [%s]: Line %i]\n%@",
                  __FILE__,__PRETTY_FUNCTION__,__LINE__,
                  fetchError);
        }
    }
    return results;
}

@end
