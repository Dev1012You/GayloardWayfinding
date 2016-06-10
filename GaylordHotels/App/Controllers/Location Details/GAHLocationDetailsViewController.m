//
//  GAHExploreDetailViewController.m
//  GaylordHotels
//
//  Created by MeetingPlay on 5/7/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "GAHLocationDetailsViewController.h"
#import "GAHDetailHeaderViewController.h"

#import "MDBeaconManager.h"
#import "MDCustomTransmitter+NetworkingHelper.h"
#import "GAHAPIDataInitializer.h"
#import "GAHGeneralInfoViewController.h"

#import "UIView+AutoLayoutHelper.h"
#import "GAHMapViewController.h"
#import "GAHMapDataSource.h"
#import "GAHDestination.h"
#import "GAHStoryboardIdentifiers.h"
#import "CHAFontAwesome.h"
#import "MBProgressHUD.h"
#import "UIImageView+AFNetworking.h"
#import "CHADestination.h"
#import "CHAMapImage.h"

#import "GAHSelectionModalView.h"
#import "GAHFuzzySearch.h"

#import "GAHDestination+Helpers.h"
#import "CHADestination+HelperMethods.h"

#import "NSURLSession+MTPCategory.h"
#import "NSMutableURLRequest+MTPCategory.h"
#import "NSString+MTPWebViewURL.h"

#import <Gimbal/Gimbal.h>

#import "UIColor+GAHCustom.h"
#import "UIButton+GAHCustomButtons.h"

@interface GAHLocationDetailsViewController () <GAHMapViewDelegate, GAHSelectionModalDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIPickerViewDataSource, UIPickerViewDelegate, UIWebViewDelegate>

@property (nonatomic, strong) GAHDetailHeaderViewController *headerView;
@property (nonatomic, strong) NSMutableArray *headerConstraints;
@property (nonatomic, strong) NSLayoutConstraint *headerHeight;
@property (nonatomic, strong) NSLayoutConstraint *detailsHeightConstraint;
@property (nonatomic, strong) NSArray *mapContainerConstraints;

@property (nonatomic, strong) UITableView *filterDestinationTableView;
@property (nonatomic, strong) NSArray *sortedMeetingPlayDestinations;
@property (nonatomic, strong) NSArray *displayData;
@property (nonatomic, strong) NSDictionary *reservationData;

@property (nonatomic, assign, getter=isFetching) BOOL fetching;

@property (nonatomic, strong) GAHSelectionModalView *selectionModalView;

@property (nonatomic, strong) NSArray *placedTransmitters;
@property (nonatomic, strong) NSDictionary *startLocations;
@end


@implementation GAHLocationDetailsViewController

#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // do any setup here
    [self fetchStartLocations:nil];
    
    self.placedTransmitters = [self.dataInitializer.beaconManager.allBeacons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.placed = 1"]];
    
    self.fetching = false;
    
    // view setup items
    [self setupSubviews];
    
    self.mainDetailsCollectionView.delegate = self;
    self.mainDetailsCollectionView.dataSource = self;
    
    // data setup
    [self loadHeaderData];
    
    GAHDataSource *locationItem = [[GAHDataSource alloc] init];
    locationItem.data = @[self.locationData];
    self.dataSource = locationItem;
    [self configureWithDataSource:self.dataSource];
    
    // map container configuration
    [self configureMapContainer:self.mapContainer];
    
    [self.expandMapButton.titleLabel setFont:[UIFont fontWithName:@"FontAwesome" size:20.f]];
    [self.expandMapButton addTarget:self
                             action:@selector(didTapMapContainer:)
                   forControlEvents:UIControlEventTouchUpInside];
    self.expandMapButton.enabled = false;
    
    [self toggleExpandConstraintsButtonAppearance:false];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapMapContainer:)];
    singleTap.numberOfTapsRequired = 1;
    [self.mapContainer addGestureRecognizer:singleTap];
}

- (void)setupSubviews
{
    [self setupConstraints];
    [self.view sendSubviewToBack:self.mainMenuContainer];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"defaultTexture"]];
    
    [self setupButton:self.requestRouteButton directionsButton:true];
    [self setupButton:self.reservationsButton directionsButton:false];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:false];
    
    [self setPageTitleText:self.locationData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.headerView cancelTimer];
    [self.mapViewController cancelTimer];
}

- (void)dealloc
{
    NSLog(@"location details did dealloc");
}

#pragma mark - Protocol Conformance
#pragma mark Selection Modal Protocol
- (UITableViewCell *)selectionModalTableView:(UITableView *)tableView configureCell:(UITableViewCell *)cell data:(id)rowData atIndexPath:(NSIndexPath *)indexPath
{
    GAHDestination *location = (GAHDestination *)rowData;
    cell.textLabel.text = location.location;
    
    return cell;
}

- (void)selectionModalTableView:(UITableView *)tableView didSelectData:(id)rowData atIndexPath:(NSIndexPath *)indexPath
{
    GAHDestination *location = (GAHDestination *)rowData;

    CHADestination *destination = [CHADestination wayfindingBasePointForMeetingPlaySlug:location.wfpName wayfindingLocations:self.dataInitializer.mapDataSource.mapDestinations];
    
    [self sendRequestForDirections:destination destination:self.locationData];

    [[[tableView superview] superview] removeFromSuperview];
}

#pragma mark UICollectionView Protocol
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.displayData.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GAHDetailContentCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:GAHDetailContentCellIdentifier forIndexPath:indexPath];
    NSDictionary *detailData = self.displayData[indexPath.row];
    
    NSString *iconString = [detailData objectForKey:@"icon"];
    NSString *itemTitle = [detailData objectForKey:@"label"];
    
    if (iconString.length < 1)
    {
        iconString = [CHAFontAwesome icon:@"fa-info-circle"];
    }
    else
    {
        iconString = [CHAFontAwesome icon:iconString];
    }
    
    cell.iconLabel.text = iconString;
    cell.detailsLabel.text = itemTitle;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *linkItem = self.displayData[indexPath.row];
    if ([linkItem isKindOfClass:[NSDictionary class]])
    {
        NSString *link = [linkItem objectForKey:@"link"];
        [self processLink:link];
    }
}

- (void)processLink:(NSString *)link
{
    if (link.length > 0)
    {
        if ([link rangeOfString:@"http" options:NSCaseInsensitiveSearch].location == 0)
        {
            [self openLink:link];
        }
        else
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:link]];
        }
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat marginSize = 10.f;
    CGFloat height = collectionView.frame.size.height - (marginSize * 2.f);
    CGFloat width = (CGRectGetWidth(collectionView.frame)/3.f) - (marginSize * 1.5f);
    return CGSizeMake(width, height);
}

#pragma mark UIWebViewDelegate Methods
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self showLoadingIndicator:YES error:nil];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self showLoadingIndicator:NO error:nil];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self showLoadingIndicator:NO error:error];
    if (webView == self.extraDetailsWebView)
    {
        self.extraDetailsWebView.hidden = true;
    }
}

- (void)showLoadingIndicator:(BOOL)visible error:(NSError *)error
{
    if (error)
    {
        NSLog(@"%s\n[%s]: Line %i] error %@",__FILE__,__PRETTY_FUNCTION__,__LINE__,
              error);
    }
    
    if (visible)
    {
        [MBProgressHUD showHUDAddedTo:self.extraDetailsWebView animated:true];
    }
    else
    {
        [MBProgressHUD hideAllHUDsForView:self.extraDetailsWebView animated:true];
    }
}

#pragma mark - IBActions

- (IBAction)returnPrevious:(id)sender
{
    [self.headerView cancelTimer];
    
    [self.mapViewController cancelTimer];
    
    [super returnToPrevious:sender];
}

- (void)openLink:(NSString *)link
{
    GAHGeneralInfoViewController *locationMisc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:GAHGeneralInfoViewControllerIdentifier];
    locationMisc.generalInfoURL = [link stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    locationMisc.minimizeCloseBar = false;
    [locationMisc.generalInfoWebView setScalesPageToFit:true];
    
    [self presentViewController:locationMisc animated:true completion:nil];
}

- (IBAction)didTapMapContainer:(id)sender
{
    GAHMapViewSize newMapSize = 0;
    if (CGRectGetHeight(self.mapContainer.frame) > 300)
    {
        newMapSize = GAHMapViewSizeLarge;
    }
    else
    {
        newMapSize = GAHMapViewSizeSmall;
    }
    
    [self mapViewDidToggleSize:newMapSize];
}

- (void)mapView:(GAHMapViewController *)mapView didSelectDetails:(GAHDestination *)selectedDestination
{
    if ([mapView isEqual:self.mapViewController])
    {
        [self didTapMapContainer:nil];
    }
    else
    {
        GAHLocationDetailsViewController *explore = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:GAHExploreDetailViewControllerIdentifier];
        explore.dataInitializer = self.dataInitializer;
        explore.directionsLoader = self.directionsLoader;
        explore.rootNavigationController = self.rootNavigationController;
        
        explore.locationData = selectedDestination;
        [self showMapView:nil];
        [self.navigationController pushViewController:explore animated:true];
    }
}

#pragma mark - Wayfinding Methods
- (BOOL)shouldLoadDirections:(MDCustomTransmitter *)transmitter
{
    if ([GMBLApplicationStatus bluetoothStatus] != GMBLBluetoothStatusOK)
    {
        [self presentDestinationSelection:@"Sorry, but we couldn't find a beacon near you because bluetooth is disabled. Please select a start destination."];
        return NO;
    }
    
    if (transmitter == nil)
    {
        [self presentDestinationSelection:@"Sorry, but we couldn't find a beacon near you. Please select a start destination."];
        return NO;
    }
    
    id destination = self.locationData;
    if ([destination isKindOfClass:[GAHDestination class]] == NO)
    {
        UIAlertView *debugAlert = [[UIAlertView alloc] initWithTitle:@"Load Directions" message:@"Destination is not a class" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [debugAlert show];
        return NO;
    }

    // found a transmitter, destination is appropriate and we aren't already fetching
    return YES;
}

- (IBAction)loadDirections:(id)sender
{
    BOOL testBeacons = [[[NSUserDefaults standardUserDefaults] objectForKey:@"beaconSelectEnabled"] boolValue];
    if (testBeacons)
    {
        [self beaconSelection];
    }
    else
    {
        MDCustomTransmitter *transmitter = self.dataInitializer.beaconManager.activeBeacon;
        
        NSLog(@"transmitter %@", transmitter.identifier);
        
        if ([self shouldLoadDirections:transmitter] == YES)
        {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:true];
            hud.labelText = @"Calculating Route";
            
            CHADestination *startPoint = [self destinationForTransmitter:transmitter];
            
            if (startPoint)
            {
                [self sendRequestForDirections:startPoint
                                   destination:self.locationData];
            }
            else
            {
                [self showMultipleStartLocationsNearby:transmitter];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideAllHUDsForView:self.view animated:true];
            });
        }
        else
        {
            DLog(@"\nno active transmitter");
        }
    }
}

- (CHADestination *)destinationForTransmitter:(MDCustomTransmitter *)transmitter
{
    CHADestination *startPoint = nil;
    
    if (transmitter.placed)
    {
        startPoint = [self destinationForPlacedTransmitter:transmitter];
    }
    else
    {
        GAHDestination *startDestination = [[GAHDestination destinationsForBaseLocation:transmitter.meetingPlaySlug
                                                                   meetingPlayLocations:self.dataInitializer.meetingPlayLocations] firstObject];
        
        startPoint = [CHADestination wayfindingBasePointForMeetingPlaySlug:startDestination.wfpName
                                                       wayfindingLocations:self.dataInitializer.mapDataSource.mapDestinations];
    }
    
    return startPoint;
}

- (CHADestination *)destinationForPlacedTransmitter:(MDCustomTransmitter *)placedTransmitter
{
    NSString *defaultStart = placedTransmitter.defaultStart;
    
    GAHDestination *nearestNavigableDestination = [GAHDestination existingDestination:defaultStart
                                                                         inCollection:self.dataInitializer.meetingPlayLocations];
    
    CHADestination *destinationForTransmitter = [CHADestination wayfindingBasePointForMeetingPlaySlug:nearestNavigableDestination.wfpName
                                                                                  wayfindingLocations:self.dataInitializer.mapDataSource.mapDestinations];
//    if (destinationForTransmitter == nil)
//    {
//        destinationForTransmitter = [self.dataInitializer findNearestDestination:placedTransmitter];
//    }
    
    return destinationForTransmitter;
}

- (NSArray *)sortMeetingPlayDestinations:(NSArray *)meetingPlayDestinations
{
    NSArray *sortedDestinations = [meetingPlayDestinations sortedArrayUsingComparator:^NSComparisonResult(GAHDestination *obj1, GAHDestination *obj2) {
        
        return [obj1.location caseInsensitiveCompare:obj2.location];
    }];
    
    return sortedDestinations;
}

#pragma mark Continue Directions Request

- (void)sendRequestForDirections:(CHADestination *)start destination:(GAHDestination *)destination
{
    if ([destination.wfpName caseInsensitiveCompare:start.destinationName] == NSOrderedSame)
    {
        SIAlertView *sameLocation = [[SIAlertView alloc] initWithTitle:@"Wayfinding Route Error"
                                                            andMessage:@"Sorry, there was an error. Please make sure the destination and the starting location are not the same."];
        [sameLocation addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeDefault handler:nil];
        [sameLocation show];
    }
    else
    {
        CHADestination *plotterDestination = [CHADestination wayfindingBasePointForMeetingPlaySlug:destination.wfpName
                                                                               wayfindingLocations:self.dataInitializer.wayfindingBaseLocations];
        if (plotterDestination == nil)
        {
            __block GAHDestination *closestDestination;
            
            NSString *destinationSlug = destination.wfpName;
            
            __block CGFloat currentHigh = 0;
            NSArray *plottedDestinations = [self.dataInitializer.meetingPlayLocations filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"wfpName.length > 0"]];
            [plottedDestinations enumerateObjectsUsingBlock:^(GAHDestination * obj, NSUInteger idx, BOOL *stop) {
                CGFloat matchPercent = [GAHFuzzySearch scoreString:destinationSlug against:obj.wfpName];
                if (matchPercent > currentHigh)
                {
                    closestDestination = obj;
                    currentHigh = matchPercent;
                }
            }];
            
            SIAlertView *showNoDestination = [[SIAlertView alloc] initWithTitle:@"Destination Error" andMessage:@"The destination hasn't been plotted yet, but we've chosen the closest matching location based on its name."];
            [showNoDestination addButtonWithTitle:@"Go There" type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alertView)
             {
                 if (start && closestDestination)
                 {
                     //                 [self.rootNavigationController loadWayfindingStart:start destination:closestDestination];
                 }
                 else
                 {
                     DLog(@"\ncouldntFindMatch %@", closestDestination);
                 }
             }];
            [showNoDestination addButtonWithTitle:@"Cancel" type:SIAlertViewButtonTypeCancel handler:nil];
            [showNoDestination show];
        }
        else
        {
            [self.rootNavigationController loadWayfindingStart:start
                                                   destination:destination];
        }
    }
}

- (void)presentDestinationSelection:(NSString *)presentDestinationReason
{
    if (self.selectionModalView == nil)
    {
        GAHSelectionModalView *newSelectionModal = [GAHSelectionModalView new];
        newSelectionModal.translatesAutoresizingMaskIntoConstraints = false;
        newSelectionModal.selectionModalDelegate = self;
        
        [newSelectionModal setupDefaultAppearance:true];
        
        self.selectionModalView = newSelectionModal;
        
        self.selectionModalView.cancelBlock = ^{
            newSelectionModal.dataSearchBar.text = @"";
        };
    }
    
    if (presentDestinationReason.length)
    {
        self.selectionModalView.containerDescription.text = presentDestinationReason;
    }
    
    [self.view addSubview:self.selectionModalView];
    
    [self.view addConstraints:[self.selectionModalView pinToSuperviewBoundsInsets:UIEdgeInsetsMake(10, 10, 10, 10)]];
    
    [self.selectionModalView prepareData:[self sortMeetingPlayDestinations:self.dataInitializer.meetingPlayLocations]];
}

#pragma mark - Helper Methods
- (void)makeReservations:(id)sender
{
    NSDictionary *linkItem = self.reservationData;
    
    if ([linkItem isKindOfClass:[NSDictionary class]])
    {
        NSString *link = [linkItem objectForKey:@"link"];
        [self processLink:link];
    }
}

#pragma mark - Initial Setup
- (void)loadHeaderData
{
    for (UIViewController *child in self.childViewControllers)
    {
        if ([child isKindOfClass:[GAHDetailHeaderViewController class]])
        {
            GAHDetailHeaderViewController *header = (GAHDetailHeaderViewController *)child;
            self.headerView = header;
            [header configureWithDataSource:self.locationData];
            
        }
        else if ([child isKindOfClass:[GAHMapViewController class]])
        {
            GAHMapViewController *mapView = (GAHMapViewController *)child;
            self.mapViewController = mapView;
            
            if (mapView)
            {
                mapView.mapViewDelegate = self;
                
                mapView.dataInitializer = self.dataInitializer;
                
                if (self.dataInitializer.mapDataSource)
                {
                    [mapView loadMapZoomToDestination:self.locationData zoomScale:defaultZoomScale animated:true completionHandler:nil];
                }
                else
                {
                    [mapView loadMap:true];
                }
                
                mapView.floorSelectorContainer.hidden = true;
            }
        }
    }
}

- (GAHDataSource *)loadData:(NSArray *)destinations
{
    GAHDataSource *meetingPlayDataSource = [[GAHDataSource alloc] init];
    meetingPlayDataSource.data = destinations;
    return meetingPlayDataSource;
}

- (void)configureWithDataSource:(GAHDataSource *)dataSource
{
    __weak __typeof(&*self)weakSelf = self;
    
    MBProgressHUD *fetchLocationData = [MBProgressHUD showHUDAddedTo:self.contentContainer animated:true];
    fetchLocationData.labelText = @"Fetching Details";
    
    [dataSource fetchDataForType:GAHDataCategoryLocation completionHandler:^(NSArray *data)
    {
        if ([data.firstObject isKindOfClass:[GAHDestination class]])
        {
            weakSelf.locationData = data.firstObject;
            NSArray *links = [NSArray arrayWithArray:weakSelf.locationData.links];
            
            __block NSDictionary *reservationData = nil;
            __block NSMutableArray *displayData = [NSMutableArray new];
            
            [links enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                
                if ([obj isKindOfClass:[NSDictionary class]])
                {
                    NSString *linkLabel = [obj objectForKey:@"label"];
                    if ([linkLabel caseInsensitiveCompare:@"reservations"] == NSOrderedSame)
                    {
                        reservationData = obj;
                    }
                    else
                    {
                        [displayData addObject:obj];
                    }
                }
            }];
            
            weakSelf.displayData = [NSArray arrayWithArray:displayData];
            weakSelf.reservationData = reservationData;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [weakSelf.headerView updateHeaderImage:weakSelf.locationData];
                [weakSelf configureReservations:weakSelf.reservationData];
                [weakSelf configureDetailsConstants:weakSelf.displayData.count];
                
                [weakSelf.mainDetailsCollectionView reloadData];

                [weakSelf.extraDetailsTextView setNeedsUpdateConstraints];
                [weakSelf setupTextView:weakSelf.locationData];
                
                NSString *roomInfoKey = weakSelf.locationData.roomKey.length ? weakSelf.locationData.roomKey : @"M-VBJ463";
                [weakSelf setupDetailsWebview:weakSelf.locationData roomKey:roomInfoKey];
                weakSelf.extraDetailsHeight.constant = weakSelf.extraDetailsTextView.superview.frame.size.height;
                
                [MBProgressHUD hideAllHUDsForView:weakSelf.contentContainer animated:true];
            });
        }
        else
        {
            fetchLocationData.labelText = @"Fetch Failed";
            [fetchLocationData hide:true afterDelay:0.5f];
        }
    }];
}
- (void)configureReservations:(NSDictionary *)reservationData
{
    if (reservationData)
    {
        self.reservationHeight.constant = 40;
        self.reservationDistance.constant = 10;
    }
}

- (void)configureDetailsConstants:(NSInteger)displayDataCount
{
    if (displayDataCount > 0)
    {
        [self.contentContainer layoutIfNeeded];
        
        self.moreItemsLabelWidth.constant = (displayDataCount < 4 ? 0 : 25);
        self.moreItemsLabel.backgroundColor = displayDataCount > 1 ? UIColorFromRGB(0xaaaaaa) : [UIColor lightGrayColor];
        
        self.mainDetailsHeight.constant = 100;
        
        [UIView animateWithDuration:0.3
                              delay:0.1
             usingSpringWithDamping:0.9
              initialSpringVelocity:1
                            options:0
                         animations:^
         {
             [self.contentContainer layoutIfNeeded];
         } completion:nil];
    }
}

#pragma mark View Setup

- (void)setPageTitleText:(GAHDestination *)locationData
{
    NSString *pageTitle = locationData.location;
    
    if (pageTitle.length > 0)
    {
        self.navigationItem.title = pageTitle.uppercaseString;
        [self.navigationItem setTitleView:nil];
    }
}

- (void)setupButton:(UIButton *)styledButton directionsButton:(BOOL)isDirections
{
    styledButton.backgroundColor = (isDirections ? kTan : [UIColor gaylordBlue]);
    styledButton.layer.cornerRadius = 3.f;
    
    [styledButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    styledButton.titleLabel.font = [UIFont fontWithName:@"MyriadPro-Bold" size:14.f];
    styledButton.titleLabel.adjustsFontSizeToFitWidth = true;
    styledButton.titleLabel.minimumScaleFactor = 0.5f;
    
    [styledButton setTitle:(isDirections ? @"TAKE ME HERE (BEGIN WAYFINDING)" : @"MAKE RESERVATIONS")
                  forState:UIControlStateNormal];
    
    SEL buttonAction = (isDirections ? @selector(loadDirections:) : @selector(makeReservations:));
    
    [styledButton addTarget:self
                     action:buttonAction
           forControlEvents:UIControlEventTouchUpInside];
}

- (void)configureMapContainer:(UIView *)mapContainer
{
    mapContainer.layer.shadowColor = [UIColor blackColor].CGColor;
    mapContainer.layer.shadowOpacity = 0.5f;
    mapContainer.layer.shadowRadius = 2.f;
    mapContainer.layer.shadowOffset = CGSizeMake(0, 1);
    
    mapContainer.layer.borderColor = [UIColor whiteColor].CGColor;
    mapContainer.layer.borderWidth = 3.f;
}

- (void)setupTextView:(GAHDestination *)destination
{
    NSString *htmlString =  @"";
    for (NSDictionary *details in destination.details)
    {
        htmlString = [htmlString stringByAppendingString:[details objectForKey:@"description"]];
    }
    
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"\t" withString:@"&nbsp;&nbsp;&nbsp;&nbsp;"];
    
    NSMutableAttributedString *attributedString =
    [[NSMutableAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding]
                                            options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType}
                                 documentAttributes:nil
                                              error:nil];
    if (attributedString.length > 1)
    {
        [attributedString setAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"MyriadPro-Regular" size:15.f]}
                                  range:NSMakeRange(0, attributedString.length-1)];
    }
    
    self.extraDetailsTextView.textColor = [UIColor blackColor];
    self.extraDetailsTextView.attributedText = attributedString;
}

- (void)setupDetailsWebview:(GAHDestination *)destination roomKey:(NSString *)roomKey
{
    NSString *locationDescription =  @"";
    for (NSDictionary *details in destination.details)
    {
        locationDescription = [locationDescription stringByAppendingString:[details objectForKey:@"description"]];
    }
    
    if (locationDescription.length)
    {
        self.extraDetailsWebView = nil;
    }
    else
    {
        if (roomKey.length)
        {
            NSString *eventRoomDetails = [NSString stringWithFormat:[NSString roomEventDetails],roomKey];
            NSURLRequest *eventRoomDetailsRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:eventRoomDetails]];
            [self.extraDetailsWebView loadRequest:eventRoomDetailsRequest];
            self.extraDetailsWebView.hidden = false;
        }
        else
        {
            SIAlertView *noRoomKeyAlert = [[SIAlertView alloc] initWithTitle:@"No Room Key Found" andMessage:@"No room key has been associated to this room."];
            [noRoomKeyAlert addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeDefault handler:nil];
            [noRoomKeyAlert show];
            
            self.extraDetailsWebView.hidden = true;
        }
    }
}

#pragma mark - Auto Layout Setup
- (void)setupConstraints
{
    [super setupConstraints];
    
    NSLayoutConstraint *top = [self.headerContainer pinToTopSuperview];
    NSLayoutConstraint *leading = [self.headerContainer pinLeading];
    NSLayoutConstraint *trailing = [self.headerContainer pinTrailing];
    NSLayoutConstraint *width = [self.headerContainer equalWidth];
    self.headerHeight = [self.headerContainer height:NSLayoutRelationEqual multiplier:0.4f];
    NSLayoutConstraint *bottom = [self.headerContainer pinSide:NSLayoutAttributeBottom toView:self.contentContainer secondViewSide:NSLayoutAttributeTop];

    self.headerConstraints = [NSMutableArray arrayWithArray:@[top,leading,trailing,width,self.headerHeight,bottom]];
    [self.headerContainer.superview addConstraints:self.headerConstraints];
    
    self.mainDetailsHeight.constant = 0;
    self.reservationHeight.constant = 0;
    self.reservationDistance.constant = 0;
    
    [self applySmallConstraints];
}

- (void)toggleExpandConstraintsButtonAppearance:(BOOL)showingButton
{
    self.mapViewController.view.userInteractionEnabled = !self.mapViewController.view.userInteractionEnabled;
    
    UIColor *buttonColor = nil;
    NSString *buttonTitleString = [CHAFontAwesome icon:@"fa-close"];
    
    if (showingButton)
    {
        self.expandMapButton.hidden = false;

        buttonColor = [UIColor darkGrayColor];
    }
    else
    {
        self.expandMapButton.hidden = true;

        buttonColor = [UIColor clearColor];
    }
    
    [self.expandMapButton setBackgroundColor:buttonColor];
    [self.expandMapButton setTitle:buttonTitleString forState:UIControlStateNormal];
}

#pragma mark Expanding the Map View
- (GAHMapViewSize)expandMap:(id)sender
{
    [self.mapContainer removeFromSuperview];
    [self.view addSubview:self.mapContainer];
    
    if (self.mapContainerConstraints.count > 0 && self.expandMapConstraints)
    {
        [self.mapContainer.superview removeConstraints:self.expandMapConstraints];
    }
    
    BOOL becomeLarge = self.mapView.frame.size.height < 300 ? true : false;
    
    if (becomeLarge)
    {
        [self applyLargeConstraints];
    }
    else
    {
        [self applySmallConstraints];
    }
    
    [self toggleExpandConstraintsButtonAppearance:becomeLarge];
    
    GAHMapViewSize mapSize = (becomeLarge ? GAHMapViewSizeLarge : GAHMapViewSizeSmall);
    self.mapViewController.currentMapContainerSize = mapSize;
    
    return mapSize;
}

- (void)mapViewDidToggleSize:(GAHMapViewSize)mapSize
{
    BOOL expandingMap = true;
    if (mapSize == GAHMapViewSizeSmall)
    {
        expandingMap = false;
    }
    
    GAHMapViewSize newMapSize = [self expandMap:nil];
    
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.3
                          delay:0
         usingSpringWithDamping:0.8
          initialSpringVelocity:0.5
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^
     {
         [self.view layoutIfNeeded];
         
     } completion:^(BOOL finished) {
         
         if (finished)
         {
             self.mapViewController.currentMapContainerSize = newMapSize;

             [self.mapViewController zoomDestination:self.locationData
                                        mapImageData:[self.dataInitializer.mapDataSource
                                                      mapImageForDestination:self.locationData]
                                                 map:self.mapViewController.mapFloorImageView.image
                                           zoomScale:defaultZoomScale];
             
             [self.mapViewController.calloutView removeFromSuperview];
         }
     }];
}

- (void)applySmallConstraints
{
    self.mapViewController.currentMapContainerSize = GAHMapViewSizeSmall;

    self.mapLeading = [self.mapContainer pinSide:NSLayoutAttributeLeading relation:NSLayoutRelationEqual constant:15];
    [self.mapContainer.superview addConstraint:self.mapLeading];
    
    self.mapWidth = [self.mapContainer width:NSLayoutRelationEqual constant:81.f];
    [self.mapContainer.superview addConstraint:self.mapWidth];

    self.mapHeight = [NSLayoutConstraint constraintWithItem:self.mapContainer attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self.mapContainer attribute:NSLayoutAttributeWidth multiplier:1.25/1.f constant:0];
    [self.mapContainer addConstraint:self.mapHeight];

    self.mapBottom = [self.mapContainer alignSide:NSLayoutAttributeBottom toView:self.headerContainer secondSide:NSLayoutAttributeBottom constant:-15];
    [self.mapContainer.superview addConstraint:self.mapBottom];

    self.mapContainerConstraints = @[self.mapLeading,self.mapWidth,self.mapHeight,self.mapBottom];
    
}

- (void)applyLargeConstraints
{
    self.mapViewController.currentMapContainerSize = GAHMapViewSizeLarge;
    
    self.mapContainerConstraints = [self.mapContainer pinToSuperviewBounds];
    
    [self.mapContainer.superview addConstraints:self.mapContainerConstraints];
    
    [self.mapViewController loadMapZoomToDestination:self.locationData zoomScale:defaultZoomScale animated:true completionHandler:nil];
}


- (void)beaconSelection
{
    UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
    pickerView.backgroundColor = [UIColor lightGrayColor];
    pickerView.translatesAutoresizingMaskIntoConstraints = false;
    pickerView.dataSource = self;
    pickerView.delegate = self;
    
    [self.view addSubview:pickerView];
    [pickerView addConstraint:[pickerView height:200]];
    [pickerView.superview addConstraints:@[[pickerView pinLeading],[pickerView pinTrailing],[pickerView pinToBottomSuperview]]];
    
    [pickerView reloadAllComponents];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.placedTransmitters.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    MDCustomTransmitter *customTransmitter = self.placedTransmitters[row];
    
    return customTransmitter.identifier;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    MDCustomTransmitter *transmitter = self.placedTransmitters[row];
    
    NSLog(@"transmitter %@", transmitter.identifier);
    
    if ([self shouldLoadDirections:transmitter] == YES)
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:true];
        hud.labelText = @"Calculating Route";
        
        // check for a default start or a related slug
        CHADestination *startPoint = [self destinationForTransmitter:transmitter];
        
        if (startPoint)
        {
            [self sendRequestForDirections:startPoint
                               destination:self.locationData];
        }
        else
        {
//            [self presentDestinationSelection];
            [self showMultipleStartLocationsNearby:transmitter];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideAllHUDsForView:self.view animated:true];
        });
    }
    else
    {
        DLog(@"\nno active transmitter");
    }
    [pickerView removeFromSuperview];
}

#pragma mark - Locations for Beacons
- (void)showMultipleStartLocationsNearby:(MDCustomTransmitter *)nearbyBeacon
{
    NSArray *nearbyLocations = [self startLocationsForBeacon:nearbyBeacon];
    if (nearbyLocations.count > 1)
    {
        GAHSelectionModalView *newSelectionModal = [GAHSelectionModalView new];
        newSelectionModal.translatesAutoresizingMaskIntoConstraints = false;
        
        newSelectionModal.selectionModalDelegate = self;
        
        [newSelectionModal setupDefaultAppearance:false];
        
        newSelectionModal.containerTitle.text = @"Multiple Start Locations";
        newSelectionModal.containerDescription.text = @"We've found a few possible start locations near your location. Please choose the closest one.";
        
        self.selectionModalView = newSelectionModal;
        
        self.selectionModalView.cancelBlock = nil;
        
        [self.view addSubview:self.selectionModalView];
        
        [self.view addConstraints:[self.selectionModalView pinToSuperviewBoundsInsets:UIEdgeInsetsMake(10, 10, 10, 10)]];
        
        [self.selectionModalView prepareData:nearbyLocations];
    }
    else
    {
        CHADestination *nearestDestination = nil;
        if (nearbyLocations.count)
        {
            nearestDestination = [CHADestination wayfindingBasePointForMeetingPlaySlug:[nearbyLocations.firstObject wfpName]
                                                                   wayfindingLocations:self.dataInitializer.mapDataSource.mapDestinations];
        }
        else
        {
            nearestDestination = [self.dataInitializer findNearestDestination:nearbyBeacon];
        }
        
        if (nearestDestination)
        {
            [self sendRequestForDirections:nearestDestination
                               destination:self.locationData];
        }
        else
        {
            NSString *beaconDestinationErrorMessage = [NSString stringWithFormat:@"Sorry, but we couldn't find any locations near your beacon %@. Please select a start destination.", nearbyBeacon.identifier];
            [self presentDestinationSelection:beaconDestinationErrorMessage];
        }
    }
}

- (NSArray *)startLocationsForBeacon:(MDCustomTransmitter *)beacon
{
    __block NSArray *startLocationOptions = [NSArray new];
    
    NSDictionary *beaconStartLocationsAll = [self beaconStartLocations];
    NSArray *startLocationSlugs = [beaconStartLocationsAll objectForKey:beacon.identifier.uppercaseString];

    [startLocationSlugs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        GAHDestination *destination = [GAHDestination existingDestination:obj inCollection:self.dataInitializer.meetingPlayLocations];
        if (destination)
        {
            startLocationOptions = [startLocationOptions arrayByAddingObject:destination];
        }
    }];
    
    return startLocationOptions;
}

- (NSDictionary *)beaconStartLocations
{
    NSDictionary *beaconStartLocations = self.startLocations;
    
    if (beaconStartLocations.allValues.count == 0)
    {
        beaconStartLocations = @{@"GS64-67TBT": @[@"national-harbor-10",
                                                  @"national-harbor-9"]};
    }

    return beaconStartLocations;
}

- (void)fetchStartLocations:(void(^)(NSDictionary *,NSError *))completionHandler
{
    NSMutableURLRequest *startLocationsRequest = [NSMutableURLRequest defaultRequestMethod:@"GET"
                                                                                       URL:@"http://deploy.meetingplay.com/gaylord/startLocations.json"
                                                                                parameters:nil];
    __weak __typeof(&*self)weakSelf = self;
    [[[NSURLSession sharedSession] dataTaskWithRequest:startLocationsRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        id responseObject;
        
        if (error)
        {
            DLog(@"\nfetch start locations error %@", error);
        }
        else
        {
            responseObject = [NSURLSession serializeJSONData:data response:response error:error];
            if ([responseObject isKindOfClass:[NSDictionary class]])
            {
                weakSelf.startLocations = [responseObject objectForKey:@"data"];
            }
        }
        
        if (completionHandler)
        {
            completionHandler(responseObject,error);
        }
    }] resume];
}

@end


#pragma mark - Detail Content Cell
@implementation GAHDetailContentCell
- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.iconLabel.font = [UIFont fontWithName:@"FontAwesome" size:40.f];
    self.iconLabel.textColor = [UIColor gaylordBlue];
    self.iconLabel.adjustsFontSizeToFitWidth = true;
    self.iconLabel.minimumScaleFactor = 0.01f;
    self.iconLabel.text = @"\uf095";

    self.detailsLabel.font = [UIFont fontWithName:@"MyriadPro-Bold" size:12.f];
    self.detailsLabel.textColor = UIColorFromRGB(0x646464);
    self.detailsLabel.text = @"+1-432-646-9873";
}

@end