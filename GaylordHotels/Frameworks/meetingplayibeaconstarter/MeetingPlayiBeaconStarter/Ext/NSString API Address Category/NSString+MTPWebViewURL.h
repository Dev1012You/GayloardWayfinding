//
//  NSString+MTPWebViewURL.h
//  MarriottTPC
//
//  Created by John Pacheco on 5/13/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MTPWebViewURL)

+ (NSString *)websiteBaseURL;

+ (NSString *)websiteLoginURL;
+ (NSString *)agendaURL;
+ (NSString *)sessionDetailsURL;
+ (NSString *)pollWithIDURL;

+ (NSString *)sponsorsURL;
+ (NSString *)gameConnectionURL;

+ (NSString *)photoGalleryURL;
+ (NSString *)conversationWallURL;

+ (NSString *)roomEventDetails;

@end
