//
//  GAHRatingFooter.h
//  GaylordHotels
//
//  Created by John Pacheco on 11/9/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GAHRateView;

@protocol GAHRatingDelegate <NSObject>

- (void)rateViewDidRateDirections:(GAHRateView *)rateView;

@end

@interface GAHRatingFooter : UICollectionReusableView
@property (weak, nonatomic) IBOutlet GAHRateView *rateView;
@property (weak, nonatomic) IBOutlet UIButton *ratingSubmitButton;

@property (nonatomic, weak) IBOutlet id ratingDelegate;

@end
