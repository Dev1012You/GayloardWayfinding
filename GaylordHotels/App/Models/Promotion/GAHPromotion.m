//
//  GAHPromotion.m
//  GaylordHotels
//
//  Created by John Pacheco on 9/16/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "GAHPromotion.h"

@implementation GAHPromotion

+ (instancetype)promotionWithDictionary:(NSDictionary *)promotionDictionary
{
    GAHPromotion *newPromotion = [GAHPromotion new];
    [newPromotion update:promotionDictionary];
    return newPromotion;
}

- (void)update:(NSDictionary *)newModelData
{
    self.images = [newModelData objectForKey:@"images"];
    self.expired = [[newModelData objectForKey:@"expired"] boolValue];
    
    self.details = [self stringOrNil:[newModelData objectForKey:@"details"]];
    self.name = [self stringOrNil:[newModelData objectForKey:@"name"]];
    self.promoID = [newModelData objectForKey:@"promoid"];
    self.promotion = [self stringOrNil:[newModelData objectForKey:@"promotion"]];
    self.promotionSlug = [self stringOrNil:[newModelData objectForKey:@"slug"]];
    
    self.dateReceived = [NSDate date];
}

- (NSString *)stringOrNil:(id)possibleString
{
    if (possibleString == nil || [possibleString isKindOfClass:[NSString class]])
    {
        return (NSString *)possibleString;
    }
    else if (possibleString)
    {
        return [NSString stringWithFormat:@"%@",possibleString];
    }
    else
    {
        return nil;
    }
}

+ (NSURL *)promotionsSavePath
{
    NSURL *saveDirectory = [[self promotionsSaveDirectory] URLByAppendingPathComponent:[self promotionsFilename]];
    return saveDirectory;
}

+ (NSURL *)promotionsSaveDirectory
{
    NSError *directoryError = nil;
    NSURL *cachesDirectory = [[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:true error:&directoryError];
    return cachesDirectory;
}

+ (NSString *)promotionsFilename
{
    return @"promotions.archive";
}

#pragma mark - NSCoding and NSCopying Protocols

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    GAHPromotion *promotion = [GAHPromotion new];
    promotion.images = [aDecoder decodeObjectForKey:@"images"];
    promotion.expired = [aDecoder decodeBoolForKey:@"expired"];
    
    promotion.details = [aDecoder decodeObjectForKey:@"details"];
    promotion.name = [aDecoder decodeObjectForKey:@"name"];
    promotion.promoID = [aDecoder decodeObjectForKey:@"promoID"];
    promotion.promotion = [aDecoder decodeObjectForKey:@"promotion"];
    promotion.promotionSlug = [aDecoder decodeObjectForKey:@"promotionSlug"];
    
    promotion.dateReceived = [aDecoder decodeObjectForKey:@"dateReceived"];
    promotion.shouldShow = [aDecoder decodeBoolForKey:@"shouldShow"];
    
    return promotion;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.images forKey:@"images"];
    [aCoder encodeBool:self.expired forKey:@"expired"];
    
    [aCoder encodeObject:self.details forKey:@"details"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.promoID forKey:@"promoID"];
    [aCoder encodeObject:self.promotion forKey:@"promotion"];
    [aCoder encodeObject:self.promotionSlug forKey:@"slug"];
    
    [aCoder encodeObject:self.dateReceived forKey:@"dateReceived"];
    [aCoder encodeBool:self.shouldShow forKey:@"shouldShow"];
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    GAHPromotion *promotion = [[GAHPromotion allocWithZone:zone] init];
    
    promotion.images = self.images;
    promotion.expired = self.expired;
    
    promotion.details = self.details;
    promotion.name = self.name;
    promotion.promoID = self.promoID;
    promotion.promotion = self.promotion;
    promotion.promotionSlug = self.promotionSlug;
    
    promotion.dateReceived = self.dateReceived;
    promotion.shouldShow = self.shouldShow;
    
    return promotion;
}

@end
