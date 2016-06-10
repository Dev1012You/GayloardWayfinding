//
//  MDMyConnectionRelationship.m
//  MarriottDigitalSummit
//
//  Created by John Pacheco on 5/8/14.
//  Copyright (c) 2014 Grumble Apps. All rights reserved.
//

#import "MDMyConnectionRelationship.h"

@implementation MDMyConnectionRelationship

+ (instancetype)relationshipFor:(NSNumber *)userID withStatus:(NSString *)relationshipStatus {
    MDMyConnectionRelationship *relationship = [[MDMyConnectionRelationship alloc] initWith:userID withStatus:relationshipStatus];
    return relationship;
}

- (instancetype)initWith:(NSNumber *)userID withStatus:(NSString *)relationshipStatus {
    self = [super init];
    if (self) {
        _userID = userID;
        _relationshipStatus = relationshipStatus;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    MDMyConnectionRelationship *relationship = [[self class] allocWithZone:zone];
    relationship.userID = self.userID;
    relationship.relationshipStatus = self.relationshipStatus;
    
    return relationship;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_userID forKey:@"userID"];
    [aCoder encodeObject:_relationshipStatus forKey:@"relationshipStatus"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        [self setUserID:[aDecoder decodeObjectForKey:@"userID"]];
        [self setRelationshipStatus:[aDecoder decodeObjectForKey:@"relationshipStatus"]];
    }
    return self;
}













@end
