//
//  GAHPromotion.h
//  GaylordHotels
//
//  Created by John Pacheco on 9/16/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GAHPromotion : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSString *details;
@property (nonatomic, assign) BOOL expired;
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *promoID;
@property (nonatomic, strong) NSString *promotion;
@property (nonatomic, strong) NSString *promotionSlug;

@property (nonatomic, strong) NSDate *dateReceived;
@property (nonatomic, assign) BOOL shouldShow;

+ (instancetype)promotionWithDictionary:(NSDictionary *)promotionDictionary;

- (void)update:(NSDictionary *)newModelData;

+ (NSURL *)promotionsSavePath;
+ (NSURL *)promotionsSaveDirectory;
+ (NSString *)promotionsFilename;

@end
