//
//  UIButton+MTPNavigationBar.m
//  GaylordHotels
//
//  Created by John Pacheco on 5/11/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "UIButton+MTPNavigationBar.h"

@implementation UIButton (MTPNavigationBar)
+ (UIBarButtonItem *)toggleMainMenuButton:(NSDictionary *)menuButtonCustomization target:(id)target selector:(SEL)action
{
    if (!menuButtonCustomization)
    {
        menuButtonCustomization = @{@"fontAwesomeCode": @"\uf0c9"};
    }
    
    UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [menuButton.titleLabel setFont:[UIFont fontWithName:@"FontAwesome" size:21.f]];
    [menuButton setFrame:CGRectMake(0, 0, 35, 35)];
    
    [menuButton setTitle:[menuButtonCustomization objectForKey:@"fontAwesomeCode"]
                forState:UIControlStateNormal];
    
    [menuButton addTarget:target action:action
         forControlEvents:UIControlEventTouchUpInside];
    
    [self addBorderEffect:menuButton];
    
    return [[UIBarButtonItem alloc] initWithCustomView:menuButton];
}

+ (UIBarButtonItem *)refreshMenuButton:(NSDictionary *)refreshButtonCustomization target:(id)target selector:(SEL)action
{
    if (!refreshButtonCustomization)
    {
        refreshButtonCustomization = @{@"fontAwesomeCode": @"\uf021"};
    }
    
    UIButton *refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [refreshButton.titleLabel setFont:[UIFont fontWithName:@"FontAwesome" size:21.f]];
    [refreshButton setFrame:CGRectMake(0, 0, 35, 35)];
    
    [refreshButton setTitle:[refreshButtonCustomization
                             objectForKey:@"fontAwesomeCode"]
                   forState:UIControlStateNormal];
    
    [refreshButton addTarget:target action:action
            forControlEvents:UIControlEventTouchUpInside];
    
    [self addBorderEffect:refreshButton];
    
    return [[UIBarButtonItem alloc] initWithCustomView:refreshButton];
}

+ (void)addBorderEffect:(UIButton *)menuButton
{
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:menuButton.frame cornerRadius:5];
    CAShapeLayer *thickFrame = [[CAShapeLayer alloc] initWithLayer:menuButton.layer];
    thickFrame.path = bezierPath.CGPath;
    thickFrame.strokeColor = [UIColor blackColor].CGColor;
    thickFrame.fillColor = [UIColor clearColor].CGColor;
    thickFrame.lineWidth = 1;
    [menuButton.layer insertSublayer:thickFrame atIndex:1];
    
    CAShapeLayer *thinFrame = [[CAShapeLayer alloc] initWithLayer:menuButton.layer];
    thinFrame.path = bezierPath.CGPath;
    thinFrame.strokeColor = [UIColor colorWithWhite:1 alpha:0.15].CGColor;
    thinFrame.fillColor = [UIColor clearColor].CGColor;
    thinFrame.lineWidth = 2.5f;
    [menuButton.layer insertSublayer:thinFrame atIndex:1];
}

+ (UIImageView *)navigationBarLogo:(CGFloat)destinationHeight
{
    UIImageView *logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navigationBarLogo"]];
    logoView.contentMode = UIViewContentModeScaleAspectFit;
    CGRect newFrame = CGRectMake(0, 0, 10, destinationHeight - 15);
    logoView.frame = newFrame;
    
    return logoView;
}

@end
