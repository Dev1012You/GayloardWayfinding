//
//  GAHDetailContentViewController.h
//  GaylordHotels
//
//  Created by MeetingPlay on 5/8/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import "MTPBaseViewController.h"
#import "GAHRootNavigationController.h"
#import "GAHDataSource.h"
#import "GAHMapViewController.h"

@interface GAHDetailContentViewController : MTPBaseViewController

@property (nonatomic, weak) id <GAHWayfindingLoading> directionsLoader;
@property (nonatomic, weak) id <GAHMapViewDelegate> mapViewDelegate;

@property (strong, nonatomic) GAHDataSource *dataSource;

@property (weak, nonatomic) IBOutlet UIView *wayfindingContainer;
@property (weak, nonatomic) IBOutlet UIButton *requestRouteButton;

@property (weak, nonatomic) IBOutlet UICollectionView *mainDetailsCollectionView;

@property (weak, nonatomic) IBOutlet UITextView *extraDetailsTextView;

@property (weak, nonatomic) IBOutlet UIWebView *extraDetailsWebView;



- (void)configureWithDataSource:(GAHDataSource *)dataSource;

@property (weak, nonatomic) IBOutlet UILabel *moreItemsLabel;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *moreItemsLabelWidth;

@end


@interface GAHDetailContentCell : UICollectionViewCell
@property (nonatomic, weak) IBOutlet UILabel *iconLabel;
@property (nonatomic, weak) IBOutlet UILabel *detailsLabel;
@end