//
//  CHAInstruction.h
//  GaylordHotels
//
//  Created by MeetingPlay on 5/1/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CGGeometry.h>

@interface CHAInstruction : NSObject

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, assign) CGPoint associatedPoint;

+ (instancetype)instructionWithText:(NSString *)instructionText;

- (instancetype)initWithInstructionText:(NSString *)instructionText;

- (NSString *)destinationNameForWayfindingIdentifier:(NSString *)identifier
                             meetingPlayDestinations:(NSArray *)meetingplayDestinations;

@end