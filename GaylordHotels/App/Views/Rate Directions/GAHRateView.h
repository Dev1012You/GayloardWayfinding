//
//  GAHRateView.h
//  GaylordHotels
//
//  Created by John Pacheco on 11/9/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef BOOL(^HCSStarRatingViewShouldBeginGestureRecognizerBlock)(UIGestureRecognizer *gestureRecognizer);

@interface GAHRateView : UIControl
@property (nonatomic) NSUInteger maximumValue;
@property (nonatomic) CGFloat minimumValue;
@property (nonatomic) CGFloat value;
@property (nonatomic) CGFloat spacing;
@property (nonatomic) BOOL allowsHalfStars;
@property (nonatomic) BOOL accurateHalfStars;
@property (nonatomic) BOOL continuous;

@property (nonatomic) BOOL shouldBecomeFirstResponder;

// Optional: if `nil` method will return `NO`.
@property (nonatomic, copy) HCSStarRatingViewShouldBeginGestureRecognizerBlock shouldBeginGestureRecognizerBlock;

@property (nonatomic, strong) UIImage *emptyStarImage;
@property (nonatomic, strong) UIImage *halfStarImage;
@property (nonatomic, strong) UIImage *filledStarImage;
@end
