//
//  GAHContentViewController.h
//  GaylordHotels
//
//  Created by MeetingPlay on 5/6/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "GAHBaseViewController.h"
#import "GAHRootNavigationController.h"
#import "GAHDataSource.h"
#import "GAHMapViewController.h"

@class GAHPropertyCategory, MDBeaconManager, GAHAPIDataInitializer, GAHContentViewController;

@protocol GAHCategoryFilterDelegate <NSObject>
@optional
- (void)contentView:(GAHContentViewController *)contenView didStartFilter:(UISearchBar *)filterBar;
- (void)contentView:(GAHContentViewController *)contenView didEndFilter:(UISearchBar *)filterBar;
@end

@interface GAHContentViewController : MTPBaseViewController <GAHMapViewDelegate>

@property (nonatomic, weak) id <MTPMainMenuToggling> mainMenuToggler;
@property (nonatomic, weak) id <GAHCategoryFilterDelegate> filterDelegate;
@property (nonatomic, strong) GAHDataSource *collectionViewData;
@property (nonatomic, strong) GAHRootNavigationController *rootNavigationController;

@property (weak, nonatomic) IBOutlet UIView *dataSourceDescription;
@property (weak, nonatomic) IBOutlet UILabel *categoryItems;
@property (weak, nonatomic) IBOutlet UILabel *categoryName;

@property (nonatomic, weak) IBOutlet UICollectionView *contentCollectionView;

#pragma mark Optional Properties
@property (nonatomic, weak) id <GAHWayfindingLoading> directionsLoader;
@property (nonatomic, strong) GAHAPIDataInitializer *dataInitialzer;
@property (nonatomic, strong) GAHMapDataSource *mapDataSource;
@property (nonatomic, strong) NSArray *destinations;
@property (nonatomic, strong) MDBeaconManager *beaconManager;

#pragma mark - Method Declarations

+ (instancetype)loadContentDataSource:(GAHDataSource *)contentDataSource
                         destinations:(NSArray *)destinations
                        mapDataSource:(GAHMapDataSource *)mapDataSource
                       withStoryboard:(UIStoryboard *)storyboard
                        andIdentifier:(NSString *)storyboardIdentifier;

- (void)configureCollectionView:(UICollectionView *)collectionView
                       withData:(GAHDataSource *)dataSource;

- (void)fetchContentForCategory:(GAHDataCategory)category
                   inDataSource:(GAHDataSource *)dataSource;

- (void)updateDescriptionForCategory:(GAHPropertyCategory *)category
                            withData:(NSArray *)dataSource;

- (void)displayCategory:(GAHPropertyCategory *)category;

@end
