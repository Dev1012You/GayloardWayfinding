//
//  GAHNodeMarker.m
//  GaylordHotels
//
//  Created by John Pacheco on 8/11/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "GAHNodeMarker.h"
#import "DestinationButton.h"

@implementation GAHNodeMarker

+ (instancetype)wayfindingButtonType:(BOOL)userLocationButton
                            withSize:(CGSize)buttonSize
{
    GAHNodeMarker *destinationContainer = [[GAHNodeMarker alloc] initWithFrame:CGRectMake(0, 0, buttonSize.width, buttonSize.height)];
    
    DestinationButton *locationMarker = [DestinationButton wayfindingButtonSize:buttonSize
                                                                   userLocation:userLocationButton];
    destinationContainer.button = locationMarker;
    if (userLocationButton)
    {
        [GAHNodeMarker addPulsingCircleLayer:destinationContainer];
    }
    [destinationContainer addSubview:locationMarker];
    
    return destinationContainer;
}

+ (void)addPulsingCircleLayer:(UIView *)parentView
{
    UIView *pulsingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, parentView.bounds.size.width, parentView.bounds.size.width)];
    pulsingView.center = parentView.center;
    [pulsingView setBackgroundColor:[UIColor blueColor]];
    [pulsingView setAlpha:0.2];
    pulsingView.layer.cornerRadius = CGRectGetMidX(pulsingView.bounds);
    pulsingView.layer.masksToBounds = true;
    
    CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    basicAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeAffineTransform(CGAffineTransformMakeScale(2, 2))];
    basicAnimation.duration = 0.8;
    basicAnimation.repeatCount = 999;
    basicAnimation.autoreverses = true;
    [pulsingView.layer addAnimation:basicAnimation forKey:@"pulseAnimation"];
    
    [parentView insertSubview:pulsingView atIndex:0];
}

+ (instancetype)cameraButtonWithSize:(CGSize)buttonSize stepNumber:(NSNumber *)stepNumber
{
    GAHNodeMarker *buttonContainer = [GAHNodeMarker new];
    buttonContainer.frame = CGRectMake(0, 0, buttonSize.width, buttonSize.height);
    
    UIView *circleBackground = [UIView new];
    circleBackground.frame = CGRectMake(0, 0, buttonSize.width, buttonSize.height);
    [buttonContainer addSubview:circleBackground];
    
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:circleBackground.frame];
    CAShapeLayer *circleLayer = [CAShapeLayer layer];
    circleLayer.path = circlePath.CGPath;
    circleLayer.fillColor = [UIColor whiteColor].CGColor;
    
    circleLayer.lineWidth = 2.f;
    circleLayer.strokeColor = [UIColor colorWithRed:128/255.0 green:128/255.0 blue:128/255.0 alpha:1.0f].CGColor;
    
    [circleBackground.layer addSublayer:circleLayer];
    
    DestinationButton *newButton = [DestinationButton cameraButtonWithSize:buttonSize];
    [buttonContainer addSubview:newButton];
    
    if (stepNumber)
    {
        [buttonContainer addStepNumberLabel:stepNumber labelSize:buttonSize];
    }
    
    return buttonContainer;
}

- (void)addStepNumberLabel:(NSNumber *)stepNumber labelSize:(CGSize)labelSize
{
    CGSize defaultButtonSize = labelSize;
    
    UIView *stepNumberContainer = [self stepNumberContainerSize:defaultButtonSize];
    
    UILabel *stepLabel = [self createStepLabel:stepNumber.integerValue
                                     labelSize:defaultButtonSize];
    self.stepLabel = stepLabel;
    [stepNumberContainer addSubview:stepLabel];
    
    stepNumberContainer.center = self.frame.origin;

    [self addSubview:stepNumberContainer];
}

- (UIView *)stepNumberContainerSize:(CGSize)stepContainerSize
{
    UIView *stepNumberContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, stepContainerSize.width, stepContainerSize.height)];
    
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:stepNumberContainer.bounds];
    CAShapeLayer *circleShape = [CAShapeLayer layer];
    circleShape.path = circlePath.CGPath;
    circleShape.fillColor = [UIColor colorWithWhite:0 alpha:0.8].CGColor;
    [stepNumberContainer.layer addSublayer:circleShape];
    
    return stepNumberContainer;
}

- (UILabel *)createStepLabel:(NSInteger)stepNumber labelSize:(CGSize)stepNumberSize
{
    UILabel *stepNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, stepNumberSize.width, stepNumberSize.height)];
    
    stepNumberLabel.adjustsFontSizeToFitWidth = true;
    stepNumberLabel.minimumScaleFactor = 0.1;
    stepNumberLabel.lineBreakMode = NSLineBreakByCharWrapping;
    
    [stepNumberLabel setTextAlignment:NSTextAlignmentCenter];
    [stepNumberLabel setFont:[UIFont fontWithName:@"MyriadPro-Regular" size:15.f]];
    [stepNumberLabel setTextColor:[UIColor whiteColor]];
    [stepNumberLabel setText:[NSString stringWithFormat:@"%@",@(stepNumber)]];
    
    return stepNumberLabel;
}

@end
