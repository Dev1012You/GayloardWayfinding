//
//  MTAPIClient.h
//  MarriottDigitalSummit
//
//  Created by John Pacheco on 4/30/14.
//  Copyright (c) 2014 Grumble Apps. All rights reserved.
//

#import "AFNetworking.h"

@interface MTAPIClient : AFHTTPRequestOperationManager

+ (MTAPIClient *)sharedClient;

@end
