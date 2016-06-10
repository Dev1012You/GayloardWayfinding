    //
//  GAHDataSource.m
//  GaylordHotels
//
//  Created by MeetingPlay on 5/4/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "GAHDataSource.h"
#import "CHADestination.h"
#import "CHAMapImage.h"
#import "CHAWayfindingSOAPTask.h"
#import "GAHDestination.h"
#import "GAHPropertyCategory.h"

#import "NSObject+EventDefaultsHelpers.h"
#import "NSURLSession+MTPCategory.h"

@interface GAHDataSource ()
@property (nonatomic, readwrite, assign) GAHDataSourceUpdateState updateState;

@end

@implementation GAHDataSource

- (instancetype)init
{
    if (self = [super init])
    {
        _updateState = GAHDataSourceUpdateStateNotFetching;
    }
    return self;
}

- (void)localDataForCategory:(GAHPropertyCategory *)category
           completionHandler:(void (^)(NSArray *))successHandler
              failureHandler:(void (^)(NSError *))errorHandler
{
    NSString *categoryName = category.categoryName;
    
    NSMutableArray *matchingDestinations = [NSMutableArray new];
    
    for (GAHDestination *destination in self.meetingPlayDestinations)
    {
        if ([destination.category isEqualToString:categoryName])
        {
            [matchingDestinations addObject:destination];
        }
    }
    
    self.categoryItems = [matchingDestinations sortedArrayUsingComparator:^NSComparisonResult(GAHDestination *obj1, GAHDestination *obj2)
    {
        return [obj1.location caseInsensitiveCompare:obj2.location];
    }];
    
    self.data = self.categoryItems;
    
    if (successHandler)
    {
        successHandler(matchingDestinations);
    }
}

- (void)filterList:(NSString *)searchCriteria data:(NSArray *)data
{
    NSArray *dataCopy = [NSArray arrayWithArray:data];
    
    NSPredicate *nameFilter = [NSPredicate predicateWithFormat:@"self.location contains[cd] %@",searchCriteria];
    
    NSArray *filteredArray = [dataCopy filteredArrayUsingPredicate:nameFilter];
    
    self.data = filteredArray;
}

- (void)fetchDataForType:(GAHDataCategory)dataCategory
       completionHandler:(void (^)(NSArray *))completionHandler
{
    NSString *requestURL = [self urlForCategory:dataCategory];
    
    NSMutableURLRequest *featuredReqeuest = [NSURLSession defaultRequestMethod:@"GET"
                                                                           URL:requestURL
                                                                    parameters:nil];
    
    [self sendRequest:featuredReqeuest dataCategory:dataCategory completionHandler:completionHandler];
}

#pragma mark - UICollectionView Protocol Conformance
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.data.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.cellReuseIdentifier forIndexPath:indexPath];
    id cellData = self.data[indexPath.row];
    if (self.cellLayoutHandler)
    {
        self.cellLayoutHandler(cell,cellData,indexPath);
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:true];
    
    id selectedData = [self.data objectAtIndex:indexPath.row];
    if (self.cellSelectionHandler)
    {
        self.cellSelectionHandler(selectedData);
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = CGRectGetWidth(collectionView.frame) - 10 * 2;
    CGFloat height = width * (3/4.f);
    
    if (self.cellHeightCalculation)
    {
        CGSize customCellSize = self.cellHeightCalculation(collectionView);
        width = customCellSize.width;
        height = customCellSize.height;
    }
    
    return CGSizeMake(width, height);
}

#pragma mark - API Data Fetching
- (void)sendRequest:(NSURLRequest *)request
       dataCategory:(GAHDataCategory)dataCategory
  completionHandler:(void (^)(NSArray *))completionHandler
{
    __weak __typeof(&*self)weakSelf = self;
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        id responseObject = [NSURLSession serializeJSONData:data
                                                   response:response
                                                      error:error];
        
        if ([responseObject isKindOfClass:[NSDictionary class]])
        {
            NSDictionary *apiData = [responseObject objectForKey:@"data"];
            if (apiData)
            {
                if (dataCategory == GAHDataCategoryLocation)
                {
                    if ([weakSelf.data.firstObject isKindOfClass:[GAHDestination class]])
                    {
                        GAHDestination *destination = weakSelf.data.firstObject;
                        [destination updateWithMeetingPlay:apiData];
                        
                        NSArray *links = [apiData objectForKey:@"links"];
                        if (links)
                        {
                            weakSelf.data = links;
                        }
                        
                        if (completionHandler)
                        {
                            completionHandler(@[destination]);
                        }
                    }
                }
                else
                {
                    NSString *baseImageURL = [[apiData objectForKey:@"image_url"] objectForKey:@"locations"];
                    if (baseImageURL.length > 0)
                    {
                        //                    [weakSelf.userDefaults setObject:baseImageURL forKey:@"GAHLocationImageURL"];
                    }
                    
                    NSArray *locations = [apiData objectForKey:@"locations"];
                    if (locations.count > 0 && completionHandler)
                    {
                        weakSelf.data = locations;
                        completionHandler(locations);
                    }
                }
            }
        }
    }] resume];
}

- (NSString *)urlForCategory:(GAHDataCategory)dataCategory
{
    NSMutableDictionary *urlDictionary =
    [NSMutableDictionary dictionaryWithDictionary:@{@(GAHDataCategoryFeatured): @"http://mapsapi.meetingplay.com/property/3/locations/featured",
                                                    @(GAHDataCategoryMainHotel): @"http://mapsapi.meetingplay.com/property/3/locations/featured"}];
    if (dataCategory == GAHDataCategoryLocation)
    {
        if ([[self.data firstObject] isKindOfClass:[GAHDestination class]])
        {
            GAHDestination *location = (GAHDestination *)[self.data firstObject];
            [urlDictionary setObject:[NSString stringWithFormat:@"http://mapsapi.meetingplay.com/property/3/location/%@",location.slug] forKey:@(GAHDataCategoryLocation)];
        }
    }
    
    return urlDictionary[@(dataCategory)];
}




























@end
