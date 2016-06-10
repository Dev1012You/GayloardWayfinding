//
//  CHAWayfindingRouteXMLParser.h
//  GaylordHotels
//
//  Created by MeetingPlay on 4/29/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CGGeometry.h>

@class CHARoute;

@interface CHAWayfindingRouteXMLParser : NSObject <NSXMLParserDelegate>

@property (nonatomic, strong) NSData *parserData;

@property (nonatomic, strong) NSMutableArray *nodes;
@property (nonatomic, copy) void (^parseCompletionHandler)(CHARoute *fetchedRoute);
@property (nonatomic, copy) void (^errorHandler)(NSError *parseError);
@end
