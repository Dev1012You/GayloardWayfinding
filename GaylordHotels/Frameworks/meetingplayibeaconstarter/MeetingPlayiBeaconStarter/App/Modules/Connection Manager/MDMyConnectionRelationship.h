//
//  MDMyConnectionRelationship.h
//  MarriottDigitalSummit
//
//  Created by John Pacheco on 5/8/14.
//  Copyright (c) 2014 Grumble Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MDMyConnectionRelationship : NSObject <NSCopying,NSCoding>
@property (nonatomic, copy) NSString *relationshipStatus;
@property (strong, nonatomic) NSNumber *userID;

+(instancetype)relationshipFor:(NSNumber*)userID withStatus:(NSString*)relationshipStatus;
-(instancetype)initWith:(NSNumber *)userID withStatus:(NSString *)relationshipStatus;
@end
