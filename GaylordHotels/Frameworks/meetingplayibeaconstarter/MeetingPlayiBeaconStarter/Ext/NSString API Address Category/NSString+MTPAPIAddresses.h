//
//  NSString+MTPAPIAddresses.h
//  MarriottTPC
//
//  Created by John Pacheco on 5/13/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MTPAPIAddresses)
+ (NSString *)apiBaseURL;
+ (NSString *)apiRelativePath;

+ (NSString *)loginURL;
+ (NSString *)logoutURL;
+ (NSString *)sessionsAll;
+ (NSString *)sessionsBeacons;
+ (NSString *)sessionPoll;

+ (NSString *)eventBeacons;
+ (NSString *)sponsorsAll;
+ (NSString *)drawingTypes;

//by user_id, get info
+ (NSString *)userInfo;
//for users, get all users and their info
+ (NSString *)userCollection;
//for user, post image
+ (NSString *)userImage;
//for user, post comment
+ (NSString *)userComment;
//for user, get contributions
+ (NSString *)userContribution;
//for user, device token
+ (NSString *)userDevice;
//for user, get drawing
+ (NSString *)userDrawing;
//for user, get nearby sponsors
+ (NSString *)userSponsorsNearby;

#pragma mark - User Connections
+ (NSString *)userConnectionBaseURL;
//by user_id, get user connections
+ (NSString *)userConnectionGet;
//by user_id, add user connection
+ (NSString *)userConnectionAdd;
//by user_id, delete user connection
+ (NSString *)userConnectionDelete;

#pragma mark - User Sponsor Connections
+ (NSString *)userSponsorConnectionBaseURL;
//by user_id, get sponsor connections
+ (NSString *)userSponsorsGet;

#pragma mark - User Sessions
//by user_id, get sessions that user has checked-in to
+ (NSString *)userSessionsGet;

#pragma mark - User Agenda
//by user_id, schedule of sessions that they have
+ (NSString *)userAgendaGet;

#pragma mark - User-Centric Management of Beacons
+ (NSString *)userManagementBaseURL;
//by user_id, get beacons associated to user_id
+ (NSString *)userBeacons;
//by user_id, add one or more beacons
+ (NSString *)userAddBeacons;
//by user_id, delete beacons
+ (NSString *)userDeleteBeacons;


#pragma mark - Beacon-Centric Management of Users
+ (NSString *)beaconManagementBaseURL;
//by beacon_id, get all users
+ (NSString *)beaconAllUsers;
//by beacon_id, add one user
+ (NSString *)beaconAddUser;
//by beacon_id, delete one user
+ (NSString *)beaconDeleteUser;


#pragma mark - Beacon Management
//for beacon, get event info
+ (NSString *)beaconEvents;

+ (NSString *)beaconMemberBaseURL;
//by beacon_id, get beacon
+ (NSString *)beaconMemberGet;
//by beacon_id, add beacon
+ (NSString *)beaconMemberAdd;
//by beacon_id, update beacon
+ (NSString *)beaconMemberUpdate;
//by beacon_id, delete beacon
+ (NSString *)beaconMemberDelete;

#pragma mark - Sponsor Connections
+ (NSString *)sponsorConnectionBaseURL;
//by sponsor_id, get sponsor's connections
+ (NSString *)sponsorConnectionGet;
//by sponsor_id, add sponsor's connection
+ (NSString *)sponsorConnectionAdd;












#pragma mark Location
+ (NSString *)locationForBeacon;
+ (NSString *)locationMaps;

#pragma mark - Maps API
+ (NSString *)promotions;
+ (NSString *)promotionWithID:(NSString *)promotionID;
+ (NSString *)promotionsFeatured;

@end
