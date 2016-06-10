//
//  GAHExploreDetailViewController.h
//  GaylordHotels
//
//  Created by MeetingPlay on 5/7/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "GAHBaseHeaderStyleViewController.h"

@class GAHMapDataSource, MDBeaconManager, GAHMapViewController;

@interface GAHLocationDetailsViewController : GAHBaseHeaderStyleViewController

@property (strong, nonatomic) GAHDataSource *dataSource;

@property (nonatomic, strong) GAHDestination *locationData;

// detail content
@property (weak, nonatomic) IBOutlet UIButton *requestRouteButton;
@property (nonatomic, weak) IBOutlet UIButton *reservationsButton;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *reservationHeight;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *reservationDistance;

@property (weak, nonatomic) IBOutlet UICollectionView *mainDetailsCollectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mainDetailsHeight;

@property (weak, nonatomic) IBOutlet UITextView *extraDetailsTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *extraDetailsHeight;
@property (weak, nonatomic) IBOutlet UIWebView *extraDetailsWebView;

@property (weak, nonatomic) IBOutlet UILabel *moreItemsLabel;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *moreItemsLabelWidth;

// map container
@property (weak, nonatomic) IBOutlet UIView *mapContainer;
@property (weak, nonatomic) IBOutlet UIView *mapView;
@property (nonatomic, strong) GAHMapViewController *mapViewController;

@property (nonatomic, weak) IBOutlet UILabel *mapViewLabel;
@property (nonatomic, weak) IBOutlet UIButton *expandMapButton;
@property (nonatomic, strong) NSMutableArray *expandMapConstraints;

@property (nonatomic, strong) NSLayoutConstraint *mapTop;
@property (nonatomic, strong) NSLayoutConstraint *mapLeading;
@property (nonatomic, strong) NSLayoutConstraint *mapTrailing;
@property (nonatomic, strong) NSLayoutConstraint *mapBottom;
@property (nonatomic, strong) NSLayoutConstraint *mapHeight;
@property (nonatomic, strong) NSLayoutConstraint *mapWidth;


- (NSInteger)expandMap:(id)sender;

- (void)configureWithDataSource:(GAHDataSource *)dataSource;

@end


#pragma mark - Detail Content Cell
@interface GAHDetailContentCell : UICollectionViewCell
@property (nonatomic, weak) IBOutlet UILabel *iconLabel;
@property (nonatomic, weak) IBOutlet UILabel *detailsLabel;
@end


