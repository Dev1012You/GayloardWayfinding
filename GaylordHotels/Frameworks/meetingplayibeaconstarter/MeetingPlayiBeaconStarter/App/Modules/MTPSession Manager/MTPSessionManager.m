//
//  MTPSessionManager.m
//  MeetingPlayiBeaconStarter
//
//  Created by John Pacheco on 4/7/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "MTPSessionManager.h"
#import "MTPSession.h"

@implementation MTPSessionManager

+ (instancetype)sessionManager
{
    return [[MTPSessionManager alloc] init];
}

- (void)addSession:(MTPSession *)session
{
    if (![self.sessionCollection containsObject:session]) {
        [self.sessionCollection addObject:session];
    }
}

- (MTPSession *)getSession:(NSNumber*)sessionID
{
    __block MTPSession *foundSession;
    [self.sessionCollection enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([[(MTPSession *)obj session_id] isEqualToNumber:sessionID]) {
            foundSession = obj;
        }
    }];
    return foundSession;
}

- (MTPSession *)getSessionByBeaconID:(NSString*)beaconID
{
    __block MTPSession *foundSession;
    [self.sessionCollection enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([[(MTPSession *)obj beaconId].uppercaseString isEqualToString:beaconID.uppercaseString]) {
            foundSession = obj;
        }
    }];
    return foundSession;
}


- (NSMutableArray*)sessionCollection
{
    if (!_sessionCollection) {
        _sessionCollection = [NSMutableArray array];
    }
    return _sessionCollection;
}

@end
