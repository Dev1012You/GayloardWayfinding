//
//  CHADirectionSet.m
//  GaylordHotels
//
//  Created by MeetingPlay on 5/1/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "CHADirectionSet.h"
#import "CHAInstruction.h"

@implementation CHADirectionSet

+ (instancetype)directionsFromData:(NSArray *)directionData
{
    NSDictionary *directionComponents = [self extractDirectionInformation:directionData];
    
    NSArray *directions = [directionComponents objectForKey:@"directionSet"];
    BOOL singleElevatorPath = [directionComponents objectForKey:@"singleElevatorPath"];
    NSString *rawDirections = [directionComponents objectForKey:@"rawDirections"];
    
    return [[CHADirectionSet alloc] initWithDirections:directions
                                    singleElevatorPath:singleElevatorPath
                                         rawDirections:rawDirections];
}

- (instancetype)initWithDirections:(NSArray *)directions
                singleElevatorPath:(BOOL)singleElevatorPathUsed
                     rawDirections:(NSString *)rawDirections
{
    if (self = [super init])
    {
        _directionSet = directions;
        _singleElevatorPathUsed = singleElevatorPathUsed;
        _rawDirections = rawDirections;
    }
    return self;
}

+ (NSDictionary *)extractDirectionInformation:(NSArray *)directionData
{
    NSMutableDictionary *directions = [NSMutableDictionary new];
    
    __block NSString *directionText;
    __block NSNumber *singleElevatorPathUsed;
    
    [directionData enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         if (![obj isKindOfClass:[NSDictionary class]]) return;
         
         [obj enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
          {
              if (![key isKindOfClass:[NSString class]])
              {
                  return;
              }
              
              if ([key isEqualToString:@"Text"])
              {
                  directionText = obj;
              }
              else if ([key isEqualToString:@"isSingleElevatorPathUsed"])
              {
                  if (![obj isKindOfClass:[NSString class]])
                  {
                      return;
                  }
                  
                  singleElevatorPathUsed = [[obj lowercaseString] isEqualToString:@"false"] ? @(false) : @(true);
              }
          }];
     }];
    
    __block NSMutableArray *instructions = [NSMutableArray new];
    
    if (directionText)
    {
        [directions setObject:directionText forKey:@"rawDirections"];
        
        NSString *substitutedText = [self substituteInstructions:directionText];
        directionText = substitutedText;
        
        NSArray *directionSet = [directionText componentsSeparatedByString:@";"];
        if (directionSet)
        {
            [directionSet enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if ([obj isKindOfClass:[NSString class]])
                {
                    CHAInstruction *newInstruction = [CHAInstruction instructionWithText:obj];
                    if (newInstruction)
                    {
                        /* now removing this text one step before this in -(void)directionInfo:
                         
                        if ([newInstruction.text.lowercaseString rangeOfString:@"arrive at floor #"].length > 0 ||
                            [newInstruction.text.lowercaseString rangeOfString:@"departing floor #"].length > 0)
                        {
//                            NSLog(@"\nelevatorInstruction %@", newInstruction.text);
                        }
                        else
                        {
                            [instructions addObject:newInstruction];
                        }
                         */
                        [instructions addObject:newInstruction];
                    }
                }
            }];
            if (instructions.count > 0)
            {
                [directions setObject:instructions forKey:@"directionSet"];
            }
        }
    }
    
    if (singleElevatorPathUsed)
    {
        [directions setObject:singleElevatorPathUsed forKey:@"singleElevatorPath"];
    }
    
    return directions;
}

+ (NSString *)substituteInstructions:(NSString *)rawDirection
{
    NSString *substitutedText = [rawDirection stringByReplacingOccurrencesOfString:@";Continue" withString:@" then go straight"];
    substitutedText = [self changeExitText:substitutedText];
    substitutedText = [self lowercaseLeftRight:substitutedText];
    return substitutedText;
}

+ (NSString *)changeExitText:(NSString *)exitText
{
    if (exitText.length > 0)
    {
        exitText = [exitText stringByReplacingOccurrencesOfString:@"Exit" withString:@"Proceed from"];
    }
    return exitText;
}

+ (NSString *)lowercaseLeftRight:(NSString *)targetString
{
    if (targetString.length > 0)
    {
        targetString = [targetString stringByReplacingOccurrencesOfString:@"Left" withString:@"left"];
        targetString = [targetString stringByReplacingOccurrencesOfString:@"Right" withString:@"right"];
        targetString = [targetString stringByReplacingOccurrencesOfString:@"Slight" withString:@"slight"];
    }
    return targetString;
}

@end