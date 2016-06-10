//
//  MTPLoginClient.m
//  MeetingPlayiBeaconStarter
//
//  Created by John Pacheco on 4/8/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "MTPLoginClient.h"
#import "NSObject+EventDefaultsHelpers.h"
//#import "MTPAPIAddresses.h"
#import "NSString+MTPAPIAddresses.h"
#import "EventKeys.h"
#import "User+Helpers.h"
#import "NSURLSession+MTPCategory.h"
#import "MTPAppSettingsKeys.h"

@interface MTPLoginClient ()
@property (nonatomic, strong) NSManagedObjectContext *scratchContext;
@end

@implementation MTPLoginClient

+ (instancetype)loginClient:(NSManagedObjectContext *)rootObjectContext
{
    return [[MTPLoginClient alloc] init:rootObjectContext];
}

- (instancetype)init:(NSManagedObjectContext *)rootObjectContext
{
    self = [super init];
    if (self) {
        _scratchContext = rootObjectContext;
    }
    return self;
}

- (void)login:(NSString *)username
     password:(NSString *)password
successHandler:(void (^)(id responseObject, User *currentUser))successHandler
failureHandler:(void (^)(NSError *))failureHandler
validationError:(NSError *)validationError
{
    validationError = [self validate:username password:password];
    if (validationError) {
        if (failureHandler) {
            failureHandler(validationError);
        }
        return;
    }

    NSString *requestURL = [NSString loginURL];

    NSMutableURLRequest *URLRequest = [NSURLSession defaultRequestMethod:@"POST" URL:requestURL parameters:@{kLoginEmail: [NSString stringWithFormat:@"%@",username]}];
    
    __weak __typeof(&*self)weakSelf = self;
    [[[NSURLSession sharedSession] dataTaskWithRequest:URLRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            if (failureHandler) {
                failureHandler(error);
            }
        } else {
            NSError *serializationError = nil;
            id responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&serializationError];
            if (serializationError) {
                NSLog(@"%s [%s]: Line %i]\nSerialzation Error %@",
                      __FILE__,__PRETTY_FUNCTION__,__LINE__,
                      serializationError);
                return;
            }
            
            if (![[responseObject objectForKey:@"success"] boolValue]) {
                if (failureHandler) {
                    NSDictionary *errors = [[responseObject objectForKey:@"errors"] firstObject];
                    NSString *errorMessage = [errors objectForKey:@"message"] ? [errors objectForKey:@"message"] : @"Login Error";
                    failureHandler([NSError errorWithDomain:[self bundleIdentifier]
                                                       code:10002
                                                   userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"loginFailedUsername", nil),
                                                              NSLocalizedFailureReasonErrorKey: errorMessage}]);
                }
                return;
            }
            
            if (successHandler) {
                NSNumber *userID = [[responseObject objectForKey:@"data"] objectForKey:kUserID];
                User *loggedInUser = [User findUser:userID context:weakSelf.scratchContext];
                if (!loggedInUser) {
                    loggedInUser = [User createInContext:weakSelf.scratchContext];
                }
                loggedInUser.loggedIn = @(true);
                loggedInUser.user_id = userID;
                NSString *emailIdentifier = [NSString stringWithFormat:@"%@",[[responseObject objectForKey:@"input"] objectForKey:kEmail]];
                loggedInUser.email = emailIdentifier;
                
                [loggedInUser saveToPersistentStore:weakSelf.scratchContext];

                if (userID) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:MTP_LoginNotification
                                                                        object:nil
                                                                      userInfo:@{@"user_id":userID}];
                }
                
                successHandler(responseObject,loggedInUser);
            }
            [weakSelf clearWebCaches];
        }
    }] resume];
}

- (NSError *)validate:(NSString *)username password:(NSString *)password
{
    NSMutableDictionary *errorDictionary =
    [NSMutableDictionary dictionaryWithDictionary:@{NSLocalizedDescriptionKey: @"Login Attempt Failed"}];
    
    
    NSDictionary *validationErrorDictionary;
    // validate the username
    if ((validationErrorDictionary = [self validUsername:username])) {
        [errorDictionary addEntriesFromDictionary:validationErrorDictionary];
        return [NSError errorWithDomain:[self bundleIdentifier]
                                   code:10001
                               userInfo:errorDictionary];;
    }
    
    // validate the password
    if ([[self.userDefaults objectForKey:MTP_LoginPasswordRequired] boolValue]) {
        if ((validationErrorDictionary = [self validPassword:password])) {
            [errorDictionary addEntriesFromDictionary:validationErrorDictionary];
            return [NSError errorWithDomain:[self bundleIdentifier]
                                       code:10001
                                   userInfo:errorDictionary];;
        }
    }
    
    return nil;
}

- (NSDictionary *)validUsername:(NSString *)username
{
    if (username.length == 0) return @{NSLocalizedFailureReasonErrorKey: @"Username was empty"};
    if ([username rangeOfString:@" "].location != NSNotFound) return @{NSLocalizedFailureReasonErrorKey: @"Username contained spaces"};

    return nil;
}

- (NSDictionary *)validPassword:(NSString *)password
{
    if (password.length == 0) return @{NSLocalizedFailureReasonErrorKey: @"Password was empty"};
    if ([password rangeOfString:@" "].location != NSNotFound) return @{NSLocalizedFailureReasonErrorKey: @"Password contained spaces"};
    
    return nil;
}


- (NSString *)bundleIdentifier
{
    return (__bridge_transfer NSString *)CFBundleGetIdentifier(CFBundleGetMainBundle());
}

- (void)clearWebCaches
{
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    for (NSHTTPCookie *cookie in cookies)
    {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
}
@end
