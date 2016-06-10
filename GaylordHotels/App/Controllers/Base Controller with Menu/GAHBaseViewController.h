//
//  GAHBaseViewController.h
//  GaylordHotels
//
//  Created by MeetingPlay on 5/4/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "MTPBaseViewController.h"
#import "GAHRootNavigationController.h"
#import "GAHAPIDataInitializer.h"
#import "MTPMainMenuViewController.h"

@class GAHMainMenuViewController, GAHMapViewController, GAHSelectionModalView;

@interface GAHBaseViewController : MTPBaseViewController <GAHAPIDataInitializerDelegate, MTPMainMenuDelegate>

@property (nonatomic, weak) GAHRootNavigationController *rootNavigationController;

@property (nonatomic, strong) GAHAPIDataInitializer *dataInitializer;

@property (nonatomic, strong) GAHMainMenuViewController *mainMenuViewController;

@property (nonatomic, strong) UIView *mainMenuContainer;
@property (nonatomic, weak) IBOutlet UIView *detailContainer;

@property (nonatomic, strong) UIView *socialView;
@property (nonatomic, strong) UIWebView *socialWebView;
@property (nonatomic, strong) NSLayoutConstraint *socialViewBottom;

@property (nonatomic, strong) GAHSelectionModalView *categorySelectionModal;

@property (nonatomic, strong) GAHMapViewController *globalMapViewController;
@property (nonatomic, assign) BOOL shouldHideMapOnDetailSelection;

@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer *rightEdgePanGesture;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@property (nonatomic, assign) BOOL shouldHideOnToggle;

- (void)toggleMenu:(id)sender;
- (void)returnToPrevious:(id)sender;
- (void)showMapView:(id)sender;
- (IBAction)toggleSocialView:(id)sender;
- (void)presentFeedback;

- (void)setupMainMenuData:(NSArray *)menuData
              withContent:(UINavigationController *)contentController;

- (void)setupConstraints;

#pragma mark URL Scheme Destination Loading
- (void)showDestination:(NSURL *)url;

@end