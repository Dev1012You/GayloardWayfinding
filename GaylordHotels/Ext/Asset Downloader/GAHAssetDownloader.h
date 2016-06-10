//
//  GAHAssetDownloader.h
//  GaylordHotels
//
//  Created by John Pacheco on 7/16/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GAHMapDataSource;

@interface GAHAssetDownloader : NSObject

@property (nonatomic, strong) NSArray *meetingPlayLocations;
@property (nonatomic, strong) GAHMapDataSource *mapDataSource;

- (void)fetchMeetingPlayLocations:(void(^)(NSArray *meetingPlayLocations, NSError *fetchError))completionHandler;
- (void)fetchMapDataSource:(void(^)(GAHMapDataSource *mapData, NSError *mapDataFetchError))completionHandler;

@end
