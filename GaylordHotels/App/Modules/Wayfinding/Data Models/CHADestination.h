//
//  CHADestination.h
//  GaylordHotels
//
//  Created by MeetingPlay on 4/28/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CGGeometry.h>
#
@interface CHADestination : NSObject <NSCoding>

@property (nonatomic, strong) NSNumber *buildingID; // = 0;
@property (nonatomic, strong) NSString *category; // = "";
@property (nonatomic, strong) NSString *destinationDescription; // = "";
@property (nonatomic, strong) NSNumber *floorNumber; // = 1;
@property (nonatomic, strong) NSNumber *isAltDestName; // = False;
@property (nonatomic, strong) NSNumber *isKiosk; // = False;
@property (nonatomic, strong) NSString *parentType; // = floor;
@property (nonatomic, strong) NSNumber *isWayPoint; // = True;
@property (nonatomic, strong) NSString *destinationName; // = "Solaris Deck";
@property (nonatomic, strong) NSNumber *visible; // = true;
@property (nonatomic, strong) NSNumber *xCoordinate; // = "1071.11103579273";
@property (nonatomic, strong) NSNumber *yCoordinate; // = "681.870845830849";

@property (nonatomic, strong) NSDictionary *details;

+ (instancetype)destinationWithData:(NSDictionary *)dataDictionary;

- (instancetype)initWithData:(NSDictionary *)dataDictionary;

- (void)updateWithData:(NSDictionary *)dataDictionary;

- (CGPoint)mapLocation:(BOOL)shouldRound;


// convenience for creating collections
+ (NSArray *)createDestinationCollection:(NSArray *)destinationCollection;
+ (NSArray *)destinationsFromDisk;
+ (BOOL)saveDestinationCollection:(NSArray *)destinations;
+ (NSString *)archiveFilename;
@end
