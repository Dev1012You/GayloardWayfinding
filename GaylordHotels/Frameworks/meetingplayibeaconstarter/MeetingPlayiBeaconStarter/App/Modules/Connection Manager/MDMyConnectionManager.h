//
//  MDMyConnectionManager.h
//  MarriottDigitalSummit
//
//  Created by John Pacheco on 5/7/14.
//  Copyright (c) 2014 Grumble Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface MDMyConnectionManager : NSObject

@property (strong, nonatomic) NSMutableSet *connections;

+ (instancetype)connectionManager:(NSManagedObjectContext *)managedObjectContext;
/**
 @description Adds a connection but with a connected relationship status
 @param userID The userID of the person to add
 */
-(void)addMyConnection:(NSNumber*)userID;
/**
 @description Adds a connection
 @param userID The userID of the person to add
 */
-(void)addMyConnection:(NSNumber*)userID withStatus:(NSString*)relationshipStatus;
/**
 @description Changes the status between the local user and the target user. It also checks if the user exists or not. If not, it will add the user with the indicated relationship status
 @param userID The userID of the target user
 @param relationshipStatus The relationship staus to which it will change
 */
-(void)changeMyConnectionStatus:(NSNumber*)userID toStatus:(NSString*)newStatus;
/**
 @description Removes a connection associated wit the local user
 @param userID The userID targeted for removal
 @return YES if the person was removed successfully
 */
-(BOOL)removeMyConnection:(NSNumber*)userID;
/**
 @description Checks for a user in the current connections
 @param userID The userID of the person in question
 @return The relationship status of the person in question and the local user or nil if no user is found
 */
-(NSString*)checkMyConnectionFor:(NSNumber*)userID;
/**
 @description Retrieve the users whose connection is pending
 @return Arrary of userID's or nil if no users are found
 */
-(NSArray*)connected;
/**
 @description Retrieve the users whose connection is pending
 @return Arrary of userID's or nil if no users are found
 */
-(NSArray*)pending;
/**
 @description Save the connection list
 */
-(void)save;
/**
 @description delete all connections
 */
-(void)flushAll;

-(void)deleteRelationshipsFile;
-(void)updateConnectionsFromApi;
@end
