//
//  UIView+MTPCategory.m
//  GaylordHotels
//
//  Created by John Pacheco on 5/8/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "UIView+MTPCategory.h"

@implementation UIView (MTPCategory)

+ (void)createLayerShadow:(CALayer *)layerForShadow
{
    layerForShadow.shadowColor = [UIColor blackColor].CGColor;
    layerForShadow.shadowOpacity = 0.2f;
    layerForShadow.shadowRadius = 1.f;
    layerForShadow.shadowOffset = CGSizeMake(0, 1);
}

@end
