//
//  MTAPIClient.m
//  MarriottDigitalSummit
//
//  Created by John Pacheco on 4/30/14.
//  Copyright (c) 2014 Grumble Apps. All rights reserved.
//

#import "MTAPIClient.h"
#import "NSObject+EventDefaultsHelpers.h"
//#import "MTPAPIAddresses.h"
#import "NSString+MTPAPIAddresses.h"
#import "MTPAppSettingsKeys.h"

@implementation MTAPIClient

+ (MTAPIClient *)sharedClient {
    static MTAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[MTAPIClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString apiBaseURL]]];
    });
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    self.securityPolicy.allowInvalidCertificates = YES; // not recommended for production
    [self setRequestSerializer:[AFJSONRequestSerializer serializer]];
    [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [self.requestSerializer setValue:@"no-cache" forHTTPHeaderField:@"Cache-Control"];
    [self.requestSerializer setValue:[[self.userDefaults objectForKey:MTP_NetworkOptions] objectForKey:MTP_XAuthToken] forHTTPHeaderField:@"X-Authentication-Token"];
    [self setResponseSerializer:[AFJSONResponseSerializer serializer]];
    
    return self;
}


@end