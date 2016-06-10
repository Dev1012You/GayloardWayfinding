//
//  UIButton+GAHCustomButtons.h
//  GaylordHotels
//
//  Created by John Pacheco on 5/6/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (GAHCustomButtons)

+ (UIButton *)menuNavigationButtonWithTarget:(id)target selector:(SEL)selector;

+ (UIButton *)backNavigationButtonWithTarget:(id)target selector:(SEL)selector;

+ (UIButton *)mapNavigationButtonWithTarget:(id)target selector:(SEL)selector;

@end
