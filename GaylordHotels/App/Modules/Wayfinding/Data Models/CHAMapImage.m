//
//  CHAMapImage.m
//  GaylordHotels
//
//  Created by MeetingPlay on 4/29/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "CHAMapImage.h"
#import "NSObject+MTPFileManager.h"
#import "UIImageView+AFNetworking.h"
#import "SDImageCache.h"
#import "SDWebImageManager.h"

@implementation CHAMapImage

+ (instancetype)mapImageFromDictionary:(NSDictionary *)mapImageData
{
    return [[CHAMapImage alloc] initWithMapImageDictionary:mapImageData];
}

- (instancetype)initWithMapImageDictionary:(NSDictionary *)mapImageDictionary
{
    if (self = [super init])
    {
        _buildingID = [mapImageDictionary objectForKey:@"BuildingId"];
        _floorName = [mapImageDictionary objectForKey:@"FloorName"];
        _floorNumber = [mapImageDictionary objectForKey:@"FloorNumber"];
        _mapType = [mapImageDictionary objectForKey:@"MapType"];
        _imageURL = [mapImageDictionary objectForKey:@"Url"];
    }
    return self;
}

- (NSURL *)fullMapImageURL
{
    NSString *baseURL = @"http://api.wayfindingpro.com";
    NSURL *url = [NSURL URLWithString:[[NSString stringWithFormat:@"%@%@",baseURL,self.imageURL] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    return self.imageURL ? url : nil;
}

- (NSString *)displayName
{
    NSString *formattedName;
    if (self.floorName.length > 0)
    {
        formattedName = [self.floorName stringByReplacingOccurrencesOfString:@"-" withString:@" "].capitalizedString;
    }
    else
    {
        formattedName = [NSString stringWithFormat:@"%@",self.floorNumber];
    }
    
    return formattedName;
}

- (void)loadImage:(void(^)(UIImage *))completionHandler
{
    void (^imageCompletionBlock)(UIImage *) = ^(UIImage *loadedImage)
    {
        if (completionHandler)
        {
            completionHandler(loadedImage);
        }
    };
    
    NSURL *mapImageURL = [self fullMapImageURL];
    if (mapImageURL == nil)
    {
        return;
    }
    
    UIImage *mapImage = self.mapImage ? self.mapImage : [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:mapImageURL.absoluteString];;
    if (mapImage == nil)
    {
        __weak __typeof(&*self)weakSelf = self;
        [[SDWebImageManager sharedManager]
         downloadImageWithURL:mapImageURL
         options:0
         progress:nil
         completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL)
         {
            weakSelf.mapImage = image;
            imageCompletionBlock(image);
        }];
    }
    else
    {
        imageCompletionBlock(mapImage);
    }
}

+ (NSArray *)processMapImageURLData:(id)mapImageURLData
{
    if (![mapImageURLData isKindOfClass:[NSArray class]])
    {
        return nil;
    }
    
    NSMutableArray *maps = [NSMutableArray new];
    
    for (id mapImageData in mapImageURLData)
    {
        CHAMapImage *mapImage = [CHAMapImage mapImageFromDictionary:mapImageData];
        [mapImage loadImage:nil];
        if (mapImage)
        {
            [maps addObject:mapImage];
        }
    }
    
    NSArray *sortedArray = [maps sortedArrayUsingComparator:^NSComparisonResult(CHAMapImage *obj1, CHAMapImage *obj2)
    {
        if (obj1.floorNumber.integerValue > obj2.floorNumber.integerValue)
        {
            return NSOrderedAscending;
        }
        else if (obj1.floorNumber.integerValue < obj2.floorNumber.integerValue)
        {
            return NSOrderedDescending;
        }
        else
        {
            return NSOrderedSame;
        }
        
    }];
    
    return sortedArray;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init])
    {
        _buildingID = [aDecoder decodeObjectForKey:@"buildingID"];
        _floorName = [aDecoder decodeObjectForKey:@"floorName"];
        _floorNumber = [aDecoder decodeObjectForKey:@"floorNumber"];
        _mapType = [aDecoder decodeObjectForKey:@"mapType"];
        _imageURL = [aDecoder decodeObjectForKey:@"imageURL"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.buildingID forKey:@"buildingID"];
    [aCoder encodeObject:self.floorName forKey:@"floorName"];
    [aCoder encodeObject:self.floorNumber forKey:@"floorNumber"];
    [aCoder encodeObject:self.mapType forKey:@"mapType"];
    [aCoder encodeObject:self.imageURL forKey:@"imageURL"];
}

+ (NSArray *)mapImagesFromDisk
{
    NSArray *mapImages = [NSArray new];

    if ([mapImages fileExistsInCaches:[CHAMapImage archiveFilename]])
    {
        NSURL *urlForArchiving = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",
                                                       [self cacheDirectory],
                                                       [CHAMapImage archiveFilename]]];
        
        mapImages = [NSKeyedUnarchiver unarchiveObjectWithFile:[urlForArchiving path]];
        
    }
    else
    {
        mapImages = nil;
    }
    
    return mapImages;
}

+ (BOOL)saveMapDataCollection:(NSArray *)mapDataSources
{
    for (id possibleMap in mapDataSources)
    {
        if (![possibleMap isKindOfClass:[CHAMapImage class]])
        {
            NSLog(@"%s\n[%s]: Line %i] Invalid object for archival %@",__FILE__,__PRETTY_FUNCTION__,__LINE__,
                  possibleMap);
            return false;
        }
    }
    
    NSURL *urlForArchiving = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",
                                                   [self cacheDirectory],
                                                   [CHAMapImage archiveFilename]]];
    
    return [NSKeyedArchiver archiveRootObject:mapDataSources
                                       toFile:urlForArchiving.path];
}

+ (NSString *)archiveFilename
{
    return @"mapDataSources.archive";
}


@end