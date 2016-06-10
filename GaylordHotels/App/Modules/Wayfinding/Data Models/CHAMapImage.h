//
//  CHAMapImage.h
//  GaylordHotels
//
//  Created by MeetingPlay on 4/29/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CHAMapImage : NSObject <NSCoding>

@property (nonatomic, strong) NSNumber *buildingID;
@property (nonatomic, strong) NSString *floorName;
@property (nonatomic, strong) NSNumber *floorNumber;
@property (nonatomic, strong) NSString *mapType;
@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, strong) UIImage *mapImage;

+ (instancetype)mapImageFromDictionary:(NSDictionary *)mapImageData;

- (instancetype)initWithMapImageDictionary:(NSDictionary *)mapImageDictionary;

- (NSString *)displayName;

- (void)loadImage:(void(^)(UIImage *loadedImage))completionHandler;

- (NSURL *)fullMapImageURL;

// convenience collection creator
+ (NSArray *)processMapImageURLData:(id)mapImageURLData;
+ (NSArray *)mapImagesFromDisk;
+ (BOOL)saveMapDataCollection:(NSArray *)mapDataSources;
+ (NSString *)archiveFilename;

//- (UIImage *)mapImage;

@end
