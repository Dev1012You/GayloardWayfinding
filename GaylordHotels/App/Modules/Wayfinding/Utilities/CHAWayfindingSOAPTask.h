//
//  CHAWayfindingSOAPTask.h
//  GaylordHotels
//
//  Created by MeetingPlay on 4/28/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CHADestination;

typedef NS_ENUM(NSUInteger, WayfindingRequestType)
{
    WayfindingRequestTypeGetDestinations = 0,           // Get list of all waypoints marked as destinations
    WayfindingRequestTypeGetGroupedDestinationsAndPOI,  // Get list of all waypoints and POI’s marked as destinations.
    WayfindingRequestTypeGetMapImageByName,             // Returns the map image of the given name from the given UID's server folder.
    WayfindingRequestTypeGetMapImageURLs,               // Returns the list of URLs for a project.
    WayfindingRequestTypeGetMultiFloorImage,            // Returns an image compilation of all floor maps.
    WayfindingRequestTypeGetMultiFloorNodeYOffsets,     // Returns the Y-Offset value for each floor map.
    WayfindingRequestTypeGetPath,                       // Returns Path By Points.
    WayfindingRequestTypeGetPoiImages,                  // Returns only the POI images that are used in the given project.
    WayfindingRequestTypeGetProjectNameFromUniqueID,    // Returns the name of project associated with the given Unique ID.
    WayfindingRequestTypeGetProjectOwnerStatus,         // Get the account status of the project owner for the given project Unique ID.
};

@interface CHAWayfindingSOAPTask : NSObject <NSXMLParserDelegate>

@property (nonatomic, assign) WayfindingRequestType wayfindingRequestType;
@property (nonatomic, strong) NSURLSessionDataTask *dataTask;
@property (nonatomic, strong) id fetchedData;

@property (nonatomic, strong) id <NSXMLParserDelegate> customXMLParser;
@property (nonatomic, copy) void (^defaultXMLParserCompletionHandler)(id fetchedData);

@property (nonatomic, assign) BOOL searchLimitedAccessOnly;

+ (NSString *)projectUniqueID;

- (void)startTask;

- (NSMutableURLRequest *)request:(WayfindingRequestType)requestType
              bodyRequestOptions:(NSDictionary *)bodyRequestOptions;

- (instancetype)initWithRequestType:(WayfindingRequestType)requestType;

#pragma mark - Convenience Initializers

+ (instancetype)getPathStartFloor:(NSNumber *)startFloor
                 startXCoordinate:(NSNumber *)startX
                 startYCoordinate:(NSNumber *)startY
                         endFloor:(NSNumber *)endFloor
                   endXCoordinate:(NSNumber *)endX
                             endY:(NSNumber *)endY;

+ (instancetype)getDestinations:(NSString *)buildingID;

+ (instancetype)getGroupedDestinationsAndPOI:(NSString *)buildingID
                             splitIntoGroups:(BOOL)splitIntoGroups;

+ (instancetype)getMultiFloorNodeYOffsets:(NSString *)buildingID;


@end
