//
//  GAHNodeMarker.h
//  GaylordHotels
//
//  Created by John Pacheco on 8/11/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DestinationButton;

@interface GAHNodeMarker : UIView

@property (nonatomic, strong) DestinationButton *button;
@property (nonatomic, strong) UILabel *stepLabel;

@property (nonatomic, assign) BOOL stepNode;

+ (instancetype)wayfindingButtonType:(BOOL)userLocationButton
                            withSize:(CGSize)buttonSize;

+ (instancetype)cameraButtonWithSize:(CGSize)buttonSize
                          stepNumber:(NSNumber *)stepNumber;

- (void)addStepNumberLabel:(NSNumber *)stepNumber labelSize:(CGSize)labelSize;

- (UIView *)stepNumberContainerSize:(CGSize)stepContainerSize;

- (UILabel *)createStepLabel:(NSInteger)stepNumber
                   labelSize:(CGSize)stepNumberSize;

@end
