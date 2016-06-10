//
//  GAHLandingViewController.h
//  GaylordHotels
//
//  Created by MeetingPlay on 4/27/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "GAHBaseHeaderStyleViewController.h"

@class GAHMapDataSource;

@interface GAHLandingViewController : GAHBaseHeaderStyleViewController

@property (weak, nonatomic) IBOutlet UILabel *landingCollectionLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *landingCollectionView;

@property (nonatomic, strong) GAHMapDataSource *mapDataSource;
@property (nonatomic, strong) GAHDataSource *contentDataSource;
@property (nonatomic, strong) NSArray *destinations;

+ (instancetype)loadDestinations:(NSArray *)destinations
                   mapDataSource:(GAHMapDataSource *)mapDataSource
                  withStoryboard:(UIStoryboard *)storyboard
                   andIdentifier:(NSString *)storyboardIdentifier;

- (void)loadData:(NSArray *)destinations;
@end







