//
//  GAHCouponView.h
//  GaylordHotels
//
//  Created by John Pacheco on 9/15/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GAHCouponDelegate <NSObject>
@optional
- (BOOL)couponWebView:(UIWebView *)couponWebView shouldLoadClickedLink:(NSURLRequest *)urlRequest;
- (void)couponWebView:(UIWebView *)couponWebView didClickLink:(NSURLRequest *)urlRequest;
@end

@interface GAHCouponView : UIView <UIWebViewDelegate>

@property (nonatomic, weak) id <GAHCouponDelegate> couponDelegate;

@property (nonatomic, strong) UIWebView *couponWebView;

@property (nonatomic, strong) UIButton *cancelButton;

+ (instancetype)loadInView:(UIView *)view urlRequest:(NSURLRequest *)urlRequest delegate:(id<GAHCouponDelegate>)couponDelegate;

- (void)loadURL:(NSURLRequest *)urlRequest;

@end
