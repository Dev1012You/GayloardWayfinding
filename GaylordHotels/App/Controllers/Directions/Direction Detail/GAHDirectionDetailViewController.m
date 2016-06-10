//
//  GAHDirectionDetailViewController.m
//  GaylordHotels
//
//  Created by MeetingPlay on 6/11/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "GAHDirectionDetailViewController.h"
#import "CHAThreeSixtyImageViewController.h"

#import "UIImageView+AFNetworking.h"
#import "UIView+AutoLayoutHelper.h"
#import "NSObject+EventDefaultsHelpers.h"
#import "MBProgressHUD.h"

#import "DestinationButton.h"
#import "GAHNodeMarker.h"
#import "CHAFontAwesome.h"

@interface GAHDirectionDetailViewController () <UIScrollViewDelegate, CHAThreeSixtyImageDelegate>
@property (nonatomic, assign) CGFloat scaleFactor;
@property (nonatomic, strong) MBProgressHUD *imageDownload;
@property (nonatomic, strong) UIButton *closeButton;
@end

@implementation GAHDirectionDetailViewController
#pragma mark - View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.infiniteScroll = true;
    
    self.closeButton = [self addCloseButton];
    
    self.imageDownload = [MBProgressHUD showHUDAddedTo:self.view animated:true];
    self.imageDownload.mode = MBProgressHUDModeAnnularDeterminate;
    self.imageDownload.progress = 0;
    self.imageDownload.labelText = @"Downloading Image";
    self.imageDownload.color = [UIColor colorWithWhite:1 alpha:0.1];
}

#pragma mark - Protocol Conformance
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return nil;
}

- (void)threeSixtyView:(CHAThreeSixtyImageViewController *)threeSixty didLoadImage:(UIImage *)fetchedImage imageURL:(NSURL *)imageURL
{
    threeSixty.threeSixtyCollectionView.hidden = false;
    [self.imageDownload hide:true];
}

- (void)threeSixtyView:(CHAThreeSixtyImageViewController *)threeSixty didUpdateImageDownloadProgress:(CGFloat)downloadProgress
{
    self.imageDownload.progress = downloadProgress;
}

#pragma mark - IBActions
- (IBAction)pressedReturn:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
}

#pragma mark - Helper Methods


#pragma mark - Initial Setup
- (void)configureThreeSixtyViewImageURL:(NSURL *)imageURL parentView:(UIView *)parentView infiniteScroll:(BOOL)infiniteScroll
{
    CHAThreeSixtyImageViewController *threeSixty = [[CHAThreeSixtyImageViewController alloc] initWithURL:imageURL
                                                                                                delegate:self
                                                                                          infiniteScroll:infiniteScroll];
    threeSixty.threeSixtyCollectionView.hidden = true;
    
    [parentView addSubview:threeSixty.view];
    [self addChildViewController:threeSixty];
    
    [parentView addConstraints:[threeSixty.view pinToSuperviewBounds]];
    
    self.threeSixtyImageViewController = threeSixty;
    
    [self.view bringSubviewToFront:self.closeButton];
    [self.view bringSubviewToFront:self.imageDownload];
}

- (UIButton *)addCloseButton
{
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.translatesAutoresizingMaskIntoConstraints = false;
    [closeButton.titleLabel setFont:[UIFont fontWithName:@"FontAwesome" size:20.f]];
    [closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [closeButton setBackgroundColor:[UIColor colorWithWhite:0.25 alpha:1]];
    [closeButton setTitle:[CHAFontAwesome faClose] forState:UIControlStateNormal];
    
    closeButton.layer.cornerRadius = 15;
    closeButton.layer.masksToBounds = true;
    
    [closeButton addTarget:self.presentingViewController
                    action:@selector(dismissModalViewControllerAnimated:)
          forControlEvents:UIControlEventTouchUpInside];
    
    [closeButton addConstraint:[closeButton height:30]];
    [closeButton addConstraint:[closeButton width:30]];
    
    [self.view addSubview:closeButton];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:closeButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.topLayoutGuide attribute:NSLayoutAttributeBottom multiplier:1 constant:10]];
    
    [self.view addConstraint:[closeButton pinTrailing:10]];
    
    return closeButton;
}

#pragma mark - Auto Layout Setup

- (BOOL)shouldAutorotate
{
    return true;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return (UIInterfaceOrientationMaskPortrait|UIInterfaceOrientationMaskLandscape);
}
@end
