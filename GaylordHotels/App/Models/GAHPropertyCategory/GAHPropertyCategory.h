//
//  GAHPropertyCategory.h
//  GaylordHotels
//
//  Created by MeetingPlay on 5/25/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GAHPropertyCategory : NSObject
@property (nonatomic, strong) NSString *categoryName;
@property (nonatomic, strong) NSNumber *categoryID;
@property (nonatomic, strong) NSNumber *rank;
@property (nonatomic, strong) NSString *icon;
@property (nonatomic, strong) NSString *slug;

- (void)updateValuesWithDictionary:(NSDictionary *)returnedValues;

@end
