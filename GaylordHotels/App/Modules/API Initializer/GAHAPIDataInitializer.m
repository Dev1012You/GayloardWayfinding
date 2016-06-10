//
//  GAHAPIDataInitializer.m
//  GaylordHotels
//
//  Created by MeetingPlay on 5/5/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "GAHAPIDataInitializer.h"
#import "CHAWayfindingSOAPTask.h"

#import "GAHDestination+Helpers.h"

#import "GAHMapDataSource.h"
#import "CHAMapImage.h"
#import "CHADestination+HelperMethods.h"
#import "GAHPropertyCategory.h"

#import "MDBeaconManager.h"
#import "MDCustomTransmitter+NetworkingHelper.h"

#import "NSObject+EventDefaultsHelpers.h"
#import "NSURLSession+MTPCategory.h"
#import "NSMutableURLRequest+MTPCategory.h"
#import "NSObject+MTPFileManager.h"

#import "SDWebImageManager.h"
#import "MBProgressHUD.h"

@interface GAHAPIDataInitializer ()
@end

@implementation GAHAPIDataInitializer

- (instancetype)init
{
    if (self = [super init])
    {
        _meetingPlayLocations = [NSArray new];
        
        _mapDataSource = [GAHMapDataSource new];

        _mapDataSource.mapImageData = [CHAMapImage mapImagesFromDisk];
        
        _wayfindingBaseLocations = _mapDataSource.mapDestinations;
        if (_wayfindingBaseLocations.count > 0)
        {
            NSLog(@"successfully loaded locations");
        }
        else
        {
            _wayfindingBaseLocations = [NSArray new];
        }
        
        _meetingPlayCategories = [NSArray new];
        
        _imageManager = [SDWebImageManager sharedManager];
        [[_imageManager imageCache] setShouldCacheImagesInMemory:false];
        [[_imageManager imageCache] setMaxMemoryCountLimit:4];
        [[_imageManager imageDownloader] setShouldDecompressImages:false];

    }
    return self;
}

- (void)fetchInitialAPIData:(void (^)(GAHMapDataSource *, NSError *fetchError))completionHandler
{
    [self fetchDestinations:completionHandler];
    
    [self fetchCategories:nil errorHandler:nil];
    
    [self fetchMapImageURLs:completionHandler];
    
    [self mapScales];
    
    [self mapInfo];
}

- (void)forceReload
{
    [self fetchInitialAPIData:nil];
}

- (void)mapInfo
{
    
}

- (void)fetchDestinations:(void(^)(GAHMapDataSource *mapDataSource, NSError *mapFetchError))completionHandler
{
    CHAWayfindingSOAPTask *getDestinations = [CHAWayfindingSOAPTask getDestinations:nil];
    
    __weak __typeof(&*self)weakSelf = self;
    getDestinations.defaultXMLParserCompletionHandler = ^(id fetchedData)
    {
        NSError *fetchDataError = nil;
        if (fetchedData)
        {
            NSArray *fetchedDestinationCollection = [CHADestination createDestinationCollection:fetchedData];
            if ([CHADestination saveDestinationCollection:fetchedDestinationCollection] == false)
            {
                DLog(@"\nerror archiving destinations");
            }
            weakSelf.wayfindingBaseLocations = fetchedDestinationCollection;
            weakSelf.mapDataSource.mapDestinations = weakSelf.wayfindingBaseLocations;
        }
        else
        {
            fetchDataError = [NSError errorWithDomain:@"com.MeetingPlay.GaylordHotels" code:1000 userInfo:@{NSLocalizedDescriptionKey: @"WayfindingPro Destination fetch failed: No data"}];
            if (completionHandler)
            {
                completionHandler(nil,fetchDataError);
            }
        }

    };
    
    [getDestinations startTask];

}
#pragma mark - Map Fetching
- (void)fetchMapImageURLs:(void(^)(GAHMapDataSource *mapDataSource, NSError *mapFetchError))completionHandler
{
    [self fetchMapImageURLsForceRefetch:false completionHandler:completionHandler];
    
}

- (void)fetchMapImageURLsForceRefetch:(BOOL)forceFetch completionHandler:(void(^)(GAHMapDataSource *mapDataSource, NSError *mapFetchError))completionHandler;
{
    CHAWayfindingSOAPTask *getMapImageURLs = [[CHAWayfindingSOAPTask alloc]
                                              initWithRequestType:WayfindingRequestTypeGetMapImageURLs];
    __weak __typeof(&*self)weakSelf = self;
    getMapImageURLs.defaultXMLParserCompletionHandler = ^(id fetchedData)
    {
        NSError *fetchDataError = nil;
        if (fetchedData)
        {
            NSArray *mapData = [CHAMapImage processMapImageURLData:fetchedData];
            
            for (CHAMapImage *mapDetails in mapData)
            {
                __weak CHAMapImage *weakMapDetails = mapDetails;
                NSURL *mapImageURL = [weakMapDetails fullMapImageURL];
                [weakSelf.imageManager downloadImageWithURL:mapImageURL
                                                    options:SDWebImageContinueInBackground
                                                   progress:nil
                                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL)
                {
                    if (error)
                    {
                        DLog(@"\nerror occurred downloading map %@", error);
                    }
                }];
            }
            
            if ([CHAMapImage saveMapDataCollection:mapData])
            {
                NSLog(@"archived map image data");
            }
            
            weakSelf.mapDataSource.mapImageData = mapData;
        }
        else
        {
            fetchDataError = [NSError errorWithDomain:@"com.MeetingPlay.GaylordHotels"
                                                 code:1000
                                             userInfo:@{NSLocalizedDescriptionKey: @"MapImageFetch failed: No data"}];
        }
        
        if (completionHandler)
        {
            completionHandler(weakSelf.mapDataSource,fetchDataError);
        }
    };
    
    [getMapImageURLs startTask];
}


#pragma mark - Category Fetching
- (void)fetchCategories:(void(^)(NSArray *categories))successHandler errorHandler:(void(^)(NSError *fetchError))errorHandler
{
    NSString *requestURL = [self categoriesURL];
    NSMutableURLRequest *categoriesRequest = [NSURLSession defaultRequestMethod:@"GET"
                                                                            URL:requestURL
                                                                     parameters:nil];
    __weak __typeof(&*self)weakSelf = self;
    [self sendRequest:categoriesRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        id responseObject = [NSURLSession serializeJSONData:data response:response error:error];
        if ([responseObject isKindOfClass:[NSDictionary class]])
        {
            NSDictionary *apiData = [responseObject objectForKey:@"data"];
            if (apiData)
            {
                id categoryCollection = [apiData objectForKey:@"categories"];
                if (categoryCollection && [categoryCollection isKindOfClass:[NSArray class]])
                {
                    NSMutableArray *fetchedCategories = [NSMutableArray new];
                    [categoryCollection enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
                     {
                         if ([obj isKindOfClass:[NSDictionary class]])
                         {
                             GAHPropertyCategory *newCategory = [GAHPropertyCategory new];
                             [newCategory updateValuesWithDictionary:obj];
                             [fetchedCategories addObject:newCategory];
                         }
                     }];
                    weakSelf.meetingPlayCategories = [NSArray arrayWithArray:fetchedCategories];
                }
                
                if (successHandler)
                {
                    successHandler(weakSelf.meetingPlayCategories);
                }
            }
        }
        else
        {
            if (errorHandler)
            {
                errorHandler([NSError errorWithDomain:([NSURLSession bundleIdentifier]?[NSURLSession bundleIdentifier]:@"com.MeetingPlay.GaylordHotels")
                              code:1012
                                             userInfo:@{NSLocalizedDescriptionKey: @"Failed category fetch"}]);
            }
        }
    }];
}

- (void)fetchMeetingPlayLocations:(void(^)(NSArray *locations,NSError *fetchError))completionHandler
{
    NSString *requestURL = [self urlForCategory:GAHDataCategoryFeatured];
    NSMutableURLRequest *featuredReqeuest = [NSURLSession defaultRequestMethod:@"GET"
                                                                   URL:requestURL
                                                            parameters:nil];
    featuredReqeuest.timeoutInterval = 20;

    __weak __typeof(&*self)weakSelf = self;
    [self sendRequest:featuredReqeuest
    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error)
        {
            if (completionHandler)
            {
                completionHandler(weakSelf.meetingPlayLocations,error);
            }
        }
        else
        {
            id responseObject = [NSURLSession serializeJSONData:data response:response error:error];
            if ([responseObject isKindOfClass:[NSDictionary class]])
            {
                NSDictionary *apiData = [responseObject objectForKey:@"data"];
                if (apiData)
                {
                    NSString *baseImageURL = [[apiData objectForKey:@"image_url"] objectForKey:@"locations"];
                    if (baseImageURL.length > 0)
                    {
                        [weakSelf.userDefaults setObject:[NSString stringWithFormat:@"%@/",baseImageURL] forKey:@"GAHLocationImageURL"];
                    }
                    
                    NSArray *locations = [apiData objectForKey:@"locations"];
                    if (locations.count > 0)
                    {
                        NSMutableArray *newFetchedDestinations = [NSMutableArray new];
                        
                        for (NSDictionary *mpObject in locations)
                        {
                            NSString *locationName = [mpObject objectForKey:@"location"];
                            if (locationName.length > 0)
                            {
                                GAHDestination *destination = [GAHDestination new];
                                [newFetchedDestinations addObject:destination];
                                [destination updateWithMeetingPlay:mpObject];
                            }
                        }
                        
                        weakSelf.meetingPlayLocations = [NSArray arrayWithArray:newFetchedDestinations];
                    }
                }
                
                if (completionHandler)
                {
                    completionHandler(weakSelf.meetingPlayLocations,error);
                }
            }
        }
    }];
}

- (void)sendRequest:(NSURLRequest *)request
  completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler
{
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:completionHandler] resume];
}

- (NSString *)categoriesURL
{
    return @"http://mapsapi.meetingplay.com/property/3/categories";
}

- (NSString *)urlForCategory:(GAHDataCategory)dataCategory
{
    NSDictionary *urlDictionary = @{@(GAHDataCategoryFeatured): @"http://mapsapi.meetingplay.com/property/3/locations/all"};
    
    return urlDictionary[@(dataCategory)];
}

#pragma mark - Map Utilities
- (NSNumber *)floorForMapName:(NSString *)meetingPlayMapName
{
    __block NSNumber *floor = nil;
    [self.mapDataSource.mapImageData enumerateObjectsUsingBlock:^(CHAMapImage *obj, NSUInteger idx, BOOL *stop) {
        NSString *wfpMapName = [obj floorName];
        if ([meetingPlayMapName caseInsensitiveCompare:wfpMapName] == NSOrderedSame)
        {
            floor = [obj floorNumber];
        }
    }];
    
    return floor;
}

- (NSString *)mapSlugForMapID:(NSNumber *)mapID
{
    NSDictionary *mapInfo = [self.meetingPlayMaps objectForKey:mapID];
    NSString *mapName = [mapInfo objectForKey:@"slug"];
    mapName = [mapName stringByReplacingOccurrencesOfString:@"-gyn" withString:@""];
    return mapName;
}

- (NSURL *)fullMapImageURL:(NSString *)imageURL
{
    NSString *baseURL = @"http://api.wayfindingpro.com";
    NSURL *url = [NSURL URLWithString:[[NSString stringWithFormat:@"%@%@",baseURL,imageURL] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    return imageURL ? url : nil;
}

- (void)mapScales
{
    NSMutableURLRequest *mapScales = [NSMutableURLRequest defaultRequestMethod:@"GET" URL:@"http://deploy.meetingplay.com/gaylord/mapscales.json" parameters:nil];
    mapScales.cachePolicy = NSURLRequestReloadIgnoringCacheData;
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:mapScales completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error)
        {
            DLog(@"\nmapscale fetch error %@", error);
        }
        else
        {
            id responseArray = [NSURLSession serializeJSONData:data response:response error:error];
            if ([responseArray isKindOfClass:[NSArray class]])
            {
                NSMutableDictionary *mapScales = [NSMutableDictionary dictionaryWithDictionary:[[self.userDefaults objectForKey:@"MTP_BaseOptions"] objectForKey:@"GAH_MapScales"]];
                
                for (NSDictionary *responseObject in responseArray)
                {
                    [responseObject enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                        [mapScales setObject:obj forKey:key];
                    }];
                }
                
                NSMutableDictionary *baseOptions = [NSMutableDictionary dictionaryWithDictionary:[self.userDefaults objectForKey:@"MTP_BaseOptions"]];
                [baseOptions setObject:mapScales forKey:@"GAH_MapScales"];
                
                [self.userDefaults setObject:baseOptions forKey:@"MTP_BaseOptions"];
                
                [self.userDefaults synchronize];
            }
        }
    }] resume];
}


- (NSArray *)mapInformation
{
    if (self.meetingPlayMaps)
    {
        return self.meetingPlayMaps;
    }
    else
    {
        NSMutableURLRequest *mapRequest = [NSMutableURLRequest defaultRequestMethod:@"GET" URL:@"http://mapsapi.meetingplay.com/property/3/maps/all" parameters:nil];
        return nil;
    }
}

#pragma mark - etc
- (CHADestination *)findNearestDestination:(MDCustomTransmitter *)transmitter
{
    if (transmitter.placed)
    {
        // placed == true, means that the location is a Map Beacon
        NSString *userCurrentMap = [self mapSlugForMapID:transmitter.fkMapID];
        if (userCurrentMap.length > 0)
        {
            userCurrentMap = [userCurrentMap stringByReplacingOccurrencesOfString:@"-gyn" withString:@""];
        }
        NSNumber *userFloor = [self floorForMapName:userCurrentMap];
        
        CGPoint mapAxisMultiplier = [CHADestination mapAxisMultiplierForFloor:userFloor mapDataSource:self.mapDataSource];
        
        CGPoint beaconCoordinates = CGPointMake((transmitter.placementX.floatValue * mapAxisMultiplier.x) + 30,
                                                (transmitter.placementY.floatValue * mapAxisMultiplier.y) + 35);
        
        CHADestination *closestNavigablePoint = [CHADestination nearestDestinationToPoint:beaconCoordinates onFloor:userFloor mapDestinations:self.mapDataSource.mapDestinations];
        
        return closestNavigablePoint;
    }
    else
    {
        return nil;
    }
}

- (CGPoint)coordinatesForTransmitter:(MDCustomTransmitter *)transmitter floor:(NSNumber *)userFloor
{
    CGPoint mapAxisMultiplier = [CHADestination mapAxisMultiplierForFloor:userFloor
                                                            mapDataSource:self.mapDataSource];
    
    CGPoint beaconCoordinates = CGPointMake((transmitter.placementX.floatValue * mapAxisMultiplier.x) + 30,
                                            (transmitter.placementY.floatValue * mapAxisMultiplier.y) + 35);
    
    return beaconCoordinates;
}

- (GAHDestination *)destinationClosestToPoint:(CGPoint)targetCoordinates targetFloor:(NSNumber *)targetFloor
{
    __block GAHDestination *nearestDestination = nil;
    NSArray *nearestPoints = [CHADestination nearestDestinationsToPoint:targetCoordinates
                                                                onFloor:targetFloor
                                                        mapDestinations:self.mapDataSource.mapDestinations];
    
    [nearestPoints enumerateObjectsUsingBlock:^(CHADestination *destination, NSUInteger idx, BOOL *stop) {
        
        GAHDestination *possibleMatch = [[GAHDestination destinationsForBaseLocation:destination.destinationName
                                                               meetingPlayLocations:self.meetingPlayLocations] firstObject];
        if (possibleMatch)
        {
            nearestDestination = possibleMatch;
            *stop = true;
        }
    }];
    
    return nearestDestination;
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    GAHAPIDataInitializer *dataCopy = [[GAHAPIDataInitializer allocWithZone:zone] init];
    
    dataCopy.mapDataSource = self.mapDataSource;
    dataCopy.meetingPlayLocations = self.meetingPlayLocations;
    dataCopy.meetingPlayCategories = self.meetingPlayCategories;
    dataCopy.wayfindingBaseLocations = self.wayfindingBaseLocations;
    dataCopy.meetingPlayMaps = self.meetingPlayMaps;
    dataCopy.beaconManager = self.beaconManager;
    dataCopy.completionHandler = self.completionHandler;
 
    return dataCopy;
}
@end
