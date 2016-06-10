//
//  GAHAPIDataInitializer.h
//  GaylordHotels
//
//  Created by MeetingPlay on 5/5/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CGGeometry.h>

@class GAHMapDataSource, MDBeaconManager, SDWebImageManager, GAHDestination, CHADestination, MDCustomTransmitter;

@protocol GAHAPIDataInitializerDelegate <NSObject>
- (void)session:(NSURLSession *)session task:(NSURLSessionTask *)sessionTask didUpdate:(NSMutableDictionary *)downloadOperations;
@end

@interface GAHAPIDataInitializer : NSObject <NSCopying>

@property (nonatomic, strong) GAHMapDataSource *mapDataSource;
@property (nonatomic, strong) NSArray *meetingPlayLocations;
@property (nonatomic, strong) NSArray *meetingPlayCategories;
@property (nonatomic, strong) NSArray *wayfindingBaseLocations;
@property (nonatomic, strong) NSDictionary *meetingPlayMaps;

@property (nonatomic, strong) SDWebImageManager *imageManager;

@property (nonatomic, strong) MDBeaconManager *beaconManager;

@property (nonatomic, assign) BOOL isFetching;

@property (nonatomic, copy) void(^completionHandler)(GAHMapDataSource *mapDataSource, NSError *fetchError);

- (void)fetchInitialAPIData:(void(^)(GAHMapDataSource *mapDataSource, NSError *fetchError))completionHandler;

- (void)fetchDestinations:(void(^)(GAHMapDataSource *mapDataSource, NSError *mapFetchError))completionHandler;
- (void)fetchMapImageURLs:(void(^)(GAHMapDataSource *mapDataSource, NSError *mapFetchError))completionHandler;
- (void)fetchMapImageURLsForceRefetch:(BOOL)forceFetch completionHandler:(void(^)(GAHMapDataSource *mapDataSource, NSError *mapFetchError))completionHandler;

- (void)fetchMeetingPlayLocations:(void(^)(NSArray *locations,NSError *fetchError))completionHandler;
- (void)fetchCategories:(void(^)(NSArray *categories))successHandler errorHandler:(void(^)(NSError *fetchError))errorHandler;

- (void)forceReload;

- (NSNumber *)floorForMapName:(NSString *)meetingPlayMapName;
- (NSString *)mapSlugForMapID:(NSNumber *)mapID;

- (CHADestination *)findNearestDestination:(MDCustomTransmitter *)transmitter;
- (CGPoint)coordinatesForTransmitter:(MDCustomTransmitter *)transmitter;
- (GAHDestination *)destinationClosestToPoint:(CGPoint)targetCoordinates targetFloor:(NSNumber *)targetFloor;

@end
