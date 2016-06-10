//
//  GAHContentViewController.m
//  GaylordHotels
//
//  Created by MeetingPlay on 5/6/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "GAHContentViewController.h"
#import "GAHLandingCell.h"
#import "GAHDestination.h"
#import "CHADestination.h"
#import "GAHPropertyCategory.h"
#import "MDBeaconManager.h"
#import "GAHBaseNavigationController.h"
#import "GAHRootNavigationController.h"
#import "GAHAPIDataInitializer.h"

#import "NSObject+EventDefaultsHelpers.h"
#import "UIImageView+AFNetworking.h"
#import "GAHLocationDetailsViewController.h"
#import "GAHStoryboardIdentifiers.h"

@interface GAHContentViewController () <UISearchBarDelegate>
@property (nonatomic, strong) GAHPropertyCategory *currentCategory;
@end

@implementation GAHContentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"defaultTexture"]];
    
    self.dataSourceDescription.backgroundColor = UIColorFromRGB(0x646464);
    
    [self updateLabels];
}

- (void)updateLabels
{
    for (UILabel *dataSourceDescriptionLabel in @[self.categoryItems,self.categoryName])
    {
        dataSourceDescriptionLabel.textColor = [UIColor whiteColor];
        UIFont *labelFont;
        if ([dataSourceDescriptionLabel isEqual:self.categoryName])
        {
            labelFont = [UIFont fontWithName:@"MyriadPro-Bold" size:12.f];
        }
        else
        {
            labelFont = [UIFont fontWithName:@"MyriadPro-Regular" size:12.f];
        }
        dataSourceDescriptionLabel.font = labelFont;
    }
}

- (void)configureCollectionView:(UICollectionView *)collectionView
                       withData:(GAHDataSource *)dataSource
{
        __weak __typeof(&*self)weakSelf = self;
    
    self.collectionViewData = dataSource;
    self.collectionViewData.meetingPlayDestinations = self.dataInitialzer.meetingPlayLocations;
    
    collectionView.dataSource = dataSource;
    collectionView.delegate = dataSource;
    
    dataSource.cellReuseIdentifier = @"GAHLandingCellIdentifier";
    [dataSource setCellLayoutHandler:^(UICollectionViewCell *cell, GAHDestination *cellData, NSIndexPath *indexPath)
     {
         if ([cell isKindOfClass:[GAHLandingCell class]])
         {
             GAHLandingCell *landingCell = (GAHLandingCell *)cell;
             
             NSString *landingItemTitle = cellData.location;
             landingCell.landingItemTitle.text = landingItemTitle;
             [landingCell loadImageForCategory:cellData.category];
             
             NSString *imageURL = cellData.image;
             imageURL = [imageURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
             if (imageURL.length > 0)
             {
                 landingCell.dimmingView.alpha = 0;
                 NSURL *imageLocation = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",
                                                              [weakSelf.userDefaults objectForKey:@"GAHLocationImageURL"],imageURL]];
                 
                 [landingCell.bannerImage setImageWithURL:imageLocation
                                         placeholderImage:[UIImage imageNamed:@"homeHeaderBackground"]];
             }
             else
             {
                 landingCell.dimmingView.alpha = .9f;
                 landingCell.bannerImage.image = [UIImage imageNamed:@"homeHeaderBackground"];
             }
         }
     }];
    
    [dataSource setCellSelectionHandler:^(GAHDestination *selectedData)
     {
         GAHLocationDetailsViewController *explore = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:GAHExploreDetailViewControllerIdentifier];
         explore.dataInitializer = weakSelf.dataInitialzer;
         explore.directionsLoader = weakSelf.directionsLoader;
         explore.rootNavigationController = weakSelf.rootNavigationController;
         
         explore.locationData = selectedData;
         
         [weakSelf.navigationController pushViewController:explore animated:true];
     }];
    
    [self.contentCollectionView reloadData];
    
    if (self.currentCategory)
    {
        [self displayCategory:self.currentCategory];
    }
}

- (void)displayCategory:(GAHPropertyCategory *)category
{
    __weak __typeof(&*self)weakSelf = self;
    self.currentCategory = category;
    [self.collectionViewData localDataForCategory:category
                                completionHandler:^(NSArray *localDestinations)
     {
         [weakSelf.contentCollectionView reloadData];
         [weakSelf updateDescriptionForCategory:category
                                       withData:localDestinations];
         [weakSelf.contentCollectionView setContentOffset:CGPointZero animated:true];
         
     } failureHandler:^(NSError *loadingError) {
         
         DLog(@"\nloading error %@", loadingError);
     }
    ];
}

- (void)fetchContentForCategory:(GAHDataCategory)category
                   inDataSource:(GAHDataSource *)dataSource
{
//    __weak __typeof(&*self)weakSelf = self;
    
//    [dataSource fetchDataForType:category
//               completionHandler:^(NSArray *fetchedItems)
//    {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [weakSelf updateDescriptionForCategory:category withData:dataSource];
//            [weakSelf.contentCollectionView reloadData];
//        });
//    }];
}

- (void)updateDescriptionForCategory:(GAHPropertyCategory *)category
                            withData:(NSArray *)dataSource
{
    self.categoryItems.text = [self categoryItemsText:dataSource];
    
    NSString *categoryString = category.categoryName;
    if (categoryString.length > 0)
    {
        self.categoryName.text = categoryString;
    }
    else
    {
        self.categoryName.text = @"";
    }
}

- (NSString *)categoryItemsText:(NSArray *)dataSource
{
    NSString *itemsDescription = [NSString stringWithFormat:@"%@ location%@ found in category",
                                  @(dataSource.count),
                                  (dataSource.count == 1) ? @"" : @"s"].capitalizedString;
    return itemsDescription;
}

- (NSString *)categoryDescription:(GAHDataCategory)category
{
    NSDictionary *categories = @{@(GAHDataCategoryMainHotel): @"Main Hotel",
                                 @(GAHDataCategoryRecreation): @"Recreation",
                                 @(GAHDataCategoryRestaurants): @"Restaurants"};
    return categories[@(category)];
}

- (void)mapView:(GAHMapViewController *)mapView didSelectDestination:(GAHDestination *)selectedDestination
{
    NSIndexSet *matchingDestinationSet = [self.collectionViewData.data indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop)
    {
        if ([[obj slug] isEqualToString:[selectedDestination slug]])
        {
            *stop = true;
            return true;
        }
        else
        {
            return false;
        }
        
    }];
    
    if (matchingDestinationSet.count > 0)
    {
        NSUInteger matchingItem = [matchingDestinationSet firstIndex];
        NSIndexPath *matchingItemPath = [NSIndexPath indexPathForItem:matchingItem inSection:0];

        [self.contentCollectionView scrollToItemAtIndexPath:matchingItemPath
                                           atScrollPosition:UICollectionViewScrollPositionCenteredVertically
                                                   animated:true];
    }
}

#pragma mark - Protocol Conformance
#pragma mark UISearchBar
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar;                     // called when text starts editing
{
    // change view constraints
    if (self.filterDelegate && [self.filterDelegate respondsToSelector:@selector(contentView:didStartFilter:)])
    {
        [self.filterDelegate contentView:self didStartFilter:searchBar];
    }
    self.contentCollectionView.contentInset = UIEdgeInsetsMake(0, 0, 200, 0);
    [searchBar setShowsCancelButton:true animated:true];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar;                       // called when text ends editing
{
    // change view constraints back
    if (self.filterDelegate && [self.filterDelegate respondsToSelector:@selector(contentView:didEndFilter:)])
    {
        [self.filterDelegate contentView:self didEndFilter:searchBar];
    }
    self.contentCollectionView.contentInset = UIEdgeInsetsZero;
    [searchBar setShowsCancelButton:false animated:true];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText;   // called when text changes (including clear)
{
    if (searchText.length == 0)
    {
        [self.collectionViewData setData:self.collectionViewData.categoryItems];
        [self.contentCollectionView reloadData];
    }
    else
    {
        [self.collectionViewData filterList:searchText data:self.collectionViewData.data];
        [self.contentCollectionView reloadData];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar;                     // called when keyboard search button pressed
{
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar;                     // called when cancel button pressed
{
    searchBar.text = @"";
    [self.collectionViewData setData:self.collectionViewData.categoryItems];
    [self.contentCollectionView reloadData];
    
    [searchBar resignFirstResponder];
}

#pragma mark - Initializers

+ (instancetype)loadContentDataSource:(GAHDataSource *)contentDataSource
                         destinations:(NSArray *)destinations
                        mapDataSource:(GAHMapDataSource *)mapDataSource
                       withStoryboard:(UIStoryboard *)storyboard
                        andIdentifier:(NSString *)storyboardIdentifier
{
    return [[GAHContentViewController alloc] initWithContentDataSource:contentDataSource
                                                          destinations:destinations
                                                         mapDataSource:mapDataSource
                                                        withStoryboard:storyboard
                                                         andIdentifier:storyboardIdentifier];
}

- (instancetype)initWithContentDataSource:(GAHDataSource *)contentDataSource destinations:(NSArray *)destinations mapDataSource:(GAHMapDataSource *)mapDataSource withStoryboard:(UIStoryboard *)storyboard andIdentifier:(NSString *)storyboardIdentifier
{
    NSAssert(storyboard != nil, @"You must provide a storyboard when creating a GAHContentViewController");
    self = [storyboard instantiateViewControllerWithIdentifier:storyboardIdentifier];
    if (self)
    {
        _collectionViewData = contentDataSource;
        _destinations = destinations;
        _mapDataSource = mapDataSource;
    }
    return self;
}










@end
