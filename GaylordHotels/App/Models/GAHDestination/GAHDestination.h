//
//  GAHDestination.h
//  GaylordHotels
//
//  Created by MeetingPlay on 5/8/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CHADestination;

@interface GAHDestination : NSObject <NSCoding>

@property (nonatomic, strong) NSString *alt;
@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) NSString *image;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSNumber *locationid;
@property (nonatomic, strong) NSString *slug;
@property (nonatomic, strong) NSString *wfpName;
@property (nonatomic, strong) NSString *roomKey;

// from detailed lookup
@property (nonatomic, strong) NSString *mapImage;
@property (nonatomic, strong) NSString *map;
@property (nonatomic, strong) NSString *mapSlug;
@property (nonatomic, strong) NSArray *details;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSArray *links;
@property (nonatomic, strong) NSArray *promos;
@property (nonatomic, strong) NSArray *images;


//@property (nonatomic, strong) CHADestination *wayfindingDetails;

#pragma mark Updating the model
- (void)updateWithMeetingPlay:(NSDictionary *)meetingPlayDictionary;
- (NSString *)stringOrNil:(id)possibleValue;
+ (GAHDestination *)existingDestination:(NSString *)destinationName inCollection:(NSArray *)collection;

#pragma mark Archiving/Unarchiving
+ (BOOL)archiveDestinationCollection:(NSArray *)destinationCollection;
+ (NSArray *)loadDestinationsFromDisk;
@end
