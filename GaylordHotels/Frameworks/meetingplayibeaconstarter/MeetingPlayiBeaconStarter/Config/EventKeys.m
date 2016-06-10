//
//  EventKeys.m
//  MeetingPlayiBeaconStarter
//
//  Created by John Pacheco on 4/4/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "EventKeys.h"

@implementation EventKeys
NSString *const MTP_LoginNotification = @"MTP_LoginNotification";
NSString *const MTP_LogoutNotification = @"MTP_LogoutNotification";
NSString *const MTP_MyConnectionStatusChanged = @"MyConnectionStatusChanged";
NSString *const MTP_MyLocationChanged = @"MyLocationChanged";

NSString *const kResponsePhotoUrl = @"photoURL";
NSString *const kLoginEmail = @"email";

#pragma mark BeaconUpdateTypes
//by user_id, get beacons associated to user_id
NSString *const kUserGetBeacons = @"userGetBeacons";
//by user_id, add one or more beacons
NSString *const kUserAddBeacons = @"userAddBeacons";
//by user_id, delete beacons
NSString *const kUserDeleteBeacons = @"userDeleteBeacons";
//by user_id, get info
NSString *const kUserInfo = @"userInfo";
//for users, get all users and their info
NSString *const kUserAllUsers = @"userAllUsers";
//by beacon_id, get all users
NSString *const kBeaconGetUsers = @"beaconGetUsers";
//by beacon_id, add one user
NSString *const kBeaconAddUser = @"beaconAddUser";
//by beacon_id, delete one user
NSString *const kBeaconDeleteUsers = @"beaconDeleteUser";
//for beacon, get event info
NSString *const kBeaconEvents = @"beaconEvents";
NSString *const kEventTypePoll = @"beaconEventPoll";
NSString *const kEventTypeSession = @"beaconEventSession";
NSString *const kEventTypeSponsorConnection = @"beaconEventSponsorConnection";
NSString *const kEventTypeCheckIn = @"beaconEventCheckIn";
NSString *const kEventTypeSessionPoll = @"beaconEventSessionPoll";

//for beacon, add beacon
NSString *const kBeaconMemberAdd = @"beaconMemberAdd";
//for beacon, update beacon
NSString *const kBeaconMemberUpdate = @"beaconMemberUpdate";
//for beacon, get beacon info
NSString *const kBeaconMemberGet = @"beaconMemberGet";
//for beacon, delete beacon
NSString *const kBeaconMemberDelete = @"beaconMemberDelete";

#pragma mark - User Profile Keys
#pragma mark UserLogin Response Keys
NSString *const kAddress1 = @"address1";
NSString *const kAddress2 = @"address2";
NSString *const kBio = @"bio";
NSString *const kCell = @"cell";
NSString *const kCity = @"city";
NSString *const kCountry = @"country";
NSString *const kCreatedOn = @"created";
NSString *const kEmail = @"email";
NSString *const kModifiedOn = @"modified";
NSString *const kPhone = @"phone";
NSString *const kPhoto = @"photo";
NSString *const kRegion = @"region";
NSString *const kStateProvince = @"state";
NSString *const kTitle = @"title";
NSString *const kUserID = @"user_id";
NSString *const kUserType = @"user_type";
NSString *const kWork = @"work";
NSString *const kFirstName = @"first_name";
NSString *const kLastName = @"last_name";
#pragma mark UserCollection Response Keys
// Keys for the UserCollection reponse from the server
NSString *const kAttendeeType = @"attendee_type";
NSString *const kCompany = @"company";
NSString *const kZipCode = @"zip_code";

#pragma mark - Standard User Settings
NSString *const kPermission = @"permission";
NSString *const kLoggedIn = @"kLoggedIn";
NSString *const kMyConnections = @"myConnections";
NSString *const kPhotoPickerFirstLoad = @"photoPickerFirstLoad";
NSString *const kPollInProgress = @"pollInProgress";
NSString *const kTermsURL = @"http://www.meetingplay.com/terms/";
NSString *const kAllConnections = @"allConnections";
NSString *const kProfileImageUrl = @"profileImageUrl";
NSString *const kSponsorLogoUrl = @"sponsorLogoUrl";
NSString *const kFetchUsersUpdate = @"fetchUsersUpdate";
NSString *const kAPNDeviceToken = @"APNDeviceToken";
NSString *const kBackgroundMode = @"backgroundMode";
NSString *const kUserDrawingUrl = @"userDrawingUrl";
NSString *const kUserDrawingType = @"userDrawingType";
NSString *const kDrawingTypesUserDefaultsKey = @"userDrawingTypesAvailable";
NSString *const kLastSessionUpdate = @"kLastSessionUpdate";

#pragma mark - MyConnectionStatusChange Keys
NSString *const kChangeToPending = @"changeToPending";
NSString *const kChangeToConnected = @"changeToConnected";
NSString *const kChangeToNotConnected = @"changeToNotConnected";
NSString *const kMyConnectionConnected = @"myConnectionConnected";
NSString *const kMyConnectionPending = @"myConnectionPending";
NSString *const kMyConnectionNotConnected = @"myConnectionNotConnected";

#pragma mark - MTPViewControllerDataSource Additional Data Keys
NSString *const kRealTimePoll = @"realTimePoll";
NSString *const kSingleUseURL = @"temporaryURL";

@end
