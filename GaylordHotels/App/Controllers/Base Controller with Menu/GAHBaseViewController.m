//
//  GAHBaseViewController.m
//  GaylordHotels
//
//  Created by MeetingPlay on 5/4/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "GAHBaseViewController.h"
#import "GAHMainMenuViewController.h"

#import "GAHMapViewController.h"
#import "GAHLocationPlacement.h"
#import "GAHLocationDetailsViewController.h"
#import "GAHNearbyLocationsViewController.h"
#import "GAHStoryboardIdentifiers.h"
#import "GAHFeedbackPresenter.h"

#import "NSObject+EventDefaultsHelpers.h"
#import "UIView+AutoLayoutHelper.h"

#import "UIButton+MTPNavigationBar.h"
#import "UIButton+GAHCustomButtons.h"

#import "GAHSelectionModalPresenter.h"
#import "GAHSelectionModalView.h"
#import "GAHDestination+Helpers.h"
#import "CHADestination+HelperMethods.h"

#import "GAHFuzzySearch.h"
#import "CHAFontAwesome.h"
#import "MDCustomTransmitter.h"

#import <Gimbal/Gimbal.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface GAHBaseViewController () <UIGestureRecognizerDelegate, GAHMapViewDelegate, GAHSelectionModalDelegate,MFMailComposeViewControllerDelegate>
@property (nonatomic, strong) NSLayoutConstraint *contentLeading;
@property (nonatomic, assign) CGFloat lastTranslation;
@property (nonatomic, strong) GAHNearbyLocationsViewController *nearbyMap;
@property (nonatomic, strong) GAHFeedbackPresenter *feedback;

@property (nonatomic, strong) GAHSelectionModalPresenter *relevantMatchesModalPresenter;
@end

@implementation GAHBaseViewController

#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.rightEdgePanGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(didPanFromEdge:)];
    self.rightEdgePanGesture.edges = UIRectEdgeRight;
    [self.view addGestureRecognizer:self.rightEdgePanGesture];
    
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
    self.tapGesture.enabled = false;
    self.tapGesture.delegate = self;
    [self.view addGestureRecognizer:self.tapGesture];
    
    self.mainMenuContainer = [UIView new];
    self.mainMenuContainer.translatesAutoresizingMaskIntoConstraints = false;
    [self.view addSubview:self.mainMenuContainer];
    
    self.mainMenuViewController = [self createMainMenu];
    [self.mainMenuContainer addSubview:self.mainMenuViewController.view];
    
    [self.view bringSubviewToFront:self.detailContainer];
    
    self.socialView = [self setupSocialView];
    [self.view addSubview:self.socialView];
    [self.view addConstraints:[self.socialView pinLeadingTrailing]];
    self.socialViewBottom = [self.socialView pinSide:NSLayoutAttributeTop toView:self.view secondViewSide:NSLayoutAttributeBottom];
    [self.view addConstraint:self.socialViewBottom];
    
    
    [self setupConstraints];
    
    self.lastTranslation = 0;
    self.shouldHideOnToggle = true;
    self.shouldHideMapOnDetailSelection = true;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setTranslucent:false];
    
    UIImageView *logoImageView = [UIButton navigationBarLogo:self.navigationController.navigationBar.frame.size.height];
    [self.navigationItem setTitleView:logoImageView];
    
    if ([[[self.navigationController viewControllers] firstObject] isEqual:self])
    {
        UIButton *menuButton = [UIButton menuNavigationButtonWithTarget:self selector:@selector(toggleMenu:)];
        [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:menuButton]];
    }
    else
    {
        UIButton *backButton = [UIButton backNavigationButtonWithTarget:self selector:@selector(returnToPrevious:)];
        UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        [self.navigationItem setLeftBarButtonItem:newBackButton];
    }
    
    UIButton *mapButton = [UIButton mapNavigationButtonWithTarget:self selector:@selector(showMapView:)];
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:mapButton]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (GAHMainMenuViewController *)createMainMenu
{
    GAHMainMenuViewController *mainMenu = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]
                                           instantiateViewControllerWithIdentifier:GAHMainMenuViewControllerIdentifier];
    mainMenu.view.translatesAutoresizingMaskIntoConstraints = false;
    mainMenu.mainMenuDelegate = self;
    
    [self addChildViewController:mainMenu];
    
    if ([self.navigationController isKindOfClass:[GAHRootNavigationController class]])
    {
        mainMenu.rootNavigationController = (GAHRootNavigationController *)self.navigationController;
    }
    else
    {
        DLog(@"\nDid not find a GAHRootNavigationController %@", self.navigationController);
    }
    
    return mainMenu;
}

#pragma mark - View Controller Setup
- (void)setupMainMenuData:(NSArray *)menuData
              withContent:(UINavigationController *)contentController
{
    if (menuData)
    {
        self.mainMenuViewController.parsedMenuItems = [self.mainMenuViewController loadMenuData:menuData];
    }
    
    if (contentController)
    {
        [self addChildViewController:contentController];
    }
}

- (IBAction)toggleSocialView:(id)sender
{
    if (self.socialViewBottom.constant == 0)
    {
        [self.socialWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://deploy.meetingplay.com/gaylord/social/"]]];
        
        if (self.mainMenuViewController.visiblityState == MTPMainMenuVisibilityStateVisible)
        {
            [self toggleMenu:nil];
        }
    }
    
    self.socialViewBottom.constant = (self.socialViewBottom.constant == 0) ? CGRectGetHeight(self.view.frame) / -1.15 : 0;
    [UIView animateWithDuration:0.5f
                          delay:0
         usingSpringWithDamping:0.65f
          initialSpringVelocity:0.2f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^
     {
         [self.socialView layoutIfNeeded];
     } completion:nil];
}

- (void)presentFeedback
{
    if (self.feedback == nil)
    {
        self.feedback = [GAHFeedbackPresenter new];
    }
    
    [self.feedback presentInView:self.view
                         margins:UIEdgeInsetsMake(10, 10, 10, 10)];
    
    if (self.mainMenuViewController.visiblityState == MTPMainMenuVisibilityStateVisible)
    {
        [self toggleMenu:nil];
    }
}

#pragma mark - Protocol Conformance
- (void)returnToPrevious:(id)sender
{
    [self.navigationController popViewControllerAnimated:true];
}

- (void)mainMenu:(MTPMainMenuViewController *)mainMenu didSelectMainMenuItem:(MTPMenuItem *)menuItem
{
    [self toggleMenu:nil];
    
    [self showCategorySelector];
}

#pragma mark Gesture Recognizer Delegate Methods
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint gestureLocation = [gestureRecognizer locationInView:self.detailContainer];
    
    if (gestureRecognizer == self.tapGesture)
    {
        if ([self.detailContainer pointInside:gestureLocation withEvent:UIEventTypeTouches])
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    
    return true;
}



#pragma mark MTPMainMenuToggling
- (void)toggleMenu:(id)sender
{
    [self topViewControllerShouldToggleMenu:sender];
    
    [self shouldShowMapView:NO];
}

- (void)didPanFromEdge:(id)sender
{
    if (self.mainMenuViewController.visiblityState == MTPMainMenuVisibilityStateVisible)
    {
        if ([sender isKindOfClass:[UIPanGestureRecognizer class]])
        {
            UIPanGestureRecognizer *panGesture = (UIPanGestureRecognizer *)sender;
            if (panGesture.state == UIGestureRecognizerStateEnded)
            {
                [self toggleMenu:sender];
                self.lastTranslation = 0;
            }
            else
            {
                if (self.contentLeading.constant < CGRectGetWidth(self.view.frame) - 60
                    && self.contentLeading.constant > 0)
                {
                    CGPoint gestureTranslation = [panGesture translationInView:self.view];
                    self.contentLeading.constant =  MAX(0, self.contentLeading.constant + (gestureTranslation.x - self.lastTranslation));
                    self.lastTranslation = gestureTranslation.x;
                }
            }
        }
    }
}

- (void)didTap:(id)sender
{
    if ([sender isKindOfClass:[UITapGestureRecognizer class]])
    {
        if ([sender isEnabled])
        {
            [self toggleMenu:sender];
        }
    }
}

static const CGFloat menuWidth = 0.85f;
- (void)topViewControllerShouldToggleMenu:(id)sender
{
    if (self.contentLeading == nil)
    {
        self.contentLeading = [self constraintForItem:self.detailContainer layoutAttribute:NSLayoutAttributeLeading];// self.contentLeading;
    }
    
    NSLayoutConstraint *leadingEdgeStartingPoint = self.contentLeading;

    leadingEdgeStartingPoint.constant = (self.mainMenuViewController.visiblityState == MTPMainMenuVisibilityStateHidden) ? CGRectGetWidth(self.mainMenuContainer.frame) : 0;
    
    [UIView animateWithDuration:0.2f animations:^{
        [self.view layoutIfNeeded];
    }];
    
    
    BOOL menuHidden = (leadingEdgeStartingPoint.constant == 0) ? true : false;
    
    [self.mainMenuViewController setVisiblityState:(menuHidden ? MTPMainMenuVisibilityStateHidden : MTPMainMenuVisibilityStateVisible)];
    
    [self.navigationController setNavigationBarHidden:!menuHidden animated:true];

    self.detailContainer.userInteractionEnabled = menuHidden;
    
    [self.tapGesture setEnabled:!menuHidden];
    
    if (self.categorySelectionModal.superview)
    {
        [self.categorySelectionModal removeFromSuperview];
    }
}

#pragma mark Map View Delegate
- (void)mapView:(GAHMapViewController *)mapView didSelectDetails:(GAHDestination *)selectedDestination
{
    if (self.navigationController)
    {
        GAHLocationDetailsViewController *explore = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:GAHExploreDetailViewControllerIdentifier];
        explore.dataInitializer = self.dataInitializer;
        explore.directionsLoader = self.rootNavigationController;
        explore.rootNavigationController = self.rootNavigationController;
        
        explore.locationData = selectedDestination;
        
        [self.navigationController pushViewController:explore animated:true];
        if (self.shouldHideMapOnDetailSelection)
        {
            [self shouldShowMapView:false];
        }
    }
}

#pragma mark - Map View Helpers
- (void)showMapView:(id)sender
{
    if (!self.globalMapViewController)
    {
        self.globalMapViewController = [self.rootNavigationController sharedMapViewController];
        [self.view addSubview:self.globalMapViewController.view];
        [self.globalMapViewController.view.superview addConstraints:[self.globalMapViewController.view pinToSuperviewBounds]];
        
        self.globalMapViewController.view.hidden = true;
        self.globalMapViewController.mapViewDelegate = self;
    }
    
    [self shouldShowMapView:self.globalMapViewController.view.hidden];
}

- (void)shouldShowMapView:(BOOL)showMapView
{
    if (showMapView)
    {
        self.globalMapViewController.view.hidden = false;
        [self.view bringSubviewToFront:self.globalMapViewController.view];
        
        [self zoomUserLocation:self.globalMapViewController];
    }
    else
    {
        [self.globalMapViewController.view removeFromSuperview];
        self.globalMapViewController = nil;
    }
}

- (void)showDestination:(NSURL *)url
{
    __block NSString *locationName = nil;
    
    __block NSMutableDictionary *urlParameters = [NSMutableDictionary new];
    
    NSString *queryString = url.query;
    NSArray *queryComponents = [queryString componentsSeparatedByString:@"&"];
    [queryComponents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSArray *singleQuery = [obj componentsSeparatedByString:@"="];
        if (singleQuery.count == 2)
        {
            NSString *key = singleQuery.firstObject;
            NSString *value = singleQuery.lastObject;
            
            if (key.length && value.length)
            {
                [urlParameters setObject:value forKey:key];
            }
        }
    }];
    
    locationName = [urlParameters objectForKey:@"locationName"];
    if (locationName.length == 0)
    {
        DLog(@"\nno location name was provided in the url %@", url.absoluteString);
        return;
    }
    
    GAHDestination *destination = [GAHDestination existingDestination:locationName
                                                         inCollection:self.dataInitializer.meetingPlayLocations];
    
    if (!self.globalMapViewController)
    {
        self.globalMapViewController = [self.rootNavigationController sharedMapViewController];
        [self.view addSubview:self.globalMapViewController.view];
        [self.globalMapViewController.view.superview addConstraints:[self.globalMapViewController.view pinToSuperviewBounds]];
        
        self.globalMapViewController.mapViewDelegate = self;
    }
    
    self.globalMapViewController.view.hidden = false;
    [self.view bringSubviewToFront:self.globalMapViewController.view];
    
    if (destination)
    {
        [self.globalMapViewController.locationPlacer zoomDestination:destination
                                                   mapViewController:self.globalMapViewController
                                                         showCallout:YES];
    }
    else
    {
        __weak __typeof(&*self)weakSelf = self;
        // do keyword search for location
        NSArray *matchesSortedByRelevance = [self destinationKeywordSearch:locationName
                                                                 locations:self.dataInitializer.meetingPlayLocations];
        
        GAHSelectionModalPresenter *relevantLocationsModal = [GAHSelectionModalPresenter new];
        [relevantLocationsModal.selectionView.containerTitle setText:@"Select a Location"];
        NSString *containerDescription = @"We couldn't find the exact location for the session. Please select one from the list below.";
        [relevantLocationsModal.selectionView.containerDescription setText:containerDescription];
        
        [relevantLocationsModal setModalCellCongiuration:^(UITableViewCell *cell, GAHDestination * rowData)
         {
             cell.textLabel.text = rowData.location;
         }];
        
        [relevantLocationsModal loadData:matchesSortedByRelevance];
        [relevantLocationsModal presentSelectionModalInView:weakSelf.view
                                           selectionHandler:^(NSIndexPath *indexPath)
         {
             GAHDestination *selectedDestination = [matchesSortedByRelevance objectAtIndex:indexPath.row];
             
             [weakSelf.globalMapViewController.locationPlacer zoomDestination:selectedDestination
                                                            mapViewController:weakSelf.globalMapViewController
                                                                  showCallout:YES];
         }];
        self.relevantMatchesModalPresenter = relevantLocationsModal;
    }
}

- (NSArray *)destinationKeywordSearch:(NSString *)destinationSlug locations:(NSArray *)existingLocations
{
    NSArray *plottedDestinations = [self.dataInitializer.meetingPlayLocations filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"wfpName.length > 0"]];
    
    NSArray *sortedDestinations = [plottedDestinations sortedArrayUsingComparator:^NSComparisonResult(GAHDestination * obj1, GAHDestination * obj2)
    {
        NSString *obj1Name = obj1.location;
        NSString *obj2Name = obj2.location;
        
        NSNumber *matchPercentObj1 = @([GAHFuzzySearch scoreString:destinationSlug against:obj1Name]);
        NSNumber *matchPercentObj2 = @([GAHFuzzySearch scoreString:destinationSlug against:obj2Name]);
        
        return [matchPercentObj2 compare:matchPercentObj1];
    }];
    
    return sortedDestinations;
}

- (void)zoomUserLocation:(GAHMapViewController *)mapViewController
{
    NSNumber *currentFloor = [self.globalMapViewController currentFloor];
    
    [self.globalMapViewController plotDestinationPoints:self.dataInitializer.meetingPlayLocations
                                      withBaseLocations:self.dataInitializer.mapDataSource.mapDestinations];
    
    [self.globalMapViewController showDestinationsOnFloor:currentFloor];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        MDCustomTransmitter *lastActiveBeacon = self.rootNavigationController.beaconSightingManager.beaconManager.activeBeacon;
        if (lastActiveBeacon)
        {
            CGPoint currentBeaconLocation = [self.globalMapViewController.locationPlacer coordinatesForBeacon:lastActiveBeacon];
            NSNumber *beaconFloor = [GAHMapDataSource floorForMapID:lastActiveBeacon.fkMapID];
            [self.globalMapViewController showFloorForMapImage:[GAHMapDataSource detailsForFloor:beaconFloor
                                                                                    mapImageData:self.dataInitializer.mapDataSource.mapImageData]];
            [self.globalMapViewController zoomToPoint:currentBeaconLocation
                                            zoomScale:defaultZoomScale];
        }
    });
}

#pragma mark - Social WebView

- (UIView *)setupSocialView
{
    if (self.socialView)
    {
        return self.socialView;
    }
    
    self.socialView = [UIView new];
    self.socialView.translatesAutoresizingMaskIntoConstraints = false;
    self.socialView.backgroundColor = [UIColor whiteColor];
    
    // hide social web view button setup
    UIButton *hideSocial = [UIButton new];
    hideSocial.translatesAutoresizingMaskIntoConstraints = false;
    [self.socialView addSubview:hideSocial];
    
    hideSocial.backgroundColor = [UIColor darkGrayColor];
    hideSocial.titleLabel.font = [UIFont fontWithName:@"FontAwesome" size:25.f];
    [hideSocial setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [hideSocial setTitle:[CHAFontAwesome faChevronDown] forState:UIControlStateNormal];
    [hideSocial addTarget:self.socialWebView action:@selector(toggleSocialView:) forControlEvents:UIControlEventTouchUpInside];
    
    // setup social web view
    self.socialWebView = [UIWebView new];
    self.socialWebView.translatesAutoresizingMaskIntoConstraints = false;
    [self.socialView addSubview:self.socialWebView];
    
    // setup constraints
    [hideSocial addConstraint:[hideSocial height:44.f]];
    [self.socialView addConstraints:[hideSocial stackAboveView:self.socialWebView]];

    [self.socialView addConstraint:[self.socialView height:CGRectGetHeight(self.view.frame) / 1.15]];
    
    return self.socialView;
}

#pragma mark - Category Picker View
- (void)showCategorySelector
{
    if (self.nearbyMap == nil)
    {
        GAHNearbyLocationsViewController *nearbyMap = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:GAHNearbyLocationsControllerIdentifier];
        nearbyMap.rootNavigationController = self.rootNavigationController;
        [nearbyMap loadDataInitializer:self.dataInitializer];
        
        self.nearbyMap = nearbyMap;
    }
    
    if (self.categorySelectionModal == nil)
    {
        GAHSelectionModalView *newSelectionModal = [GAHSelectionModalView new];
        newSelectionModal.translatesAutoresizingMaskIntoConstraints = false;
        newSelectionModal.selectionModalDelegate = self;
        [newSelectionModal setupDefaultAppearance:false];
        
        newSelectionModal.containerTitle.text = @"Nearby Locations";
        newSelectionModal.containerDescription.text = @"Please select the location type that you would like to display on the map.";
        
        self.categorySelectionModal = newSelectionModal;
    }
    
    [self.categorySelectionModal prepareData:@[@"Dining",@"Restrooms",@"Gift Shops",@"Meeting Space",@"ATM"]];
    
    BOOL bluetoothEnabled = [GMBLApplicationStatus bluetoothStatus];
    BOOL locationPermissions = [GMBLApplicationStatus locationStatus];
    
    SIAlertView *nearbyFailedAlert = [SIAlertView new];
    [nearbyFailedAlert addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeDefault handler:nil];
    
    if (bluetoothEnabled)
    {
        nearbyFailedAlert.title = @"Bluetooth is Off";
        nearbyFailedAlert.message = @"The \"Near Me\" feature requires Bluetooth to calculate locations nearest to you. Please make sure Bluetooth is enabled in your Settings application.";
        [nearbyFailedAlert show];
    }
    else if (locationPermissions)
    {
        nearbyFailedAlert.title = @"Location Services Disabled";
        nearbyFailedAlert.message = @"The \"Near Me\" feature requires permission to use your position to calculate the nearest location.\n\nPlease make sure the Gaylord Wayfinding application has permission in your Settings application.\n";
        [nearbyFailedAlert show];
    }
    else if (self.rootNavigationController.beaconSightingManager.beaconManager.activeBeacon == nil)
    {
        nearbyFailedAlert.title = @"No Active Beacons Found";
        nearbyFailedAlert.message = @"We couldn't identify any beacons nearby. Please approach a common area and try again.";
        [nearbyFailedAlert show];
    }
    else
    {
        [self.view addSubview:self.categorySelectionModal];
        [self.view addConstraints:[self.categorySelectionModal pinToSuperviewBoundsInsets:UIEdgeInsetsMake(10, 10, 10, 10)]];
    }
}

- (UITableViewCell *)selectionModalTableView:(UITableView *)tableView configureCell:(UITableViewCell *)cell data:(id)rowData atIndexPath:(NSIndexPath *)indexPath
{
    cell.textLabel.text = rowData;
    return cell;
}

- (void)selectionModalTableView:(UITableView *)tableView didSelectData:(id)rowData atIndexPath:(NSIndexPath *)indexPath
{
    NSArray *meetingPlayDestinations = [self.nearbyMap nearestLocationsForDestinationType:rowData];
    
    __block NSMutableArray *restrictNumberOfLocations = [NSMutableArray new];
    [meetingPlayDestinations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        if (idx < 5)
        {
            [restrictNumberOfLocations addObject:obj];
        }
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.nearbyMap loadLocations:restrictNumberOfLocations];
    });
    
    [self.navigationController setViewControllers:@[self.nearbyMap] animated:true];
}


#pragma mark - Auto Layout Setup

- (void)setupConstraints
{
    [self.mainMenuContainer.superview addConstraints:@[[self.mainMenuContainer pinToTopSuperview],
                                                       [self.mainMenuContainer pinToBottomSuperview],
                                                       [self.mainMenuContainer pinLeading],
                                                       [self.mainMenuContainer equalWidth:menuWidth]]];
    
    [self.mainMenuContainer addConstraints:[self.mainMenuViewController.view pinToSuperviewBounds]];

}

- (NSLayoutConstraint *)constraintForItem:(UIView *)firstItem
                          layoutAttribute:(NSLayoutAttribute)layoutAttribute
{
    if (!firstItem)
    {
        return nil;
    }
    
    for (NSLayoutConstraint *possibleMatchingConstraint in firstItem.superview.constraints)
    {
        if (possibleMatchingConstraint.firstItem == firstItem ||
            possibleMatchingConstraint.secondItem == firstItem)
        {
            if (possibleMatchingConstraint.firstAttribute == layoutAttribute)
            {
                return possibleMatchingConstraint;
            }
        }
    }
    
    return nil;
}
@end



