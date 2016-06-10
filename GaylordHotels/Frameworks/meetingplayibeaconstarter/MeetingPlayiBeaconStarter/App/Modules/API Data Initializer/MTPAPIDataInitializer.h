//
//  MTPAPIDataInitializer.h
//  MeetingPlayiBeaconStarter
//
//  Created by John Pacheco on 4/7/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MDBeaconManager, MTPSessionManager, MTPSponsorManager, MDMyConnectionManager, NSManagedObjectContext;

@interface MTPAPIDataInitializer : NSObject
@property (nonatomic, strong) NSManagedObjectContext *rootObjectContext;
@property (nonatomic, strong) MDBeaconManager *beaconManager;
@property (nonatomic, strong) MTPSessionManager *sessionManager;
@property (nonatomic, strong) MTPSponsorManager *sponsorManager;
@property (nonatomic, strong) MDMyConnectionManager *myConnectionManager;

+ (instancetype)dataInitializer:(NSManagedObjectContext *)rootObjectContext;
- (void)fetchInitialAPIData;

- (void)fetchAllUsers;
- (void)fetchDrawingTypes;
- (void)fetchAllSponsors;
- (void)fetchAllSessions;
- (void)fetchConnected;

@end
