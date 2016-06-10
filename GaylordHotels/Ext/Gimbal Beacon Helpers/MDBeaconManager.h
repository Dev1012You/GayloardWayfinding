//
//  MDBeaconManager.h
//  MarriottDigitalSummit
//
//  Created by John Pacheco on 4/30/14.
//  Copyright (c) 2014 Grumble Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MDCustomTransmitter, User, MTPSessionManager, GMBLBeacon, MTPAlertManager;

@protocol MDBeaconDebugDelegate <NSObject>
-(void)didFinishCompare:(NSDictionary*)beaconDescriptions;
-(void)updateRSSILabels;
@end

@interface MDBeaconManager : NSObject
/**
 The object in this property will receive debugging information about n=RELEVANT_BEACON_COUNT nearby beacons and the closest beacon
 */
@property (weak, nonatomic) id <MDBeaconDebugDelegate> debugDelegate;
@property (strong, nonatomic) MDCustomTransmitter *activeBeacon;
@property (strong, nonatomic) NSMutableArray *nearbyBeacons;
@property (strong, nonatomic) NSMutableArray *seenBeacons;
@property (strong, nonatomic) NSMutableArray *allBeacons;

@property (nonatomic, strong) MTPSessionManager *sessionManager;
@property (strong, nonatomic) User *currentUser;
@property (strong, nonatomic) MTPAlertManager *alertManager;

/**
 @description Retrieve all of the active beacons associated with the event from the API
 */
-(void)getEventBeacons;
- (void)getEventBeacons:(void(^)(NSArray *fetchedBeacons))completionHandler;
/**
 @description Checks to see if the beacon exists using its ID and adds it if not already added
 @param beacon The beacon to add
 @param shouldUpdate YES will call transmitBeaconData after it adds a beacon
 @see transmitBeaconData:
 */
-(void)addBeacon:(GMBLBeacon *)beacon shouldUpdate:(BOOL)shouldUpdate;
/**
 @description Checks to see if the beacon exists using its ID and adds it if not already added. There is a subsequent call to addBeacon:shouldUpdate: where shouldUpdate is NO
 @param beacon The beacon to add
 @see transmitBeaconData:
 */
-(void)addBeacon:(GMBLBeacon *)beacon;
/**
 @description Search for a beacon by its ID
 @param beaconID The beacon's ID
 @return A beacon matching the query; nil if none or more than one were found
 */
-(MDCustomTransmitter*)findBeacon:(NSString*)beaconID;
/**
 @description Update the RSSI for a beacon. NOTE: Sometimes we don't get the didArrive: which means addBeacon: never gets called.
 @param rssi The RSSI strength for a beacon
 @param beaconID The ID of the beacon to update
 @return YES if the beacon updated; if the beacon is not found it returns NO
 */
-(BOOL)updateRSSI:(NSNumber*)rssi forBeacon:(NSString*)beaconID;
/**
 @description Batch update several beacon's RSSI values
 @param beaconsWithRSSI A dictionary that contains IDs and their RSSI
 */
-(void)batchUpdateRSSIForBeacons:(NSDictionary*)beaconsWithRSSI;
/**
 @description Compare the strengths of the beacons in a collection
 @param beaconCollection The collection of beacons to compare
 @return A collection of beacons with the strongest signal
 @see RELEVANT_BEACON_COUNT in MDConstants.h
 */
-(NSArray*)compareBeacons:(NSArray*)beaconCollection;
/**
 @description Compare the strengths of the beacons in the nearbyBeacons collection
 */
-(void)compareBeacons;
-(MDCustomTransmitter *)identifyActiveBeacon;
/**
 @description Remove a single beacon
 @param beaconID The ID of the beacon to remove
 @return YES if the beacon was removed successfully
 */
-(BOOL)removeBeacon:(NSString*)beaconID;
/**
 @description Removes all of the beacons in array of nearby beacons
 */
-(void)flushBeacons;
/**
 @description Uploads the relevant data of beacons to the sever
 @param beaconCollection The collection of beacons whose information will be sent to the web service
 @param updateType The type of request you would like to make
 */
-(void)transmitBeaconData:(NSArray*)beaconCollection updateType:(NSString*)updateType;
/**
 @description Uploads the relevant data of beacons to the sever
 @param beaconCollection The collection of beacons whose information will be sent to the web service
 */
-(void)transmitBeaconData:(NSArray*)beaconCollection;
/**
 @description Retrieves any data or information associated with the beacon
 @param beaconCollection The IDs of the beacons for which you want to receive data
 @param successBlock Methods to invoke upon successfully retrieving data
 @param failureBlock Methods to invoke upon unsuccessfully retrieving data
 */
//-(void)getBeaconEvents:(NSArray*)beaconCollection success:(voidBlock)successBlock failure:(voidBlock)failureBlock;
- (void)sendGET:(NSString*)requestType toAPIUrl:(NSString*)apiURL withParameters:(NSDictionary*)parameters;
@end
