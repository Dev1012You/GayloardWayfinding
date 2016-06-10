//
//  GAHDirectionsViewController.h
//  GaylordHotels
//
//  Created by MeetingPlay on 5/1/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "MTPBaseViewController.h"
#import "CHARoute.h"

@class GAHDirectionsDataSource, GAHDirectionsViewController, GAHAPIDataInitializer, CHADestination, GAHDestination;

@protocol GAHDirectionsParsingDelegate <NSObject>
@optional
- (void)directionsView:(GAHDirectionsViewController *)directionsView didParseDirections:(GAHDirectionsDataSource *)directions;
@end

@interface GAHDirectionsViewController : MTPBaseViewController <CHARouteDirectionDisplayDelegate>
extern CGFloat const cellImageHeight;
@property (nonatomic, weak) id <GAHDirectionsParsingDelegate> directionsDelegate;

@property (strong, nonatomic) GAHDirectionsDataSource *directionsDataSource;
@property (nonatomic, strong) GAHAPIDataInitializer *dataInitializer;

@property (nonatomic, strong) NSArray *wayfindingDestinations;
@property (nonatomic, strong) NSArray *meetingPlayDestinations;

@property (nonatomic, strong) CHADestination *start;
@property (nonatomic, strong) GAHDestination *destination;

@property (weak, nonatomic) IBOutlet UICollectionView *directionsCollectionView;

- (void)clearDirections;

@end


#pragma mark Directions Data Source Class

@class CHARoute, GAHDirectionCell, CHADirectionSet;

@interface GAHDirectionsDataSource : NSObject <UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

typedef void (^DirectionsCellLayoutHandler)(GAHDirectionCell *cell, id directionSet, NSIndexPath *indexpath);

@property (nonatomic, weak) GAHDirectionsViewController *directionsViewController;
@property (nonatomic, strong) CHARoute *routeData;
@property (nonatomic, strong) NSArray *singleDirectives;
@property (nonatomic, strong) NSDictionary *directionDetails;
@property (nonatomic, strong) NSString *cellReuseIdentifier;
@property (nonatomic, strong) DirectionsCellLayoutHandler cellLayoutHandler;

- (instancetype)initWithCellIdentifier:(NSString *)cellIdentifier
                         cellLayoutHandler:(DirectionsCellLayoutHandler)cellLayoutHandler;

- (NSArray *)createSingleDirectiveDataSource:(NSArray *)directionSets;

- (void)resetDirectionData;
@end