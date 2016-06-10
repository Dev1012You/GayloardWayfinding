//
//  NSString+MTPWebViewURL.m
//  MarriottTPC
//
//  Created by John Pacheco on 5/13/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "NSString+MTPWebViewURL.h"
#import "MTPAppSettingsKeys.h"

@implementation NSString (MTPWebViewURL)

+ (NSString *)websiteBaseURL
{
    NSString *baseURL = [[[NSUserDefaults standardUserDefaults] objectForKey:MTP_NetworkOptions] objectForKey:MTP_EventBaseHTTPURL];
    NSAssert(baseURL.length > 0, @"No Base API URL was found. Please enter an address in your EventDefaults.plist");
    return baseURL;
    
//    return @"http://tpc15.meetingplay.com";
}

+ (NSString *)websiteLoginURL
{
    return [NSString stringWithFormat:@"%@/login/",[self websiteBaseURL]];
}

+ (NSString *)agendaURL
{
    return [NSString stringWithFormat:@"%@/agenda/?",[self websiteBaseURL]];
}

+ (NSString *)sessionDetailsURL
{
    return [NSString stringWithFormat:@"%@/session/%@/?",[self websiteBaseURL],@"%@"];
}

+ (NSString *)pollWithIDURL
{
    return [NSString stringWithFormat:@"%@/qr/3/%@",[self websiteBaseURL],@"%@"];
}

+ (NSString *)sponsorsURL
{
    return [NSString stringWithFormat:@"%@/sponsor-list/?",[self websiteBaseURL]];
}

+ (NSString *)gameConnectionURL
{
    return [NSString stringWithFormat:@"%@/game/%@",[self websiteBaseURL],@"complete-connection.cfm?user_id=%@&connection_user_id=%@"];
}

+ (NSString *)photoGalleryURL
{
    return [NSString stringWithFormat:@"%@/photo-gallery/?",[self websiteBaseURL]];
}

+ (NSString *)conversationWallURL
{
    return [NSString stringWithFormat:@"%@/conversation-wall/?",[self websiteBaseURL]];
}

+ (NSString *)roomEventDetails
{
    return [NSString stringWithFormat:@"http://www.meetingplay.com/gaylord/event-room.cfm?room_key=%@&",@"%@"];
}

@end
