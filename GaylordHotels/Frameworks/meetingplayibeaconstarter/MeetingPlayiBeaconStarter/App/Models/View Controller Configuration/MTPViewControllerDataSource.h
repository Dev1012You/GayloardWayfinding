//
//  MTPViewControllerDataSource.h
//  MeetingPlayiBeaconStarter
//
//  Created by John Pacheco on 4/9/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, MTPDisplayStyle)
{
    MTPDisplayStyleNone                   = 1 << 0,
    
    MTPDisplayStyleUsersAll               = 1 << 1,
    MTPDisplayStyleUsersConnected         = 1 << 2,
    MTPDisplayStyleUsersUnconnected       = 1 << 3,
    MTPDisplayStyleUsersPending           = 1 << 4,
    MTPDisplayStyleUsersNearby            = 1 << 5,
    
    MTPDisplayStyleSponsorsAll            = 1 << 6,
    MTPDisplayStyleSponsorsConnected      = 1 << 7,
    MTPDisplayStyleSponsorsUnconnected    = 1 << 8,
    MTPDisplayStyleSponsorsPending        = 1 << 9,
    MTPDisplayStyleSponsorsNearby         = 1 << 10,
    
    MTPDisplayStyleWebView                = 1 << 11,
    MTPDisplayStyleRootView               = 1 << 12,
    MTPDisplayStyleConnectionDetails      = 1 << 13,
    MTPDisplayStylePhotoUpload            = 1 << 14,
    
    MTPDisplayStyleExplore                = 1 << 15,
    MTPDisplayStyleExploreDetails         = 1 << 16,
    MTPDisplayStyleEvents                 = 1 << 17,
    MTPDisplayStyleNotifications          = 1 << 18,
    MTPDisplayStyleGeneralInformation     = 1 << 19,
    MTPDisplayStyleUserSettings           = 1 << 20,
    MTPDisplayStyleQRReader               = 1 << 21,
    MTPDisplayStyleMapView                = 1 << 22,
    MTPDisplayStyleSearch                 = 1 << 23,
    
    //    MTPDisplayStyle = 1 << 11,
};

@interface MTPViewControllerDataSource : NSObject
@property (nonatomic, assign) MTPDisplayStyle dataSourceType;

@property (nonatomic, strong) NSString *pageTitle;
@property (nonatomic, strong) NSString *pageHeaderText;
@property (nonatomic, strong) NSString *pageSubtitleDescriptionText;

@property (nonatomic, strong) NSString *pageHeaderBackgroundImage;
@property (nonatomic, strong) NSString *pageContentBackgroundImage;

@property (nonatomic, strong) NSString *webviewBaseURL;

@property (nonatomic, strong) NSMutableDictionary *additionalData;

+ (instancetype)viewDataSource:(NSDictionary *)contentDictionary;

- (instancetype)initWithDataSource:(NSDictionary *)contentDictionary;

@end
