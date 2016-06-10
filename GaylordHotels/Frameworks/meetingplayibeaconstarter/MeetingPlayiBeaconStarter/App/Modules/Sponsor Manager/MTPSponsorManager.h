//
//  MTPSponsorManager.h
//  MeetingPlayiBeaconStarter
//
//  Created by John Pacheco on 4/7/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Sponsor;

@interface MTPSponsorManager : NSObject
//CoreData Handling
@property (nonatomic, strong) NSManagedObjectContext *rootSponsorContext;
@property (nonatomic, strong) NSManagedObjectContext *sponsorScratchContext;

@property (strong, nonatomic) NSMutableSet *allSponsors;

- (instancetype)initManagedObjectContext:(NSManagedObjectContext *)rootSponsorContext NS_DESIGNATED_INITIALIZER;

- (NSArray *)connectedSponsors;
- (void)nearbySponsors:(void (^)(NSArray *fetchedSponsors))completionHandler;
- (void)addSponsor:(Sponsor *)sponsor;
- (Sponsor *)getSponsor:(NSNumber *)sponsorID;
- (NSString *)connectionStatus:(NSNumber *)sponsorID;
- (void)updateSponsor:(Sponsor *)sponsor connectionStatus:(NSString *)newConnectionStatus;

- (void)save;

- (NSArray *)processRemoteSponsorData:(NSArray *)sponsorAPIData;
- (void)fetchConnectedSponsors:(void(^)())completionHandler;
- (void)fetchAllSponsors:(void(^)(NSArray *allSponsors))completionHandler;

@end