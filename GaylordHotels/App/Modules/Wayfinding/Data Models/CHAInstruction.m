//
//  CHAInstruction.m
//  GaylordHotels
//
//  Created by MeetingPlay on 5/1/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "CHAInstruction.h"
#import "GAHDestination.h"

@implementation CHAInstruction

+ (instancetype)instructionWithText:(NSString *)instructionText
{
    return [[CHAInstruction alloc] initWithInstructionText:instructionText];
}

- (instancetype)initWithInstructionText:(NSString *)instructionText
{
    if (self = [super init])
    {
        _text = instructionText;
    }
    return self;
}


- (NSString *)destinationNameForWayfindingIdentifier:(NSString *)identifier
                             meetingPlayDestinations:(NSArray *)meetingplayDestinations
{
    __block NSString *destinationName;
    [meetingplayDestinations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        if ([obj isKindOfClass:[GAHDestination class]])
        {
            if ([[(GAHDestination *)obj slug] caseInsensitiveCompare:identifier] == NSOrderedSame)
            {
                destinationName = [obj location];
                *stop = true;
            }
        }
    }];
    return destinationName;
}
@end