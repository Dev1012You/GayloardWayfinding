//
//  EventKeys.h
//  MeetingPlayiBeaconStarter
//
//  Created by John Pacheco on 4/4/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EventKeys : NSObject

extern NSString *const MTP_LoginNotification;
extern NSString *const MTP_LogoutNotification;
extern NSString *const MTP_MyConnectionStatusChanged;
extern NSString *const MTP_MyLocationChanged;
#pragma mark API Keys
extern NSString *const kResponsePhotoUrl;
extern NSString *const kLoginEmail;

#pragma mark BeaconUpdateTypes
//by user_id, get beacons associated to user_id
extern NSString *const kUserGetBeacons;
//by user_id, add one or more beacons
extern NSString *const kUserAddBeacons;
//by user_id, delete beacons
extern NSString *const kUserDeleteBeacons;
//by user_id, get info
extern NSString *const kUserInfo;
//for users, get all users and their info
extern NSString *const kUserAllUsers;
//by beacon_id, get all users
extern NSString *const kBeaconGetUsers;
//by beacon_id, add one user
extern NSString *const kBeaconAddUser;
//by beacon_id, delete one user
extern NSString *const kBeaconDeleteUsers;
//for beacon, get event info
extern NSString *const kBeaconEvents;
extern NSString *const kEventTypePoll;
extern NSString *const kEventTypeSession;
extern NSString *const kEventTypeSponsorConnection;
extern NSString *const kEventTypeCheckIn;
extern NSString *const kEventTypeSessionPoll;

//for beacon, add beacon
extern NSString *const kBeaconMemberAdd;
//for beacon, update beacon
extern NSString *const kBeaconMemberUpdate;
//for beacon, get beacon info
extern NSString *const kBeaconMemberGet;
//for beacon, delete beacon
extern NSString *const kBeaconMemberDelete;

#pragma mark - User Profile Keys
#pragma mark UserLogin Response Keys
// Keys for the UserLogin response from the server
extern NSString *const kAddress1;
extern NSString *const kAddress2;
extern NSString *const kBio;
extern NSString *const kCell;
extern NSString *const kCity;
extern NSString *const kCountry;
extern NSString *const kCreatedOn;
extern NSString *const kEmail;
extern NSString *const kModifiedOn;
extern NSString *const kPhone;
extern NSString *const kPhoto;
extern NSString *const kRegion;
extern NSString *const kStateProvince;
extern NSString *const kTitle;
extern NSString *const kUserID;
extern NSString *const kUserType;
extern NSString *const kWork;
extern NSString *const kFirstName;
extern NSString *const kLastName;

#pragma mark UserCollection Response Keys
// Keys for the UserCollection reponse from the server
extern NSString *const kAttendeeType;
extern NSString *const kCompany;
extern NSString *const kZipCode;

#pragma mark - Standard User Settings
extern NSString *const kPermission;
extern NSString *const kLoggedIn;
extern NSString *const kMyConnections;
extern NSString *const kPhotoPickerFirstLoad;
extern NSString *const kPollInProgress;
extern NSString *const kTermsURL;
extern NSString *const kAllConnections;
extern NSString *const kProfileImageUrl;
extern NSString *const kSponsorLogoUrl;
extern NSString *const kFetchUsersUpdate;
extern NSString *const kAPNDeviceToken;
extern NSString *const kBackgroundMode;
extern NSString *const kUserDrawingUrl;
extern NSString *const kUserDrawingType;
extern NSString *const kDrawingTypesUserDefaultsKey;
extern NSString *const kLastSessionUpdate;

#pragma mark - MyConnectionStatusChange Keys
extern NSString *const kChangeToPending;
extern NSString *const kChangeToConnected;
extern NSString *const kChangeToNotConnected;
extern NSString *const kMyConnectionConnected;
extern NSString *const kMyConnectionPending;
extern NSString *const kMyConnectionNotConnected;


#pragma mark - MTPViewControllerDataSource Additional Data Keys
extern NSString *const kRealTimePoll;
extern NSString *const kSingleUseURL;

// UI colors
#define kLightGreen [UIColor colorWithRed:110/255.0 green:222/255.0 blue:192/255.0 alpha:1.0f]
#define kDarkGreen [UIColor colorWithRed:21/255.0 green:154/255.0 blue:4/255.0 alpha:1.0f]
#define kLightBlue [UIColor colorWithRed:1/255.0 green:49/255.0 blue:127/255.0 alpha:1.0f]
#define kDarkBlue [UIColor colorWithRed:11/255.0 green:41/255.0 blue:61/255.0 alpha:1.0f]
#define kOrange [UIColor colorWithRed:220/255.0 green:110/255.0 blue:29/255.0 alpha:1.0f]
@end
