//
//  NSString+MTPAPIAddresses.m
//  MarriottTPC
//
//  Created by John Pacheco on 5/13/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "NSString+MTPAPIAddresses.h"
#import "MTPAppSettingsKeys.h"

@implementation NSString (MTPAPIAddresses)
+ (NSString *)apiBaseURL
{
    NSString *baseURL = [[[NSUserDefaults standardUserDefaults] objectForKey:MTP_NetworkOptions] objectForKey:MTP_EventBaseAPIURL];
    NSAssert(baseURL.length > 0, @"No Base API URL was found. Please enter an address in your EventDefaults.plist");
    return baseURL;
//    return @"http://mm15api.meetingplay.com";
}

+ (NSString *)apiRelativePath
{
    return @"";
}

+ (NSNumber *)propertyKey
{
    return @3;
}

+ (NSString *)loginURL
{
    return [NSString stringWithFormat:@"%@%@/users/authenticate",[self apiBaseURL],[self apiRelativePath]];
}
+ (NSString *)logoutURL
{
    return [NSString stringWithFormat:@"%@%@/logout",[self apiBaseURL],[self apiRelativePath]];
}
+ (NSString *)sessionsAll
{
    return [NSString stringWithFormat:@"%@%@/sessions",[self apiBaseURL],[self apiRelativePath]];
}
+ (NSString *)sessionsBeacons
{
    return [NSString stringWithFormat:@"%@/beacons",[self sessionsAll]];
}
+ (NSString *)sessionPoll
{
    return [NSString stringWithFormat:@"%@%@/session/%@/poll",[self apiBaseURL],[self apiRelativePath],@"%@"];
}

+ (NSString *)eventBeacons
{
    return [NSString stringWithFormat:@"%@%@/property/%@/beacons/all",[self apiBaseURL],[self apiRelativePath],[self propertyKey]];
}

+ (NSString *)sponsorsAll
{
    return [NSString stringWithFormat:@"%@%@/sponsors",[self apiBaseURL],[self apiRelativePath]];
}
+ (NSString *)drawingTypes
{
    return [NSString stringWithFormat:@"%@%@/drawing/types",[self apiBaseURL],[self apiRelativePath]];
}

//by user_id, get info
+ (NSString *)userInfo
{
    return [NSString stringWithFormat:@"%@%@/user",[self apiBaseURL],[self apiRelativePath]];
}
//for users, get all users and their info
+ (NSString *)userCollection
{
    return [NSString stringWithFormat:@"%@%@/users",[self apiBaseURL],[self apiRelativePath]];
}
//for user, post image
+ (NSString *)userImage
{
    return [NSString stringWithFormat:@"%@/%@",[self userInfo],@"%@/photos"];
}
//for user, post comment
+ (NSString *)userComment
{
    return [NSString stringWithFormat:@"%@/%@",[self userInfo],@"%@/comment"];
}
//for user, get contributions
+ (NSString *)userContribution
{
    return [NSString stringWithFormat:@"%@/%@",[self userInfo],@"%@/contributions"];
}
//for user, device token
+ (NSString *)userDevice
{
    return [NSString stringWithFormat:@"%@/%@",[self userInfo],@"%@/devices"];
}
//for user, get drawing
+ (NSString *)userDrawing
{
    return [NSString stringWithFormat:@"%@/%@",[self userInfo],@"%@/drawing"];
}
//for user, get nearby sponsors
+ (NSString *)userSponsorsNearby
{
    return [NSString stringWithFormat:@"%@/%@",[self userInfo],@"%@/sponsors-nearby"];
}

#pragma mark - User Connections
+ (NSString *)userConnectionBaseURL
{
    return [NSString stringWithFormat:@"%@%@/user/%@",[self apiBaseURL],[self apiRelativePath],@"%@/connections"];
}
//by user_id, get user connections
+ (NSString *)userConnectionGet
{
    return [self userConnectionBaseURL];
}
//by user_id, add user connection
+ (NSString *)userConnectionAdd
{
    return [self userConnectionBaseURL];
}
//by user_id, delete user connection
+ (NSString *)userConnectionDelete
{
    return [self userConnectionBaseURL];
}

#pragma mark - User Sponsor Connections
+ (NSString *)userSponsorConnectionBaseURL
{
    return [NSString stringWithFormat:@"%@%@/user/%@",[self apiBaseURL],[self apiRelativePath],@"%@/sponsor-connections"];
}
//by user_id, get sponsor connections
+ (NSString *)userSponsorsGet
{
    return [self userSponsorConnectionBaseURL];
}

#pragma mark + User Sessions
//by user_id, get sessions that user has checked-in to
+ (NSString *)userSessionsGet
{
    return [NSString stringWithFormat:@"%@%@/user/%@",[self apiBaseURL],[self apiRelativePath],@"%@/sessions"];
}

#pragma mark - User Agenda
//by user_id, schedule of sessions that they have
+ (NSString *)userAgendaGet
{
    return [NSString stringWithFormat:@"%@%@/user/%@",[self apiBaseURL],[self apiRelativePath],@"%@/agenda"];
}

#pragma mark - User-Centric Management of Beacons
+ (NSString *)userManagementBaseURL
{
    return [NSString stringWithFormat:@"%@%@/user%@",[self apiBaseURL],[self apiRelativePath],@"/%@/beacons"];
}
//by user_id, get beacons associated to user_id
+ (NSString *)userBeacons
{
    return [self userManagementBaseURL];
}
//by user_id, add one or more beacons
+ (NSString *)userAddBeacons
{
    return [self userManagementBaseURL];
}
//by user_id, delete beacons
+ (NSString *)userDeleteBeacons
{
    return [self userManagementBaseURL];
}


#pragma mark - Beacon-Centric Management of Users
+ (NSString *)beaconManagementBaseURL
{
    return [NSString stringWithFormat:@"%@%@/beacon%@",[self apiBaseURL],[self apiRelativePath],@"/%@/users"];
}
//by beacon_id, get all users
+ (NSString *)beaconAllUsers
{
    return [self beaconManagementBaseURL];
}
//by beacon_id, add one user
+ (NSString *)beaconAddUser
{
    return [self beaconManagementBaseURL];
}
//by beacon_id, delete one user
+ (NSString *)beaconDeleteUser
{
    return [self beaconManagementBaseURL];
}


#pragma mark - Beacon Management
//for beacon, get event info
+ (NSString *)beaconEvents
{
    return [NSString stringWithFormat:@"%@%@/beacon%@",[self apiBaseURL],[self apiRelativePath],@"/%@/events"];
}

+ (NSString *)beaconMemberBaseURL
{
    return [NSString stringWithFormat:@"%@%@/beacon",[self apiBaseURL],[self apiRelativePath]];
}
//by beacon_id, get beacon
+ (NSString *)beaconMemberGet
{
    return [self beaconMemberBaseURL];
}
//by beacon_id, add beacon
+ (NSString *)beaconMemberAdd
{
    return [self beaconMemberBaseURL];
}
//by beacon_id, update beacon
+ (NSString *)beaconMemberUpdate
{
    return [self beaconMemberBaseURL];
}
//by beacon_id, delete beacon
+ (NSString *)beaconMemberDelete
{
    return [self beaconMemberBaseURL];
}

#pragma mark - Sponsor Connections
+ (NSString *)sponsorConnectionBaseURL
{
    return [NSString stringWithFormat:@"%@%@/sponsor/%@",[self apiBaseURL],[self apiRelativePath],@"%@/connections"];
}
//by sponsor_id, get sponsor's connections
+ (NSString *)sponsorConnectionGet
{
    return [self sponsorConnectionBaseURL];
}
//by sponsor_id, add sponsor's connection
+ (NSString *)sponsorConnectionAdd
{
    return [self sponsorConnectionBaseURL];
}
//by sponsor_id, delete sponsor's connection
+ (NSString *)sponsorConnectionDelete
{
    return [self sponsorConnectionBaseURL];
}

#pragma mark - Location
+ (NSString *)locationForBeacon
{
    return [NSString stringWithFormat:@"%@%@/property/%@/locations/beacon/%@",[self apiBaseURL],[self apiRelativePath],[self propertyKey],@"%@"];
}

+ (NSString *)locationMaps
{
    return [NSString stringWithFormat:@"%@%@/property/%@/maps/all",[self apiBaseURL],[self apiRelativePath],[self propertyKey]];
}


#pragma mark - Promotions
+ (NSString *)promotions
{
    return [NSString stringWithFormat:@"%@%@/property/%@/promotions/all",[self apiBaseURL],[self apiRelativePath],[self propertyKey]];
}

+ (NSString *)promotionWithID:(NSString *)promotionID
{
    return [NSString stringWithFormat:@"%@%@/property/%@/promotion/%@",[self apiBaseURL],[self apiRelativePath],[self propertyKey],promotionID];
}

+ (NSString *)promotionsFeatured
{
    return [NSString stringWithFormat:@"%@%@/property/%@/promotions/featured",[self apiBaseURL],[self apiRelativePath],[self propertyKey]];
}
@end
