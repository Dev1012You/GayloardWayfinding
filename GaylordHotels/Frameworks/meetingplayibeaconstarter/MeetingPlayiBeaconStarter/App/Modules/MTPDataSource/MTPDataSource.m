//
//  MTPDataSource.m
//  MeetingPlayiBeaconStarter
//
//  Created by John Pacheco on 4/9/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "MTPDataSource.h"

#import "MTPSponsorManager.h"
#import "Sponsor+Helpers.h"

#import "MDMyConnectionManager.h"

#import "User+Helpers.h"
#import "NSObject+EventDefaultsHelpers.h"

#import "MTPBeaconSightingManager.h"
#import "MDBeaconManager.h"
#import "MDCustomTransmitter.h"

//#import "MTPAPIAddresses.h"
#import "NSString+MTPAPIAddresses.h"
#import "NSObject+EventDefaultsHelpers.h"
#import "NSURLSession+MTPCategory.h"

//#import "MTPSessionManager.h"
//#import "MTPSession.h"

@interface MTPDataSource ()
@property (nonatomic, strong) NSArray *dataCollection;
@property (nonatomic, strong) MTPSponsorManager *sponsorManager;
@property (nonatomic, strong) MTPBeaconSightingManager *beaconSightingManager;
@property (nonatomic, strong) MDMyConnectionManager *connectionManager;
//@property (nonatomic, strong) MTPSessionManager *sessionManager;
@property (nonatomic, strong) NSManagedObjectContext *scratchContext;
@property (nonatomic, assign) NSInteger networkTasks;
@property (nonatomic, strong) NSMutableSet *userIDs;
@end

@implementation MTPDataSource

+ (instancetype)dataSourceRootObjectContext:(NSManagedObjectContext *)rootObjectContext
                      beaconSightingManager:(MTPBeaconSightingManager *)beaconSightingManager
                          connectionManager:(MDMyConnectionManager *)connectionManager

{
    return [[MTPDataSource alloc] initWithRootObjectContext:rootObjectContext
                                      beaconSightingManager:beaconSightingManager
                                          connectionManager:connectionManager];
}

- (instancetype)initWithRootObjectContext:(NSManagedObjectContext *)rootObjectContext
                    beaconSightingManager:(MTPBeaconSightingManager *)beaconSightingManager
                        connectionManager:(MDMyConnectionManager *)connectionManager
{
    self = [super init];
    if (self) {
        _dataCollection = [NSArray new];
        _scratchContext = rootObjectContext;
        _sponsorManager = [[MTPSponsorManager alloc] initManagedObjectContext:rootObjectContext];
        _beaconSightingManager = beaconSightingManager;
        _connectionManager = connectionManager;
    }
    return self;
}

- (void)dataForTypes:(MTPDisplayStyle)contentTypes
            typeData:(NSDictionary *)additionalLoadingParameters
  shouldFetchFromAPI:(BOOL)shouldFetch
   completionHandler:(void (^)(NSArray *dataTypes))completionHandler
      failureHandler:(void (^)(NSError *loadingError))failureHandler
{
    if (self.networkTasks > 0)
    {
        NSError *loadingError = [NSError errorWithDomain:([NSURLSession bundleIdentifier] ? [NSURLSession bundleIdentifier] : @"com.MeetingPlay.ErrorDomain")
                                                    code:1013
                                                userInfo:@{NSLocalizedDescriptionKey: @"Did not begin new network tasks or add them to the queue.",
                                                           NSLocalizedFailureReasonErrorKey: @"There are existing network tasks to be completed. Waiting for them to finish before adding them to the queue."}];
        if (failureHandler)
        {
            failureHandler(loadingError);
        }
        return;
    }
    
    self.dataCollection = [NSArray new];
    self.userIDs = [NSMutableSet new];
    
    if (contentTypes == MTPDisplayStyleSponsorsAll ||
        contentTypes == MTPDisplayStyleUsersAll ||
        contentTypes == MTPDisplayStyleUsersNearby)
    {
        if (shouldFetch || contentTypes == MTPDisplayStyleUsersNearby)
        {
            [self fetchData:contentTypes typeData:additionalLoadingParameters completionHandler:completionHandler failureHandler:failureHandler];
        }
        else
        {
            [self loadData:contentTypes typeData:additionalLoadingParameters completionHandler:completionHandler failureHandler:failureHandler];
        }
    }
}

- (void)fetchData:(MTPDisplayStyle)contentTypes
         typeData:(NSDictionary *)additionalLoadingParameters
completionHandler:(void (^)(NSArray *dataTypes))completionHandler
   failureHandler:(void (^)(NSError *loadingError))failureHandler
{
    switch (contentTypes)
    {
        case MTPDisplayStyleUsersAll:{
//            fetchedData = [User allUsersInContext:self.scratchContext];
            abort();
            break;
        }
        case MTPDisplayStyleUsersNearby: {
//            completionHandler([User findUsers:@[@(854),@(855),@(856),@(857),@(858),@(859)] context:self.scratchContext]);
//            return;
            
            NSArray *nearbyBeacons = [[self.beaconSightingManager.beaconManager nearbyBeacons] copy];
            for (MDCustomTransmitter *nearbyBeacon in nearbyBeacons)
            {
                    [self sendAPIRequestURL:[NSString stringWithFormat:[NSString beaconAllUsers],nearbyBeacon.identifier]
                             forContentType:contentTypes
                         withAdditionalData:additionalLoadingParameters
                          completionHandler:completionHandler
                             failureHandler:failureHandler];
                
                self.networkTasks++;
            }
            
            if (nearbyBeacons.count == 0)
            {
                if (failureHandler) {
                    failureHandler([NSError errorWithDomain:([NSURLSession bundleIdentifier] ? [NSURLSession bundleIdentifier] : @"com.MeetingPlay.ErrorDomain")
                                                       code:1014
                                                   userInfo:@{NSLocalizedDescriptionKey: @"No beacons found nearby",
                                                              NSLocalizedFailureReasonErrorKey: @"You haven't been associated with any beacons yet."}]);
                }
            }
            break;
        }
        case MTPDisplayStyleUsersConnected:
        case MTPDisplayStyleSponsorsUnconnected:
        case MTPDisplayStyleSponsorsPending:
        case MTPDisplayStyleSponsorsNearby: {
//            fetchedData = [User allUsersInContext:self.scratchContext];
            abort();
            break;
        }
        default:
            break;
    }
}

- (void)loadData:(MTPDisplayStyle)contentTypes
        typeData:(NSDictionary *)additionalLoadingParameters
completionHandler:(void (^)(NSArray *dataTypes))completionHandler
  failureHandler:(void (^)(NSError *loadingError))failureHandler
{
    NSArray *fetchedData;
    
    switch (contentTypes)
    {
        case MTPDisplayStyleUsersAll:{
            fetchedData = [User allUsersInContext:self.scratchContext];
            break;
        }
        case MTPDisplayStyleUsersConnected:
        case MTPDisplayStyleSponsorsUnconnected:
        case MTPDisplayStyleSponsorsPending:
        case MTPDisplayStyleSponsorsNearby: {
            fetchedData = [User allUsersInContext:self.scratchContext];
            break;
        }
        default:
            break;
    }

    if (fetchedData.count > 0)
    {
        self.dataCollection = [self.dataCollection arrayByAddingObjectsFromArray:fetchedData];
        if (completionHandler)
        {
            completionHandler(self.dataCollection);
        }
    }
    else
    {
        if (failureHandler)
        {
            failureHandler([NSError errorWithDomain:([NSURLSession bundleIdentifier] ? [NSURLSession bundleIdentifier] : @"com.MeetingPlay.ErrorDomain")
                                               code:1102
                                           userInfo:@{NSLocalizedDescriptionKey: @"No users found"}]);
        }
    }
}

#pragma mark - UITableView Data Source Conformance
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataCollection.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id cellData = [self.dataCollection objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:(self.cellIdentifier ? self.cellIdentifier : @"TableCell")
                                                            forIndexPath:indexPath];
    
    if (self.cellLayoutDelegate &&
        [self.cellLayoutDelegate respondsToSelector:@selector(layoutCell:tableView:indexPath:data:)])
    {
        cell = [self.cellLayoutDelegate layoutCell:cell
                                         tableView:tableView
                                         indexPath:indexPath
                                              data:cellData];
    }
    
    return cell;
}

#pragma mark - UICollectionView Data Source Conformance
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataCollection.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    id cellData = [self.dataCollection objectAtIndex:indexPath.row];
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:(self.cellIdentifier ? self.cellIdentifier : @"CollectionCell")
                                                                           forIndexPath:indexPath];
    
    if (self.cellLayoutDelegate &&
        [self.cellLayoutDelegate respondsToSelector:@selector(layoutCell:collectionView:indexPath:data:)])
    {
        cell = [self.cellLayoutDelegate layoutCell:cell
                                    collectionView:collectionView
                                         indexPath:indexPath
                                              data:cellData];
    }
    
    return cellData;
}

#pragma mark - Network Requests
- (void)sendAPIRequestURL:(NSString *)requestURLString
           forContentType:(MTPDisplayStyle)contentType
       withAdditionalData:(NSDictionary *)additionalData
        completionHandler:(void(^)(NSArray *))completionHandler
           failureHandler:(void(^)(NSError *))failure
{
    __weak __typeof(&*self)weakSelf = self;
    NSMutableURLRequest *urlRequest = [NSURLSession defaultRequestMethod:@"GET" URL:requestURLString parameters:nil];
    [[[NSURLSession sharedSession] dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        self.networkTasks--;
        
        id responseObject = [NSURLSession serializeJSONData:data response:response error:error];
        
        if (!completionHandler) {
            return;
        }
        
        if ([responseObject isKindOfClass:[NSDictionary class]] == false) {
            return;
        }
        
        switch (contentType)
        {
            case MTPDisplayStyleUsersNearby:
            {
                NSArray *userIDs = [[[responseObject objectForKey:@"data"] objectForKey:@"users"] objectForKey:@"user_id"];
                [self.userIDs addObjectsFromArray:userIDs];
                NSArray *doNotDisplayIDs = @[@(1),@(2),@(3)];
                for (NSNumber *idNumber in doNotDisplayIDs)
                {
                    [self.userIDs removeObject:idNumber];
                }
                if (self.networkTasks == 0)
                {
                    if (completionHandler)
                    {
                        completionHandler([User findUsers:[self.userIDs allObjects] context:weakSelf.scratchContext]);
                    }
                }
                break;
            }
            default:
                break;
        }
    }] resume];
    

}

@end
