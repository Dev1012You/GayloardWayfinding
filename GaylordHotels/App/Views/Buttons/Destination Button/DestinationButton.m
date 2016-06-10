//
//  DestinationButton.m
//  GaylordHotels
//
//  Created by MeetingPlay on 5/6/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "DestinationButton.h"
#import "GAHDestination.h"
#import "NSObject+EventDefaultsHelpers.h"

#import "UIView+AutoLayoutHelper.h"

@implementation DestinationButton

+ (DestinationButton *)buttonWithSize:(CGSize)buttonSize
{
    DestinationButton *newButton = [DestinationButton buttonWithType:UIButtonTypeCustom];
    [newButton setFrame:CGRectMake(0, 0, buttonSize.width, buttonSize.height)];
    
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:newButton.frame];
    CAShapeLayer *circleLayer = [CAShapeLayer layer];
    circleLayer.path = circlePath.CGPath;
    circleLayer.fillColor = [UIColor colorWithRed:22/255.f
                                            green:82/255.f
                                             blue:186/255.f
                                            alpha:1.f].CGColor;
    circleLayer.lineWidth = buttonSize.width * 0.2;
    circleLayer.strokeColor = [UIColor colorWithWhite:1.f alpha:0.75f].CGColor;
    
    [newButton.layer addSublayer:circleLayer];
    
    return newButton;
}

+ (instancetype)wayfindingButtonSize:(CGSize)buttonSize userLocation:(BOOL)userLocationButton
{
    DestinationButton *newButton = [DestinationButton buttonWithType:UIButtonTypeCustom];
    [newButton setFrame:CGRectMake(0, -buttonSize.height/2.f, buttonSize.width, buttonSize.height)];
    
    NSString *buttonBackgroundImage = nil;
    if (userLocationButton)
    {
        buttonBackgroundImage = @"userLocationMarker";
    }
    else
    {
        buttonBackgroundImage = @"destinationMarker";
    }
    UIImage *buttonBackground = [UIImage imageNamed:buttonBackgroundImage];
    
    [newButton setBackgroundImage:buttonBackground forState:UIControlStateNormal];
    
    return newButton;
}

+ (DestinationButton *)cameraButtonWithSize:(CGSize)buttonSize
{
    DestinationButton *newButton = [DestinationButton buttonWithType:UIButtonTypeCustom];
    [newButton setFrame:CGRectMake(0, 0, buttonSize.width, buttonSize.height)];
    
    [newButton.titleLabel setFont:[UIFont fontWithName:@"FontAwesome" size:21.f]];
    newButton.titleLabel.adjustsFontSizeToFitWidth = true;
    newButton.titleLabel.minimumScaleFactor = 0.2;
    newButton.titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
    
    [newButton setTitle:@"\uf030" forState:UIControlStateNormal];
    [newButton setTitleColor:UIColorFromRGB(0x808080) forState:UIControlStateNormal];
    
    return newButton;
}


@end
