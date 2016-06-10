//
//  CHAVerticalPathInfo.m
//  GaylordHotels
//
//  Created by MeetingPlay on 4/30/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "CHAVerticalPathInfo.h"
#import "CHAMapLocation.h"

@implementation CHAVerticalPathInfo

+ (instancetype)verticalPath:(CHAMapLocation *)start finish:(CHAMapLocation *)finish travelType:(NSString *)travelType
{
    return [[CHAVerticalPathInfo alloc] initWithStart:start finish:finish travelType:travelType];
}

- (instancetype)initWithStart:(CHAMapLocation *)start finish:(CHAMapLocation *)finish travelType:(NSString *)traveType
{
    if (self = [super init])
    {
        _start = start;
        _finish = finish;
        _travelType = traveType;
    }
    return self;
}

+ (instancetype)verticalPathFromData:(NSDictionary *)verticalPathComponents
{
    CHAMapLocation *start = [verticalPathComponents objectForKey:@"start"];
    CHAMapLocation *finish = [verticalPathComponents objectForKey:@"finish"];
    NSString *travelType = [verticalPathComponents objectForKey:@"travelType"];
    
    CHAVerticalPathInfo *verticalPath;
    if (start && finish && travelType)
    {
        verticalPath = [CHAVerticalPathInfo verticalPath:start
                                                  finish:finish
                                              travelType:travelType];
    }
    else
    {
        verticalPath = [[CHAVerticalPathInfo alloc] init];
    }
    
    return verticalPath;
}

+ (NSDictionary *)extractVerticalPathInfo:(NSString *)verticalDataString
{
    NSArray *pathInfoComponents = [verticalDataString componentsSeparatedByString:@","];
    if (pathInfoComponents.count == 5)
    {
        NSString *startString = pathInfoComponents[0];
        NSDictionary *startData = [CHAMapLocation extractLocationInformationFromString:startString];
        CHAMapLocation *start = [CHAMapLocation mapLocation:startString
                                                xCoordinate:[startData objectForKey:@"x"]
                                                yCoordinate:[startData objectForKey:@"y"]
                                                floorNumber:[startData objectForKey:@"floor"]];
        
        NSString *finishString = pathInfoComponents[1];
        NSDictionary *finishData = [CHAMapLocation extractLocationInformationFromString:finishString];
        CHAMapLocation *finish = [CHAMapLocation mapLocation:finishString
                                                 xCoordinate:[finishData objectForKey:@"x"]
                                                 yCoordinate:[finishData objectForKey:@"y"]
                                                 floorNumber:[finishData objectForKey:@"floor"]];
        
        NSString *travelType;
        NSScanner *typeScanner = [NSScanner scannerWithString:verticalDataString];
        typeScanner.charactersToBeSkipped = [NSCharacterSet characterSetWithCharactersInString:@"{;},[]0123456789"];
        [typeScanner scanCharactersFromSet:[NSCharacterSet letterCharacterSet]
                                intoString:&travelType];
        
        if (start && finish && travelType)
        {
            return @{@"start": start,
                     @"finish": finish,
                     @"travelType": travelType};
        }
    }
    
    return nil;
}

@end