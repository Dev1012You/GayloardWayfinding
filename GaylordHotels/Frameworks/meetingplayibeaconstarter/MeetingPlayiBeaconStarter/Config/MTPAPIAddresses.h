//
//  MTPAPIAddresses.h
//  MeetingPlayiBeaconStarter
//
//  Created by John Pacheco on 4/7/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MTPAPIAddresses : NSObject

// API URLS
#ifdef DEBUG
    #define API_BASE_URL @"http://mm15api.meetingplay.com"
    #define API_RELATIVE_PATH @""
#else
    #define API_BASE_URL @"http://mm15api.meetingplay.com"
    #define API_RELATIVE_PATH @""
#endif


#define LOGIN_URL [NSString stringWithFormat:@"%@%@/users/authenticate",API_BASE_URL,API_RELATIVE_PATH]
#define LOGOUT_URL [NSString stringWithFormat:@"%@%@/logout",API_BASE_URL,API_RELATIVE_PATH]
#define SESSIONS_ALL [NSString stringWithFormat:@"%@%@/sessions",API_BASE_URL,API_RELATIVE_PATH]
#define SESSIONS_BEACONS [NSString stringWithFormat:@"%@/beacons",SESSIONS_ALL]
#define SESSION_POLL [NSString stringWithFormat:@"%@%@/session/%@/poll",API_BASE_URL,API_RELATIVE_PATH,@"%@"]

#define EVENT_BEACONS [NSString stringWithFormat:@"%@%@/beacons",API_BASE_URL,API_RELATIVE_PATH]
#define SPONSORS_ALL [NSString stringWithFormat:@"%@%@/sponsors",API_BASE_URL,API_RELATIVE_PATH]
#define DRAWING_TYPES [NSString stringWithFormat:@"%@%@/drawing/types",API_BASE_URL,API_RELATIVE_PATH]

//by user_id, get info
#define USER_INFO [NSString stringWithFormat:@"%@%@/user",API_BASE_URL,API_RELATIVE_PATH]
//for users, get all users and their info
#define USER_COLLECTION [NSString stringWithFormat:@"%@%@/users",API_BASE_URL,API_RELATIVE_PATH]
//for user, post image
#define USER_IMAGE [NSString stringWithFormat:@"%@/%@",USER_INFO,@"%@/photos"]
//for user, post comment
#define USER_COMMENT [NSString stringWithFormat:@"%@/%@",USER_INFO,@"%@/comment"]
//for user, get contributions
#define USER_CONTRIBUTION [NSString stringWithFormat:@"%@/%@",USER_INFO,@"%@/contributions"]
//for user, device token
#define USER_DEVICE [NSString stringWithFormat:@"%@/%@",USER_INFO,@"%@/devices"]
//for user, get drawing
#define USER_DRAWING [NSString stringWithFormat:@"%@/%@",USER_INFO,@"%@/drawing"]
//for user, get nearby sponsors
#define USER_SPONSORS_NEARBY [NSString stringWithFormat:@"%@/%@",USER_INFO,@"%@/sponsors-nearby"]

#pragma mark - User Connections
#define USER_CONNECTION_BASE [NSString stringWithFormat:@"%@%@/user/%@",API_BASE_URL,API_RELATIVE_PATH,@"%@/connections"]
//by user_id, get user connections
#define USER_CONNECTION_GET USER_CONNECTION_BASE
//by user_id, add user connection
#define USER_CONNECTION_ADD USER_CONNECTION_BASE
//by user_id, delete user connection
#define USER_CONNECTION_DELETE USER_CONNECTION_BASE

#pragma mark - User Sponsor Connections
#define USER_SPONSOR_CONNECTION_BASE [NSString stringWithFormat:@"%@%@/user/%@",API_BASE_URL,API_RELATIVE_PATH,@"%@/sponsor-connections"]
//by user_id, get sponsor connections
#define USER_SPONSORS_GET USER_SPONSOR_CONNECTION_BASE

#pragma mark - User Sessions
//by user_id, get sessions that user has checked-in to
#define USER_SESSIONS_GET [NSString stringWithFormat:@"%@%@/user/%@",API_BASE_URL,API_RELATIVE_PATH,@"%@/sessions"]

#pragma mark - User Agenda
//by user_id, schedule of sessions that they have
#define USER_AGENDA_GET [NSString stringWithFormat:@"%@%@/user/%@",API_BASE_URL,API_RELATIVE_PATH,@"%@/agenda"]

#pragma mark - User-Centric Management of Beacons
#define USER_MANAGEMENT [NSString stringWithFormat:@"%@%@/user%@",API_BASE_URL,API_RELATIVE_PATH,@"/%@/beacons"]
//by user_id, get beacons associated to user_id
#define USER_BEACONS USER_MANAGEMENT
//by user_id, add one or more beacons
#define USER_ADD_BEACON USER_MANAGEMENT
//by user_id, delete beacons
#define USER_DELETE_BEACONS USER_MANAGEMENT


#pragma mark - Beacon-Centric Management of Users
#define BEACON_MANAGEMENT [NSString stringWithFormat:@"%@%@/beacon%@",API_BASE_URL,API_RELATIVE_PATH,@"/%@/users"]
//by beacon_id, get all users
#define BEACON_ALL_USERS BEACON_MANAGEMENT
//by beacon_id, add one user
#define BEACON_ADD_USERS BEACON_MANAGEMENT
//by beacon_id, delete one user
#define BEACON_DELETE_USER BEACON_MANAGEMENT


#pragma mark - Beacon Management
//for beacon, get event info
#define BEACON_EVENTS [NSString stringWithFormat:@"%@%@/beacon%@",API_BASE_URL,API_RELATIVE_PATH,@"/%@/events"]

#define BEACON_MEMBER [NSString stringWithFormat:@"%@%@/beacon",API_BASE_URL,API_RELATIVE_PATH]
//by beacon_id, get beacon
#define BEACON_MEMBER_GET BEACON_MEMBER
//by beacon_id, add beacon
#define BEACON_MEMBER_ADD BEACON_MEMBER
//by beacon_id, update beacon
#define BEACON_MEMBER_UPDATE BEACON_MEMBER
//by beacon_id, delete beacon
#define BEACON_MEMBER_DELETE BEACON_MEMBER

#pragma mark - Sponsor Connections
#define SPONSOR_CONNECTION_BASE [NSString stringWithFormat:@"%@%@/sponsor/%@",API_BASE_URL,API_RELATIVE_PATH,@"%@/connections"]
//by sponsor_id, get sponsor's connections
#define SPONSOR_CONNECTION_GET SPONSOR_CONNECTION_BASE
//by sponsor_id, add sponsor's connection
#define SPONSOR_CONNECTION_ADD SPONSOR_CONNECTION_BASE
//by sponsor_id, delete sponsor's connection
#define SPONSOR_CONNECTION_DELETE SPONSOR_CONNECTION_BASE

@end
