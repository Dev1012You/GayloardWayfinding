//
//  GAHPropertyCategory.m
//  GaylordHotels
//
//  Created by MeetingPlay on 5/25/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "GAHPropertyCategory.h"

@implementation GAHPropertyCategory

- (void)updateValuesWithDictionary:(NSDictionary *)returnedValues
{
    self.categoryName = [[returnedValues objectForKey:@"category"] isKindOfClass:[NSString class]] ? [returnedValues objectForKey:@"category"] : nil;
    self.categoryID = [[returnedValues objectForKey:@"categoryid"] isKindOfClass:[NSNumber class]] ? [returnedValues objectForKey:@"categoryid"] : nil;
    self.rank = [[returnedValues objectForKey:@"rank"] isKindOfClass:[NSNumber class]] ? [returnedValues objectForKey:@"rank"] : nil;
    self.icon = [[returnedValues objectForKey:@"icon"] isKindOfClass:[NSString class]] ? [returnedValues objectForKey:@"icon"] : nil;
    self.slug = [[returnedValues objectForKey:@"slug"] isKindOfClass:[NSString class]] ? [returnedValues objectForKey:@"slug"] : nil;
}

@end
