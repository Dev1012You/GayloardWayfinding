//
//  UIColor+GAHCustom.m
//  GaylordHotels
//
//  Created by John Pacheco on 10/8/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "UIColor+GAHCustom.h"

@implementation UIColor (GAHCustom)

+ (UIColor *)gaylordBlue
{
    return [self gaylordBlue:1];
}

+ (UIColor *)gaylordBlue:(CGFloat)alpha
{
    
    CGFloat colorAlpha = alpha;
    UIColor *darkBlue = [UIColor colorWithRed:0/255.0 green:44/255.0 blue:114/255.0 alpha:colorAlpha];
    
    return darkBlue;
}

@end
