//
//  NSMutableURLRequest+MTPCategory.h
//  GaylordHotels
//
//  Created by John Pacheco on 7/23/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableURLRequest (MTPCategory)

+ (instancetype)defaultRequestMethod:(NSString *)methodType
                                 URL:(NSString *)url
                          parameters:(NSDictionary *)parameters;
@end
