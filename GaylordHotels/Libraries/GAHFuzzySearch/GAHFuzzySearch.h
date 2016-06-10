//
//  GAHFuzzySearch.h
//  GaylordHotels
//
//  Created by John Pacheco on 9/14/15.
//  Copyright © 2015 MeetingPlay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

enum {
    NSStringScoreOptionNone                         = 1 << 0,
    NSStringScoreOptionFavorSmallerWords            = 1 << 1,
    NSStringScoreOptionReducedLongStringPenalty     = 1 << 2
};

typedef NSUInteger NSStringScoreOption;

@interface GAHFuzzySearch: NSObject

+ (CGFloat) scoreString:(NSString *)originalString against:(NSString *)otherString;
+ (CGFloat) scoreString:(NSString *)originalString against:(NSString *)otherString fuzziness:(NSNumber *)fuzziness;
+ (CGFloat) scoreString:(NSString *)originalString against:(NSString *)anotherString fuzziness:(NSNumber *)fuzziness options:(NSStringScoreOption)options;

@end