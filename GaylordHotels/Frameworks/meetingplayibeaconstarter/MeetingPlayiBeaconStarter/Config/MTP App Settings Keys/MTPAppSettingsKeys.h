//
//  MTPAppSettingsKeys.h
//  RS West Coast 2015
//
//  Created by John Pacheco on 7/24/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MTPAppSettingsKeys : NSObject

#pragma mark - Base Options
extern NSString *const MTP_BaseOptions;
extern NSString *const MTP_LoginPINRequired;

extern NSString *const MTP_NamePreference;
extern NSString *const MTP_APNSDeviceToken;
extern NSString *const MTP_LoginPasswordRequired;
extern NSString *const MTP_EventConnectionGame;
extern NSString *const MTP_CustomFonts;

extern NSString *const MTP_ViewControllerConfigurationData;

#pragma mark - iBeacon Options
extern NSString *const MTP_BeaconOptions;
extern NSString *const MTP_GimbalAPIKey;
extern NSString *const MTP_RelevantBeaconCount;
extern NSString *const MTP_DefaultNilRSSI;

#pragma mark - Network Options
extern NSString *const MTP_NetworkOptions;
extern NSString *const MTP_EventBaseHTTPURL;
extern NSString *const MTP_EventBaseAPIURL;
extern NSString *const MTP_URLRequestDefaultTimeoutInterval;
extern NSString *const MTP_XAuthToken;
extern NSString *const MTP_ParseApplicationID;
extern NSString *const MTP_ParseClientKey;

#pragma mark - Quick Links Apperance Options
extern NSString *const MTP_QuickLinksItems;
extern NSString *const MTP_QuickLinksAppearanceOptions;

extern NSString *const MTP_QuickLinkIconColor;
extern NSString *const MTP_QuickLinkTextColor;
extern NSString *const MTP_QuickLinkCircleColor;
extern NSString *const MTP_QuickLinksBackgroundColor;

#pragma mark - Main Menu Appearance Options
extern NSString *const MTP_MainMenuItems;
extern NSString *const MTP_MainMenuOptions;

extern NSString *const MTP_MainMenuFontDescription;
extern NSString *const MTP_MainMenuDefaultFontName;
extern NSString *const MTP_MainMenuDefaultFontSize;
extern NSString *const MTP_MainMenuDefaultFontColor;

extern NSString *const MTP_EditProfileButtonColor;
extern NSString *const MTP_EditProfileButtonTextColor;

extern NSString *const MTP_MainMenuFontName;
extern NSString *const MTP_MainMenuFontSize;
extern NSString *const MTP_MainMenuFontColor;
extern NSString *const MTP_MainMenuIconColor;

extern NSString *const MTP_MainMenuSectionFontDescription;
extern NSString *const MTP_MainMenuSectionFontName;
extern NSString *const MTP_MainMenuSectionFontSize;
extern NSString *const MTP_MainMenuSectionFontColor;
extern NSString *const MTP_MainMenuSectionBackgroundColor;

#pragma mark - Login Screen Options
extern NSString *const MTP_LoginScreenOptions;

extern NSString *const MTP_LoginButtonBackgroundColor;
extern NSString *const MTP_LoginButtonTextColor;
extern NSString *const MTP_LoginButtonBorderColor;
extern NSString *const MTP_AcceptTermsCheckmarkColor;
















@end
