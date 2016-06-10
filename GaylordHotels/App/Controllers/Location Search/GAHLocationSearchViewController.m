//
//  GAHLocationSearchViewController.m
//  GaylordHotels
//
//  Created by MeetingPlay on 7/3/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "GAHLocationSearchViewController.h"
#import "GAHLocationDetailsViewController.h"
#import "GAHDestination.h"
#import "MBProgressHUD.h"
#import "GAHAPIDataInitializer.h"
#import "GAHStoryboardIdentifiers.h"
#import "GAHLandingCell.h"
#import "UIImageView+AFNetworking.h"

@interface GAHLocationSearchViewController ()
@end

@implementation GAHLocationSearchViewController

#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view sendSubviewToBack:self.mainMenuContainer];
    
//    self.contentDataSource.meetingPlayDestinations = self.dataInitializer.meetingPlayLocations;
    self.contentDataSource.cellReuseIdentifier = @"GAHLandingCellIdentifier";
    
    self.landingCollectionView.dataSource = self.contentDataSource;
    self.landingCollectionView.delegate = self.contentDataSource;
    
    self.matchingLocations = [NSArray new];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MBProgressHUD hideAllHUDsForView:self.view animated:true];
}

#pragma mark - Protocol Conformance
#pragma mark - IBActions
#pragma mark - Overridden Methods
- (void)loadData:(NSArray *)destinations
{
    if (destinations)
    {
        self.contentDataSource.data = destinations;
        self.landingCollectionView.dataSource = self.contentDataSource;
        
        [self.landingCollectionView reloadData];
        
        self.landingCollectionLabel.text = [[NSString stringWithFormat:@"%@ LOCATION%@ FOUND",
                                             @(self.contentDataSource.data.count),
                                             self.contentDataSource.data.count == 1 ? @"" : @"s"] uppercaseString];
    }
}

#pragma mark - Helper Methods
- (NSArray *)filterDestinations:(NSArray *)destinations criteria:(NSString *)criteria
{
    NSMutableArray *matchingDestinations =[NSMutableArray new];
    for (GAHDestination *destination in destinations)
    {
        if ([destination.location rangeOfString:criteria options:NSCaseInsensitiveSearch].location != NSNotFound)
        {
            [matchingDestinations addObject:destination];
        }
    }
    return matchingDestinations;
}

#pragma mark - Initial Setup
- (void)configureWithDataSource:(MTPViewControllerDataSource *)controllerDataSource
{
    __weak __typeof(&*self)weakSelf = self;
    
    [self.contentDataSource setCellLayoutHandler:^(UICollectionViewCell *cell, GAHDestination *cellData, NSIndexPath *indexPath)
     {
         if ([cell isKindOfClass:[GAHLandingCell class]])
         {
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
                                                              [weakSelf.userDefaults objectForKey:@"GAHLocationImageURL"],imageURL]];
                 [landingCell.bannerImage setImageWithURL:imageLocation
                                         placeholderImage:nil];
             }
             else
             {
                 landingCell.bannerImage.alpha = 0.25f;
                 landingCell.bannerImage.image = [UIImage imageNamed:@"homeHeaderBackground"];
             }
         }
     }];
    
    [self.contentDataSource setCellSelectionHandler:^(GAHDestination *selectedData)
     {
         GAHLocationDetailsViewController *explore = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:GAHExploreDetailViewControllerIdentifier];
         explore.rootNavigationController = weakSelf.rootNavigationController;
         explore.dataInitializer = weakSelf.dataInitializer;
         explore.directionsLoader = weakSelf.directionsLoader;
         explore.locationData = selectedData;
         
         [weakSelf.navigationController pushViewController:explore animated:true];
     }];
    
    NSString *searchCriteria = [controllerDataSource.additionalData objectForKey:@"searchTerm"];
    if (searchCriteria.length > 0)
    {
        self.matchingLocations = [self filterDestinations:self.dataInitializer.meetingPlayLocations criteria:searchCriteria];
    }
    
    [self loadData:self.matchingLocations];
}


#pragma mark - Auto Layout Setup
- (void)setupConstraints
{
    [super setupConstraints];
}


@end
