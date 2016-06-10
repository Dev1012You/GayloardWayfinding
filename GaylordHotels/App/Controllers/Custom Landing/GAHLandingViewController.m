//
//  GAHLandingViewController.m
//  GaylordHotels
//
//  Created by MeetingPlay on 4/27/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "GAHLandingViewController.h"
#import "UIView+AutoLayoutHelper.h"
#import "GAHBaseNavigationController.h"
#import "GAHAPIDataInitializer.h"
#import "GAHMainMenuViewController.h"
#import "MTPMenuItem.h"

#import "GAHDataSource.h"
#import "GAHDestination.h"
#import "CHADestination.h"

#import "GAHLandingCell.h"
#import "GAHLocationDetailsViewController.h"
#import "GAHStoryboardIdentifiers.h"

#import "UIImageView+AFNetworking.h"
#import "UIView+MTPCategory.h"

#import "UIButton+GAHCustomButtons.h"
#import "UIButton+MTPNavigationBar.h"
#import "NSURLSession+MTPCategory.h"

#import "MBProgressHUD.h"
#import "AFNetworkReachabilityManager.h"

#import "GAHNotificationView.h"
#import "GAHCouponView.h"


#import "MDCustomTransmitter.h"

@interface GAHLandingViewController () <UICollectionViewDelegateFlowLayout, UIWebViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, GAHCouponDelegate, UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) MBProgressHUD *featuredHUD;
@property (nonatomic, strong) UIView *termsContainer;
@property (nonatomic, strong) UIWebView *termsWebView;

@property (nonatomic, strong) NSArray *featuredLocations;

@property (nonatomic, strong) NSArray *debugBeaconData;
@property (nonatomic, strong) UITableView *debugBeaconTable;
@end

@implementation GAHLandingViewController
#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self setupConstraints];
    [self setupHeaderBackground];
    
    [self.contentContainer setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"defaultTexture"]]];
    
    self.landingCollectionLabel.font = [UIFont fontWithName:@"MyriadPro-Regular" size:14.f];
    self.landingCollectionLabel.textColor = [UIColor whiteColor];
    self.landingCollectionLabel.backgroundColor = kTan;

    [self setupContentDataSource];

    [self configureWithDataSource:self.configurationDataSource];
    
    self.landingCollectionView.dataSource = self;
    self.landingCollectionView.delegate = self;
    
    [UIView createLayerShadow:self.landingCollectionLabel.layer];
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"debugEnabled"] boolValue])
    {
        [self debug];
    }
    
    self.featuredHUD = [[MBProgressHUD alloc] initWithView:self.view];
    self.featuredHUD.labelText = @"Loading Locations";
    
    UITapGestureRecognizer *tapToOpenExplore = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadExploreSection:)];
    [self.headerContainer addGestureRecognizer:tapToOpenExplore];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:false];
    
    BOOL hasShownTerms = [[NSUserDefaults standardUserDefaults] boolForKey:@"shownTerms"];
    if (!hasShownTerms)
    {
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"shownTerms"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self.navigationController.navigationBar setUserInteractionEnabled:false];
        [self.contentContainer setUserInteractionEnabled:false];
        
        self.termsContainer = [self showTerms];
        [self.view addSubview:self.termsContainer];
        [self.view addConstraints:[self.termsContainer pinToSuperviewBoundsConstant:5]];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.termsWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://deploy.meetingplay.com/gaylord/terms"]]];
}

- (UIView *)showTerms
{
    UIView *terms = [UIView new];
    terms.layer.cornerRadius = 5;
    terms.layer.shadowColor = [UIColor blackColor].CGColor;
    terms.layer.shadowOpacity = 1;
    terms.layer.shadowRadius = 20;
    
    terms.translatesAutoresizingMaskIntoConstraints = false;

    UIWebView *termsWebView = [UIWebView new];
    self.termsWebView = termsWebView;
    termsWebView.translatesAutoresizingMaskIntoConstraints = false;
    termsWebView.scalesPageToFit = true;
    termsWebView.delegate = self;
    [terms addSubview:termsWebView];
    
    UIButton *agree = [UIButton new];
    agree.translatesAutoresizingMaskIntoConstraints = false;
    [agree setBackgroundColor:[UIColor colorWithRed:0/255.0 green:0/255.0 blue:100/255.0 alpha:1.0f]];
    [agree.titleLabel setFont:[UIFont fontWithName:@"MyriadPro-Bold" size:17.f]];
    [agree setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [agree setTitle:@"I Understand" forState:UIControlStateNormal];
    [agree addTarget:self action:@selector(hideTerms:) forControlEvents:UIControlEventTouchUpInside];
    [agree addConstraint:[agree height:44]];
    
    [terms addSubview:agree];
    [terms addConstraints:[agree pinSides:@[@(NSLayoutAttributeLeading),@(NSLayoutAttributeTrailing),@(NSLayoutAttributeBottom)] constant:5]];
    
    [terms addConstraints:@[[termsWebView pinToTopSuperview:5],[termsWebView pinLeading:5],[termsWebView pinTrailing:5],[termsWebView pinSide:NSLayoutAttributeBottom toView:agree secondViewSide:NSLayoutAttributeTop constant:5]]];
    
    return terms;
}

- (void)hideTerms:(id)sender
{
    [self.termsContainer removeFromSuperview];
    [self.navigationController.navigationBar setUserInteractionEnabled:true];
    [self.contentContainer setUserInteractionEnabled:true];
}

- (void)showNoLocations
{
    [self loadData:nil];
    
    __weak __typeof(&*self)weakSelf = self;
    SIAlertView *noLocations = [[SIAlertView alloc] initWithTitle:@"Fetching Featured Locations" andMessage:@"There was a problem fetching the featured locations. Check your internet connection and please try again."];
    [noLocations addButtonWithTitle:@"Try Again" type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alertView)
    {
        [weakSelf fetchMeetingPlayLocations];
    }];
    
    [noLocations addButtonWithTitle:@"Cancel" type:SIAlertViewButtonTypeCancel handler:nil];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideAllHUDsForView:self.view animated:true];
        [noLocations show];
    });
}

#pragma mark - Helper Methods
- (void)loadData:(NSArray *)destinations
{
    NSInteger featuredLocationsCount = 0;
    if (destinations)
    {
        self.featuredLocations = destinations;
        featuredLocationsCount = destinations.count;
        [self.landingCollectionView reloadData];
    }
    
    self.landingCollectionLabel.text = [[NSString stringWithFormat:@"%ld FEATURED LOCATION%@",
                                         featuredLocationsCount,
                                         featuredLocationsCount == 1 ? @"" : @"s"] uppercaseString];
}

- (void)fetchMeetingPlayLocations
{
    [MBProgressHUD showHUDAddedTo:self.view animated:true];
    
    __weak __typeof(&*self)weakSelf = self;
    [self.dataInitializer fetchMeetingPlayLocations:^(NSArray *locations, NSError *fetchError) {
        if (fetchError)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf showNoLocations];
            });
        }
        else
        {
            [weakSelf fetchFeatured:locations];
        }
    }];
}

- (void)fetchFeatured:(id)content
{
    __weak __typeof(&*self)weakSelf = self;
    [self fetchFeaturedLocations:^(NSArray *fetchedData,NSError *fetchFeaturesError)
     {
         NSMutableArray *featuredLocations = [NSMutableArray new];
         
         if (fetchFeaturesError)
         {
             [weakSelf showNoLocations];
         }
         else
         {
             if (fetchedData.count > 0)
             {
                 NSSet *fetchedSlugs = [NSSet setWithArray:fetchedData];
                 for (id destination in content)
                 {
                     if ([destination isKindOfClass:[GAHDestination class]])
                     {
                         GAHDestination *mpDestination = destination;
                         if ([fetchedSlugs containsObject:mpDestination.slug])
                         {
                             [featuredLocations addObject:destination];
                         }
                     }
                 }
             }
             else
             {
                 SIAlertView *noLocationsFound = [[SIAlertView alloc] initWithTitle:@"No Locations Found" andMessage:@"There are currently no featured locations!"];
                 [noLocationsFound addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeDefault handler:nil];
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [noLocationsFound show];
                 });
             }
         }
         
         dispatch_async(dispatch_get_main_queue(), ^{
             [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:true];
             [weakSelf loadData:featuredLocations];
         });
     }];
}

#pragma mark - Protocol Conformance
- (void)reloadContent:(id)content dataType:(GAHDataType)dataType reloadError:(NSError *)reloadError
{
    if (dataType == GAHDataTypeMeetingPlayLocation)
    {
        if ([content isKindOfClass:[NSArray class]])
        {
            if ([content count] == 0)
            {
                [self showNoLocations];
                return;
            }
            
            [self fetchFeatured:content];
        }
        else
        {
            [self showNoLocations];
        }
    }
    else if (dataType == GAHDataTypeMapData)
    {
        if ([content isKindOfClass:[GAHMapDataSource class]])
        {
            self.mapDataSource = content;
        }
    }
    else
    {
        DLog(@"\nunknown data type %@", @(dataType));
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.featuredHUD hide:false];
    });
}

- (void)fetchFeaturedLocations:(void(^)(NSArray *fetchedData,NSError *fetchFeaturesError))completionHandler
{
    NSMutableURLRequest *featuredRequest = [NSURLSession defaultRequestMethod:@"GET" URL:@"http://mapsapi.meetingplay.com/property/3/locations/featured" parameters:nil];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:featuredRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        NSMutableArray *locationSlugs = [NSMutableArray new];
        id jsonData = [NSURLSession serializeJSONData:data response:response error:error];
        if (jsonData && [jsonData isKindOfClass:[NSDictionary class]])
        {
            id locationsData = [[jsonData objectForKey:@"data"] objectForKey:@"locations"];
            if (locationsData && [locationsData isKindOfClass:[NSArray class]])
            {
                for (NSDictionary *location in locationsData)
                {
                    NSString *locationName = [location objectForKey:@"slug"];
                    if (locationName.length > 0)
                    {
                        [locationSlugs addObject:locationName];
                    }
                }
            }
        }
        
        if (completionHandler)
        {
            completionHandler(locationSlugs,error);
        }
    }] resume];
}

#pragma mark - Initial Setup

#pragma mark - UICollectionView Protocol Conformance
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.featuredLocations.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GAHLandingCellIdentifier" forIndexPath:indexPath];
    GAHDestination *cellData = self.featuredLocations[indexPath.row];
    GAHLandingCell *landingCell = (GAHLandingCell *)cell;
    
    NSString *landingItemTitle =landingItemTitle = cellData.location;
    landingCell.landingItemTitle.text = landingItemTitle;
    
    [landingCell loadImageForCategory:cellData.category];
    
    landingCell.bannerImage.alpha = 0.5f;
    
    NSString *imageURL = cellData.image;
    imageURL = [imageURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    if (imageURL.length > 0)
    {
        landingCell.bannerImage.alpha = 1.f;
        NSURL *imageLocation = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",
                                                     [self.userDefaults objectForKey:@"GAHLocationImageURL"],imageURL]];
        [landingCell.bannerImage setImageWithURL:imageLocation
                                placeholderImage:nil];
    }
    else
    {
        landingCell.bannerImage.alpha = 0.25f;
        landingCell.bannerImage.image = [UIImage imageNamed:@"homeHeaderBackground"];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:true];
    
    id selectedData = [self.featuredLocations objectAtIndex:indexPath.row];
    
    if (selectedData)
    {
        GAHLocationDetailsViewController *explore = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:GAHExploreDetailViewControllerIdentifier];
        
        explore.rootNavigationController = self.rootNavigationController;
        explore.dataInitializer = self.dataInitializer;
        explore.directionsLoader = self.directionsLoader;
        
        explore.locationData = selectedData;
        
        [self.navigationController pushViewController:explore animated:true];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = CGRectGetWidth(collectionView.frame) - 12 * 2;
    CGFloat height = width * (3/4.f);
    
    return CGSizeMake(width, height);
}


- (void)setupContentDataSource
{
    self.contentDataSource = [[GAHDataSource alloc] init];
}

- (void)configureWithDataSource:(MTPViewControllerDataSource *)controllerDataSource
{
    [MBProgressHUD showHUDAddedTo:self.view animated:true];
    
    if (self.dataInitializer.meetingPlayLocations.count > 0)
    {
        [self fetchFeatured:self.dataInitializer.meetingPlayLocations];
    }
    else
    {
        [self fetchMeetingPlayLocations];
    }
}

- (void)setupHeaderBackground
{
    UIImageView *headerBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"homeHeaderBackground"]];
    headerBackground.translatesAutoresizingMaskIntoConstraints = false;
    headerBackground.contentMode = UIViewContentModeScaleToFill;
    [self.headerContainer addSubview:headerBackground];
    [headerBackground.superview addConstraints:[headerBackground pinToSuperviewBounds]];
}

- (IBAction)loadExploreSection:(id)sender
{
    __block MTPMenuItem * exploreItem;
    [self.mainMenuViewController.mainMenuItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        [obj enumerateKeysAndObjectsUsingBlock:^(id key, NSArray * menuItems, BOOL *stop) {
            
            for (MTPMenuItem *menuItem in menuItems)
            {
                if ([menuItem.title rangeOfString:@"navigate" options:NSCaseInsensitiveSearch].length > 0)
                {
                    exploreItem = menuItem;
                }
            }
        }];
    }];
    
    if (exploreItem)
    {
        [self.mainMenuViewController loadMainMenuItem:exploreItem];
    }
}

#pragma mark - Initialization
+ (instancetype)loadDestinations:(NSArray *)destinations
                   mapDataSource:(GAHMapDataSource *)mapDataSource
                  withStoryboard:(UIStoryboard *)storyboard
                   andIdentifier:(NSString *)storyboardIdentifier
{
    return [[GAHLandingViewController alloc] initWithDestinations:destinations
                                                    mapDataSource:mapDataSource
                                                   withStoryboard:storyboard
                                                    andIdentifier:storyboardIdentifier];
}

- (instancetype)initWithDestinations:(NSArray *)destinations
                       mapDataSource:(GAHMapDataSource *)mapDataSource
                      withStoryboard:(UIStoryboard *)storyboard
                       andIdentifier:(NSString *)storyboardIdentifier
{
    NSAssert(storyboard != nil, @"You must provide a storyboard");
    
    self = [storyboard instantiateViewControllerWithIdentifier:storyboardIdentifier];
    if (self)
    {
        _mapDataSource = mapDataSource;
        _destinations = destinations;
    }
    return self;
}

- (void)setupConstraints
{
    [super setupConstraints];
}

- (void)debug
{
//    [GAHCouponView loadInView:self.view urlRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.meetingplay.com/"]] delegate:self];
    
    UIView *containerView = [UIView new];
    containerView.translatesAutoresizingMaskIntoConstraints = false;
    [self.view addSubview:containerView];
    [containerView.superview addConstraints:[containerView pinToSuperviewBoundsInsets:UIEdgeInsetsMake(10, 10, 10, 10)]];
    
    UITableView *beaconsTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    beaconsTable.translatesAutoresizingMaskIntoConstraints = false;
    [containerView addSubview:beaconsTable];
    [beaconsTable.superview addConstraints:[beaconsTable pinSides:@[@(NSLayoutAttributeLeading),@(NSLayoutAttributeTrailing),@(NSLayoutAttributeTop)]
                                                         constant:0]];
    beaconsTable.delegate = self;
    beaconsTable.dataSource = self;
    
    self.debugBeaconTable = beaconsTable;
    
    UIButton *hideButton = [UIButton buttonWithType:UIButtonTypeCustom];
    hideButton.translatesAutoresizingMaskIntoConstraints = false;
    hideButton.backgroundColor = [UIColor blackColor];
    [hideButton setTitle:@"HIDE" forState:UIControlStateNormal];
    [hideButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [hideButton addTarget:containerView action:@selector(removeFromSuperview) forControlEvents:UIControlEventTouchUpInside];
    [containerView addSubview:hideButton];
    [hideButton.superview addConstraints:[hideButton pinSides:@[@(NSLayoutAttributeLeading),@(NSLayoutAttributeTrailing),@(NSLayoutAttributeBottom)]
                                                     constant:0]];
    [hideButton addConstraint:[hideButton height:44]];
    
    [beaconsTable.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[beaconsTable][hideButton]"
                                                                                  options:0
                                                                                  metrics:nil
                                                                                    views:@{@"beaconsTable":beaconsTable,
                                                                                            @"hideButton":hideButton}]];
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(reloadBeacons) userInfo:nil repeats:YES];
    [timer fire];
}

- (void)reloadBeacons
{
    NSArray *beacons = [NSArray arrayWithArray:self.rootNavigationController.beaconSightingManager.beaconManager.nearbyBeacons];
    self.debugBeaconData = beacons;
    [self.debugBeaconTable reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.debugBeaconData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DefaultCell"];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DefaultCell"];
    }
    
    MDCustomTransmitter *beacon = self.debugBeaconData[indexPath.row];
    
    NSString *beaconInfo = [NSString stringWithFormat:@"%@ --- RSSI: %@",beacon.identifier,beacon.RSSI];
    cell.textLabel.text = beaconInfo;
    
    return cell;
}






















@end