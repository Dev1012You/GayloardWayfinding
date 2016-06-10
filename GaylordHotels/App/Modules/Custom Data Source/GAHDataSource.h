//
//  GAHDataSource.h
//  GaylordHotels
//
//  Created by MeetingPlay on 5/4/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTPViewControllerDataSource.h"

#import <UIKit/UICollectionView.h>
#import <UIKit/UICollectionViewCell.h>
#import <UIKit/UICollectionViewFlowLayout.h>

@class GAHDestination, GAHPropertyCategory;

typedef NS_ENUM(NSUInteger, GAHDataCategory)
{
    GAHDataCategoryLocation = 0,
    GAHDataCategoryMainHotel = 1,
    GAHDataCategoryFloor1    = 2,
    GAHDataCategoryRestaurants = 10,
    GAHDataCategoryRecreation = 11,
    GAHDataCategoryFeatured = 20,
};

typedef NS_ENUM(NSUInteger, GAHDataSourceUpdateState)
{
    GAHDataSourceUpdateStateNotFetching = 0,
    GAHDataSourceUpdateStateFetching,
    GAHDataSourceUpdateStateDidFinishFetching,
};

typedef void(^CellLayoutHandler)(UICollectionViewCell *cell, id cellData, NSIndexPath *indexPath);
typedef void(^CellSelectionHandler)(id cellData);
typedef CGSize(^CellHeightCalculation)(UIView *targetView);

@interface GAHDataSource : NSObject <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, readonly) GAHDataSourceUpdateState updateState;

@property (nonatomic, copy) CellLayoutHandler cellLayoutHandler;
@property (nonatomic, copy) CellSelectionHandler cellSelectionHandler;
@property (nonatomic, copy) CellHeightCalculation cellHeightCalculation;

@property (nonatomic, strong) NSString *cellReuseIdentifier;
@property (nonatomic, strong) NSArray *meetingPlayDestinations;
@property (nonatomic, strong) NSArray *data;

@property (nonatomic, assign) GAHDataCategory dataCategory;
@property (nonatomic, strong) NSArray *categoryItems;


- (void)localDataForCategory:(GAHPropertyCategory *)category
           completionHandler:(void(^)(NSArray *))successHandler
              failureHandler:(void(^)(NSError *))errorHandler;

- (void)fetchDataForType:(GAHDataCategory)dataCategory
       completionHandler:(void(^)(NSArray *))completionHandler;

- (void)filterList:(NSString *)searchCriteria data:(NSArray *)data;

@end
