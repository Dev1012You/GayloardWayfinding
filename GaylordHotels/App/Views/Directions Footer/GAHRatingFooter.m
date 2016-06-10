//
//  GAHRatingFooter.m
//  GaylordHotels
//
//  Created by John Pacheco on 11/9/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "GAHRatingFooter.h"
#import "GAHRateView.h"
#import "SIAlertView.h"

@implementation GAHRatingFooter

- (IBAction)submitRatingPressed:(id)sender
{
    if (self.ratingDelegate && [self.ratingDelegate respondsToSelector:@selector(rateViewDidRateDirections:)])
    {
        [self.ratingDelegate rateViewDidRateDirections:self.rateView];
    }
}

@end
