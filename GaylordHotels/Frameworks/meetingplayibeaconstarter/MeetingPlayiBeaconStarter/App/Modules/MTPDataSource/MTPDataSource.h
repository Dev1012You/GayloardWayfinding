//
//  MTPDataSource.h
//  MeetingPlayiBeaconStarter
//
//  Created by John Pacheco on 4/9/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UITableView.h>
#import <UIKit/UICollectionView.h>
#import <UIKit/UICollectionViewCell.h>
#import "MTPViewControllerDataSource.h"

@class MTPSponsorManager, NSManagedObjectContext, MTPBeaconSightingManager, MDMyConnectionManager;

@protocol MTPCellLayoutDelegate <NSObject>
@optional
- (UICollectionViewCell *)layoutCell:(UICollectionViewCell *)cell
                      collectionView:(UICollectionView *)collectionView
                           indexPath:(NSIndexPath *)indexPath
                                data:(id)cellData;

- (UITableViewCell *)layoutCell:(UITableViewCell *)cell
                      tableView:(UITableView *)tableView
                      indexPath:(NSIndexPath *)indexPath
                           data:(id)cellData;
@end



@interface MTPDataSource : NSObject <UITableViewDataSource, UICollectionViewDataSource>
@property (nonatomic, weak) id <MTPCellLayoutDelegate> cellLayoutDelegate;
@property (nonatomic, strong) NSString *cellIdentifier;

+ (instancetype)dataSourceRootObjectContext:(NSManagedObjectContext *)rootObjectContext
                      beaconSightingManager:(MTPBeaconSightingManager *)beaconSightingManager
                          connectionManager:(MDMyConnectionManager *)connectionManager;

- (instancetype)initWithRootObjectContext:(NSManagedObjectContext *)rootObjectContext
                    beaconSightingManager:(MTPBeaconSightingManager *)beaconSightingManager
                        connectionManager:(MDMyConnectionManager *)connectionManager NS_DESIGNATED_INITIALIZER;

- (void)dataForTypes:(MTPDisplayStyle)contentTypes
            typeData:(NSDictionary *)additionalLoadingParameters
  shouldFetchFromAPI:(BOOL)shouldFetch
   completionHandler:(void(^)(NSArray *dataForTypes))completionHandler
      failureHandler:(void(^)(NSError *loadingError))failureHandler;

@end
