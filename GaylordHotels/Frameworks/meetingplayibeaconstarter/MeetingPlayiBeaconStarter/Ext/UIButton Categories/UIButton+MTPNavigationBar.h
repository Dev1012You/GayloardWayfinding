//
//  UIButton+MTPNavigationBar.h
//  GaylordHotels
//
//  Created by John Pacheco on 5/11/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (MTPNavigationBar)

+ (UIBarButtonItem *)toggleMainMenuButton:(NSDictionary *)menuButtonCustomization target:(id)target selector:(SEL)action;

+ (UIBarButtonItem *)refreshMenuButton:(NSDictionary *)refreshButtonCustomization target:(id)target selector:(SEL)action;

+ (UIImageView *)navigationBarLogo:(CGFloat)destinationHeight;

@end
