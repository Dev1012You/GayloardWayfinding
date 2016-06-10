//
//  GAHFeedbackPresenter.m
//  GaylordHotels
//
//  Created by John Pacheco on 11/13/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "GAHFeedbackPresenter.h"
#import "MBProgressHUD.h"
#import "UIView+AutoLayoutHelper.h"

@implementation GAHFeedbackPresenter
- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _feedbackContainer = [UIView new];
        _feedbackContainer.translatesAutoresizingMaskIntoConstraints = false;
        _feedbackContainer.layer.shadowColor = [UIColor blackColor].CGColor;
        _feedbackContainer.layer.shadowOffset = CGSizeMake(0, 0);
        _feedbackContainer.layer.shadowRadius = 10;
        _feedbackContainer.layer.shadowOpacity = 1;
        
        _feedbackWebView = [UIWebView new];
        _feedbackWebView.translatesAutoresizingMaskIntoConstraints = false;
        
        [_feedbackContainer addSubview:_feedbackWebView];
        [_feedbackContainer addConstraints:[_feedbackWebView pinToSuperviewBounds]];
        
        _hideContainerButton = [self hideButton];
        [_feedbackContainer addSubview:_hideContainerButton];
        [_feedbackContainer addConstraint:[_hideContainerButton pinToTopSuperview:10]];
        [_feedbackContainer addConstraint:[_hideContainerButton pinTrailing:10]];
    }
    
    return self;
}

- (UIButton *)hideButton
{
    UIButton *hideContainerButton = [UIButton new];
    hideContainerButton.translatesAutoresizingMaskIntoConstraints = false;
    [hideContainerButton addConstraint:[hideContainerButton height:35]];
    [hideContainerButton addConstraint:[hideContainerButton width:35]];
    
    [hideContainerButton setTitle:@"X" forState:UIControlStateNormal];
    [hideContainerButton setBackgroundColor:[UIColor darkGrayColor]];
    
    return hideContainerButton;
}

- (void)presentInView:(UIView *)parentView margins:(UIEdgeInsets)margins
{
    [parentView addSubview:self.feedbackContainer];
    
    NSDictionary *viewsDictionary = @{@"parentView": parentView,
                                      @"feedback": self.feedbackContainer};
    
    NSString *verticalMargins = [NSString stringWithFormat:@"V:|-%@-[feedback]-%@-|",@(margins.top),@(margins.bottom)];
    NSString *horizontalMargins = [NSString stringWithFormat:@"H:|-%@-[feedback]-%@-|",@(margins.left),@(margins.right)];
    
    [parentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:verticalMargins options:0 metrics:nil views:viewsDictionary]];
    [parentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:horizontalMargins options:0 metrics:nil views:viewsDictionary]];
    
    self.feedbackWebView.delegate = self;
    [self.feedbackWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.meetingplay.com/gaylordfeedback"]]];
    
    [self.hideContainerButton addTarget:self.feedbackContainer
                                 action:@selector(removeFromSuperview)
                       forControlEvents:UIControlEventTouchUpInside];
}

- (void)hideFeedbackContainer
{
    [self.feedbackContainer removeFromSuperview];
}

#pragma mark Web View Delegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self toggleProgressHUDVisiblity:true];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self toggleProgressHUDVisiblity:false];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self toggleProgressHUDVisiblity:false];
}

- (void)toggleProgressHUDVisiblity:(BOOL)visible
{
    if (self.feedbackWebView)
    {
        if (visible)
        {
            [MBProgressHUD showHUDAddedTo:self.feedbackWebView animated:true];
        }
        else
        {
            [MBProgressHUD hideAllHUDsForView:self.feedbackWebView animated:true];
        }
    }
    else
    {
        NSLog(@"%s\n[%s]: Line %i] %@",__FILE__,__PRETTY_FUNCTION__,__LINE__,
              @"no feedback container found");
    }
}

@end