//
//  UIButton+GAHCustomButtons.m
//  GaylordHotels
//
//  Created by John Pacheco on 5/6/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "UIButton+GAHCustomButtons.h"
#import <QuartzCore/CALayer.h>

@implementation UIButton (GAHCustomButtons)

+ (UIButton *)menuNavigationButtonWithTarget:(id)target selector:(SEL)selector
{
    UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [menuButton.titleLabel setFont:[UIFont fontWithName:@"FontAwesome" size:35.f]];
    [menuButton setFrame:CGRectMake(0, 0, 35, 35)];
    
    [menuButton setTitle:@"\uf0c9"
                forState:UIControlStateNormal];
    
    [menuButton addTarget:target
                   action:selector
         forControlEvents:UIControlEventTouchUpInside];
    
    return menuButton;
}

+ (UIButton *)backNavigationButtonWithTarget:(id)target selector:(SEL)selector
{
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [backButton.titleLabel setFont:[UIFont fontWithName:@"FontAwesome" size:25.f]];
    [backButton setFrame:CGRectMake(0, 0, 35, 35)];
    
    [backButton setTitle:@"\uf053"
                forState:UIControlStateNormal];
    
    [backButton addTarget:target
                   action:selector
         forControlEvents:UIControlEventTouchUpInside];
    
    return backButton;
}

+ (UIButton *)mapNavigationButtonWithTarget:(id)target selector:(SEL)selector
{
    UIButton *mapButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [mapButton setFrame:CGRectMake(0, 0, 35, 35)];
    [mapButton setBackgroundImage:[UIImage imageNamed:@"mapFolded"]
                         forState:UIControlStateNormal];
    
    [mapButton addTarget:target
                  action:selector
        forControlEvents:UIControlEventTouchUpInside];
    
    return mapButton;
}

@end
