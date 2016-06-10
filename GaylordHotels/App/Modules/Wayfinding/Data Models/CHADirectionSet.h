//
//  CHADirectionSet.h
//  GaylordHotels
//
//  Created by MeetingPlay on 5/1/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CHADirectionSet : NSObject

@property (nonatomic, strong) NSString *rawDirections;
@property (nonatomic, strong) NSArray *directionSet;
@property (nonatomic, assign) BOOL singleElevatorPathUsed;

+ (instancetype)directionsFromData:(NSArray *)directionData;

- (instancetype)initWithDirections:(NSArray *)directions
                singleElevatorPath:(BOOL)singleElevatorPathUsed
                     rawDirections:(NSString *)rawDirections;

+ (NSDictionary *)extractDirectionInformation:(NSArray *)directionData;

@end

