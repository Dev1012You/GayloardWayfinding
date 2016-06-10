//
//  GAHCouponView.m
//  GaylordHotels
//
//  Created by John Pacheco on 9/15/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "GAHCouponView.h"

@implementation GAHCouponView

+ (instancetype)loadInView:(UIView *)view urlRequest:(NSURLRequest *)urlRequest delegate:(id<GAHCouponDelegate>)couponDelegate
{
    GAHCouponView *couponView = [GAHCouponView new];
    couponView.couponDelegate = couponDelegate;
    couponView.translatesAutoresizingMaskIntoConstraints = false;
    [view addSubview:couponView];
    
    NSDictionary *subviews = @{@"couponView": couponView};
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[couponView]-20-|" options:0 metrics:nil views:subviews]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[couponView]-20-|" options:0 metrics:nil views:subviews]];
    
    [couponView loadURL:urlRequest];
    
    return couponView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setBackgroundColor:[UIColor whiteColor]];
        
        // webview setup
        _couponWebView = [UIWebView new];
        _couponWebView.translatesAutoresizingMaskIntoConstraints = false;
//        _couponWebView.scalesPageToFit = true;
        _couponWebView.opaque = false;
        _couponWebView.backgroundColor = [UIColor clearColor];
        _couponWebView.delegate = self;
        
        [self addSubview:_couponWebView];
        
        // cancel button setup
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelButton.translatesAutoresizingMaskIntoConstraints = false;
        _cancelButton.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:100/255.0 alpha:1.0f];
        [_cancelButton addTarget:self action:@selector(removeFromSuperview) forControlEvents:UIControlEventTouchUpInside];
        _cancelButton.titleLabel.font = [UIFont fontWithName:@"MyriadPro-Regular" size:17.f];
        [_cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        
        [self addSubview:_cancelButton];
        
        [self setupConstraints];
    }
    
    return self;
}

#pragma mark - Methods

- (void)loadURL:(NSURLRequest *)urlRequest
{
    [self.couponWebView loadRequest:urlRequest];
}

#pragma mark - Protocol Conformance
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    BOOL shouldLoad = YES;
    if (navigationType == UIWebViewNavigationTypeLinkClicked)
    {
        if (self.couponDelegate && [self.couponDelegate respondsToSelector:@selector(couponWebView:shouldLoadClickedLink:)])
        {
            if ([self.couponDelegate couponWebView:webView shouldLoadClickedLink:request])
            {
                shouldLoad = YES;
            }
            else
            {
                shouldLoad = NO;
            }
        }
        else
        {
            shouldLoad = YES;
        }
        
        if (self.couponDelegate && [self.couponDelegate respondsToSelector:@selector(couponWebView:didClickLink:)])
        {
            [self.couponDelegate couponWebView:webView didClickLink:request];
        }
    }
    else
    {
        shouldLoad = YES;
    }

    return shouldLoad;
}

#pragma mark - Constraints

- (void)setupConstraints
{
    NSDictionary *subviews = @{@"couponWebView": _couponWebView,
                               @"cancelButton": _cancelButton};
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[couponWebView]-[cancelButton(44)]|" options:0 metrics:nil views:subviews]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[couponWebView]|" options:0 metrics:nil views:subviews]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[cancelButton]|" options:0 metrics:nil views:subviews]];
    
}

@end
