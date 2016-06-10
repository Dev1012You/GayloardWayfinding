//
//  CHAVerticalPathInfo.h
//  GaylordHotels
//
//  Created by MeetingPlay on 4/30/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CHAMapLocation;

@interface CHAVerticalPathInfo : NSObject

@property (nonatomic, strong) CHAMapLocation *start;
@property (nonatomic, strong) CHAMapLocation *finish;
@property (nonatomic, strong) NSString *travelType;

@property (nonatomic, strong) NSString *rawDataString;

+ (instancetype)verticalPath:(CHAMapLocation *)start
                      finish:(CHAMapLocation *)finish
                  travelType:(NSString *)travelType;

- (instancetype)initWithStart:(CHAMapLocation *)start
                       finish:(CHAMapLocation *)finish
                   travelType:(NSString *)traveType;

+ (NSDictionary *)extractVerticalPathInfo:(NSString *)verticalDataString;

+ (instancetype)verticalPathFromData:(NSDictionary *)verticalPathComponents;

@end
