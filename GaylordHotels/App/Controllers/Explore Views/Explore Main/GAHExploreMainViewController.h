//
//  GAHExploreMainViewController.h
//  GaylordHotels
//
//  Created by MeetingPlay on 5/5/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "GAHBaseHeaderStyleViewController.h"
#import "GAHMapViewController.h"

@class GAHDataSource, GAHMapViewController, GAHContentViewController, MDBeaconManager;

@interface GAHExploreMainViewController : GAHBaseHeaderStyleViewController <GAHMapViewDelegate>

@property (nonatomic, strong) MDBeaconManager *beaconManager;

@property (nonatomic, strong) GAHContentViewController *contentCollectionViewController;
@property (nonatomic, strong) GAHMapViewController *mapViewController;

@property (nonatomic, strong) GAHPropertyCategory *currentCategory;

@property (nonatomic, strong) GAHDataSource *headerData;
@property (nonatomic, strong) GAHDataSource *contentData;

+ (instancetype)loadWithDestinations:(NSArray *)destinations
                          headerData:(GAHDataSource *)headerData
                       contentData:(GAHDataSource *)contentData
                      fromStoryboard:(UIStoryboard *)storyboard
                       andIdentifier:(NSString *)storyboardIdentifier;

- (void)loadPropertyCategories:(NSArray *)propertyCategories;
@end





@class GAHMapScrollHandler;

@protocol GAHMapScrollHidingDelegate <NSObject>
@optional
- (void)scrollHandler:(GAHMapScrollHandler *)scrollHandler toggleSelectorVisiblity:(BOOL)hidden;
@end

@interface GAHMapScrollHandler : NSObject <UIScrollViewDelegate>
@property (nonatomic, weak) id <UIScrollViewDelegate> zoomDelegate;
@property (nonatomic, weak) id <GAHMapScrollHidingDelegate> hidingDelegate;

@property (nonatomic, weak) NSLayoutConstraint *categoryContainerHeight;
@property (nonatomic, assign) BOOL shouldHideCategories;
@end