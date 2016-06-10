//
//  MTPLoginClient.h
//  MeetingPlayiBeaconStarter
//
//  Created by John Pacheco on 4/8/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSManagedObjectContext, User;

@interface MTPLoginClient : NSObject

//@property (nonatomic, copy) void (^successHandler)(id responseObject);
//@property (nonatomic, copy) void (^failureHandler)(NSError *error);

+ (instancetype)loginClient:(NSManagedObjectContext *)rootObjectContext;

- (void)login:(NSString *)username
     password:(NSString *)password
successHandler:(void (^)(id responseObject, User *currentUser))successHandler
failureHandler:(void (^)(NSError *))failureHandler
validationError:(NSError *)validationError;

@end
