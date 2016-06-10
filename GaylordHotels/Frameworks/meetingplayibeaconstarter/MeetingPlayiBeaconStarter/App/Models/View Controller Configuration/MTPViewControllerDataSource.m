//
//  MTPViewControllerDataSource.m
//  MeetingPlayiBeaconStarter
//
//  Created by John Pacheco on 4/9/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "MTPViewControllerDataSource.h"

@implementation MTPViewControllerDataSource

+ (instancetype)viewDataSource:(NSDictionary *)contentDictionary
{
    return [[MTPViewControllerDataSource alloc] initWithDataSource:contentDictionary];
}

- (instancetype)initWithDataSource:(NSDictionary *)contentDictionary
{
    self = [super init];
    if (self)
    {
        _dataSourceType = [self contentTypeFromString:[contentDictionary objectForKey:@"contentType"]];
        _pageTitle = [contentDictionary objectForKey:@"pageTitle"];
        _pageHeaderText = [contentDictionary objectForKey:@"pageHeaderText"];
        _pageSubtitleDescriptionText = [contentDictionary objectForKey:@"pageSubtitleDescriptionText"];
        _pageHeaderBackgroundImage = [contentDictionary objectForKey:@"pageHeaderBackgroundImage"];
        _pageContentBackgroundImage = [contentDictionary objectForKey:@"pageContentBackgroundImage"];
        _webviewBaseURL = [contentDictionary objectForKey:@"webviewBaseURL"];
        _additionalData = [NSMutableDictionary dictionaryWithDictionary:[contentDictionary
                                                                         objectForKey:@"additionalData"]];
    }
    return self;
}

- (MTPDisplayStyle)contentTypeFromString:(NSString *)contentTypeString
{
    return [[[self possibleContentTypes] objectForKey:contentTypeString] longLongValue];
}

- (NSDictionary *)possibleContentTypes
{
    return @{@"MTPDisplayStyleNone": @(1 << 0),
             
             @"MTPDisplayStyleUsersAll": @(1 << 1),
             @"MTPDisplayStyleUsersConnected": @(1 << 2),
             @"MTPDisplayStyleUsersUnconnected": @(1 << 3),
             @"MTPDisplayStyleUsersPending": @(1 << 4),
             @"MTPDisplayStyleUsersNearby": @(1 << 5),
             
             @"MTPDisplayStyleSponsorsAll": @(1 << 6),
             @"MTPDisplayStyleSponsorsConnected": @(1 << 7),
             @"MTPDisplayStyleSponsorsUnconnected": @(1 << 8),
             @"MTPDisplayStyleSponsorsPending": @(1 << 9),
             @"MTPDisplayStyleSponsorsNearby": @(1 << 10),
             
             @"MTPDisplayStyleWebView": @(1 << 11),
             @"MTPDisplayStyleRootView": @(1 << 12),
             @"MTPDisplayStyleConnectionDetails": @(1 << 13),
             @"MTPDisplayStylePhotoUpload": @(1 << 14),
             
             @"MTPDisplayStyleExplore": @(1 << 15),
             @"MTPDisplayStyleExploreDetails": @(1 << 16),
             
             @"MTPDisplayStyleEvents": @(1 << 17),
             @"MTPDisplayStyleNotifications": @(1 << 18),
             @"MTPDisplayStyleGeneralInformation": @(1 << 19),
             @"MTPDisplayStyleUserSettings": @(1 << 20),
             @"MTPDisplayStyleQRReader": @(1 << 21),
             @"MTPDisplayStyleMapView": @(1 << 22),
             @"MTPDisplayStyleSearch": @(1 << 23),
             };
}

@end
