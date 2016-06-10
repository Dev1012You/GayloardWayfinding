//
//  MTPSessionManager.h
//  MeetingPlayiBeaconStarter
//
//  Created by John Pacheco on 4/7/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MTPSession;

@interface MTPSessionManager : NSObject

@property (strong, nonatomic) NSMutableArray *sessionCollection;

+ (instancetype)sessionManager;

- (void)addSession:(MTPSession *)session;

- (MTPSession *)getSession:(NSNumber *)sessionID;

- (MTPSession *)getSessionByBeaconID:(NSString *)beaconID;

@end
