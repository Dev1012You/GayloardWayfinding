//
//  MDMyConnectionManager.m
//  MarriottDigitalSummit
//
//  Created by John Pacheco on 5/7/14.
//  Copyright (c) 2014 Grumble Apps. All rights reserved.
//

#import "MDMyConnectionManager.h"
#import "MDMyConnectionRelationship.h"
#import "User+Helpers.h"
#import "MTAPIClient.h"
//#import "MTPAPIAddresses.h"
#import "NSString+MTPAPIAddresses.h"
#import "EventKeys.h"

@interface MDMyConnectionManager ()
@property (nonatomic, strong) NSManagedObjectContext *scratchContext;
@end

@implementation MDMyConnectionManager

+ (instancetype)connectionManager:(NSManagedObjectContext *)managedObjectContext
{
    return [[MDMyConnectionManager alloc] init:managedObjectContext];
}

- (instancetype)init:(NSManagedObjectContext *)rootContext
{
    self = [super init];
    if (self) {
        _scratchContext = rootContext;
        NSString *path = [self itemArchivePath];
        [self setConnections:[[NSKeyedUnarchiver unarchiveObjectWithFile:path] mutableCopy]];
    }
    return self;
}

- (NSMutableSet *)connections {
    if (!_connections) {
        _connections = [NSMutableSet new];
    }
    return _connections;
}

- (void)addMyConnection:(NSNumber *)userID {
    [self addMyConnection:userID withStatus:kMyConnectionConnected];
}

- (void)addMyConnection:(NSNumber *)userID withStatus:(NSString *)relationshipStatus {
    NSString *connectionStatus = [self checkMyConnectionFor:userID];
    if (connectionStatus) {
        [self changeMyConnectionStatus:userID toStatus:relationshipStatus];
    } else {
        MDMyConnectionRelationship *relationship = [MDMyConnectionRelationship relationshipFor:userID withStatus:relationshipStatus];
        NSNumber *newUserId;
        if (![relationship.userID isKindOfClass:[NSNumber class]]) {
            NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
            [f setNumberStyle:NSNumberFormatterDecimalStyle];
            newUserId = [f numberFromString:(NSString *)userID];
            relationship.userID = newUserId;
        }
        [self.connections addObject:relationship];
        [self save];
    }
}

-(void)changeMyConnectionStatus:(NSNumber*)userID toStatus:(NSString*)newStatus {
    __block BOOL containsUser = NO;
    [self.connections enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        if ([[obj userID] isEqual:userID]) {
            [obj setRelationshipStatus:newStatus];
            containsUser = YES;
            *stop = YES;
        }
    }];
    
    if (!containsUser) {
        [self addMyConnection:userID withStatus:newStatus];
    } else {
        [self save];
    }
}

- (BOOL)removeMyConnection:(NSNumber *)userID {
    NSInteger countBeforeRemoval = self.connections.count;
    __block MDMyConnectionRelationship *relationship;
    [self.connections enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        if ([[obj userID] isEqual:userID]) {
            relationship = obj;
        }
    }];
    
    if (relationship) {
        [self.connections removeObject:relationship];
    } else {
//        DLog(@"\nuserID not found %@", userID);
        NSLog(@"\nuserID not found %@", userID);
    }
    
    [self save];
    return countBeforeRemoval == self.connections.count ? NO : YES;
}

- (NSString*)checkMyConnectionFor:(NSNumber *)userID {
    NSNumber *targetUserId;
    if ([userID isKindOfClass:[NSNumber class]]) {
        targetUserId = userID;
    } else {
        if ([targetUserId isKindOfClass:[NSString class]]) {
            NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
            [f setNumberStyle:NSNumberFormatterDecimalStyle];
            targetUserId = [f numberFromString:(NSString *)userID];
        } else {
            return nil;
        }
    }
    
    __block MDMyConnectionRelationship *relationship;
    [self.connections enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        NSNumber *relationshipUserId;
        if ([[obj userID] isKindOfClass:[NSNumber class]]) {
            relationshipUserId = [obj userID];
        } else {
            if ([[obj userID] isKindOfClass:[NSString class]]) {
                NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
                [f setNumberStyle:NSNumberFormatterDecimalStyle];
                relationshipUserId = [f numberFromString:(NSString *)[obj userID]];
            } else {
//                DLog(@"\nother type of class than string or number");
                NSLog(@"\nother type of class than string or number");
            }
        }
        if ([relationshipUserId isEqualToNumber:targetUserId]) {
            relationship = obj;
        }
    }];
    
    if (relationship) {
        return relationship.relationshipStatus;
    } else {
        return nil;
    }
}

- (NSArray*)connected {
    __block NSMutableArray *pendingIDs = [NSMutableArray new];
    [self.connections enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        if ([[obj relationshipStatus] isEqualToString:kMyConnectionConnected]) {
            [pendingIDs addObject:[obj userID]];
        }
    }];
    return (pendingIDs.count > 0) ? pendingIDs : nil;
}

- (NSArray*)pending {
    __block NSMutableArray *pendingIDs = [NSMutableArray new];
    [self.connections enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        if ([[obj relationshipStatus] isEqualToString:kMyConnectionPending]) {
            [pendingIDs addObject:[obj userID]];
        }
    }];
    return (pendingIDs.count > 0) ? pendingIDs : nil;
}

- (void)flushAll {
    [self.connections removeAllObjects];
}


- (void)save {
    NSString *path = [self itemArchivePath];
    BOOL success = [NSKeyedArchiver archiveRootObject:self.connections toFile:path];
//    DLog(@"%@", success ? @"true" : @"false");
}

- (void)deleteRelationshipsFile {
    NSString *path = [self itemArchivePath];
    BOOL success = [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
//    DLog(@"%@", success ? @"true" : @"false");
}


-(NSString *)itemArchivePath {
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    // Get one and only document directory from that list
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    return [documentDirectory stringByAppendingPathComponent:@"connections.archive"];
}

- (void)updateConnectionsFromApi {
    // fetch already connected users
    User *currentUser = [User currentUser:self.scratchContext];
    if (!currentUser) {
        return;
    }
    
    NSString *apiURL = [NSString stringWithFormat:[NSString userConnectionGet],currentUser.user_id];

    // get already-connected users or get users nearby that are associated to a beacon
    __weak __typeof(&*self)weakSelf = self;
    [[MTAPIClient sharedClient] GET:apiURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        if ([responseObject isKindOfClass:[NSDictionary class]])
        {
            if ([responseObject objectForKey:@"data"]) {
                NSString *keyForUsers;
                if ([apiURL isEqualToString:[NSString stringWithFormat:[NSString userConnectionGet],currentUser.user_id]])
                {
                    [weakSelf flushAll];
                    // fetch connected users
                    keyForUsers = @"connnection_user_id";
                    NSArray *connectedUserIDsFromAPI = [responseObject objectForKey:@"data"];
                    [connectedUserIDsFromAPI enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        if ([obj isKindOfClass:[NSDictionary class]]) {
                            NSDictionary *connectionInfo = obj;
                            NSArray *connectionInfoKeys = [connectionInfo allKeys];
                            if ([connectionInfoKeys containsObject:@"connection_status"] &&
                                [connectionInfoKeys containsObject:keyForUsers])
                            {
                                id userId = [connectionInfo objectForKey:keyForUsers];
                                if ([userId isKindOfClass:[NSNumber class]])
                                {
                                    NSNumber *connectionUserId = userId;
                                    NSString *connectionStatus = [connectionInfo objectForKey:@"connection_status"];
                                    NSString *newStatus;
                                    if ([connectionStatus isEqualToString:@"Pending"]) {
                                        newStatus = kMyConnectionConnected;
                                    } else if ([connectionStatus isEqualToString:@"Connected"]) {
                                        newStatus = kMyConnectionConnected;
                                    } else {
//                                        DLog(@"\nunknown connection type");
                                        newStatus = kMyConnectionConnected;
                                    }
                                    [weakSelf changeMyConnectionStatus:connectionUserId
                                                              toStatus:newStatus];
                                } else {
                                    //                                        DLog(@"\nconnnection_user_id is not a number");
                                }
                            }
                        } else {
                            //                                DLog(@"\nnot a dictionary");
                        }
                    }];
                }
            }
        } else {
            DLog(@"\ninvalid response object");
//            NSLog(@"\ninvalid response object");
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"\nError occurred %ld: %@", error.code, error.localizedDescription);
//        NSLog(@"\nError occurred %@: %@", @(error.code), error.localizedDescription);
    }];
}



















@end
