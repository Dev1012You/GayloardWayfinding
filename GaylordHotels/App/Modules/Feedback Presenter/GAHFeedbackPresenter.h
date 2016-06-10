//
//  GAHFeedbackPresenter.h
//  GaylordHotels
//
//  Created by John Pacheco on 11/13/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GAHFeedbackPresenter : NSObject <UIWebViewDelegate>

@property (nonatomic, strong) UIView *feedbackContainer;
@property (nonatomic, strong) UIWebView *feedbackWebView;
@property (nonatomic, strong) UIButton *hideContainerButton;

- (void)presentInView:(UIView *)parentView margins:(UIEdgeInsets)margins;

@end