//
//  GAHDetailHeaderViewController.m
//  GaylordHotels
//
//  Created by MeetingPlay on 5/7/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "GAHDetailHeaderViewController.h"
#import "UIView+AutoLayoutHelper.h"
#import "UIImageView+AFNetworking.h"
#import "UIView+MTPCategory.h"
#import "GAHDestination.h"
#import "SDWebImageDownloader.h"

@interface GAHDetailHeaderViewController ()
@property (nonatomic, strong) NSDictionary *dataSource;
@property (nonatomic, strong) NSArray *displayImageNames;
@property (nonatomic, strong) NSArray *displayImages;
@end

@implementation GAHDetailHeaderViewController
#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [UIView createLayerShadow:self.view.layer];
    self.headerImage.clipsToBounds = true;
    self.headerImage.contentMode = UIViewContentModeScaleAspectFill;
    
    self.displayImageNames = [NSArray new];
    self.displayImages = [NSArray new];
}

#pragma mark - Protocol Conformance
#pragma mark - Helper Methods
- (void)cycleImages:(id)sender
{
    if (self.displayImages.count)
    {
        UIImage *currentImage = self.headerImage.image;
        NSUInteger currentImageIndex = [self.displayImages indexOfObject:currentImage];
        NSUInteger imageNextIndex = (currentImageIndex < self.displayImages.count - 1 ? ++currentImageIndex : 0);
        UIImage *nextImage = self.displayImages[imageNextIndex];
        
        [self.headerImage setImage:nextImage];
    }
}

- (void)startImageCycle
{
    if (self.imageCycle == nil)
    {
        self.imageCycle = [NSTimer timerWithTimeInterval:5 target:self selector:@selector(cycleImages:) userInfo:nil repeats:true];
        [[NSRunLoop currentRunLoop] addTimer:self.imageCycle forMode:NSDefaultRunLoopMode];
    }
    
    [self.imageCycle fire];
}

- (void)cancelTimer
{
    [self.imageCycle invalidate];
    self.imageCycle = nil;
}

#pragma mark - Initial Setup
- (void)configureWithDataSource:(GAHDestination *)locationItem
{
    /*
    selected data {
        alt = "Aerial_Overall_9176";
        category = Recreation;
        image = "Aerial_Overall_9176.jpg";
        location = "Falls Pool Oasis";
        locationid = 5;
        slug = "iconic-falls-pool";
    }
     */
    
    if ([locationItem isKindOfClass:[GAHDestination class]])
    {
        NSArray *imagesToDisplay = [NSArray new];
        NSString *imageName = [locationItem.image stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        if (imageName.length > 0)
        {
            imagesToDisplay = [imagesToDisplay arrayByAddingObject:imageName];
        }
        
        [self setHeaderBackgroundImage:imageName];
    }
}

- (void)updateHeaderImage:(GAHDestination *)destination
{
    __block NSArray *additionalImages = [NSArray new];
    if (destination.images.count > 0)
    {
        [destination.images enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            if (![obj isKindOfClass:[NSDictionary class]])
            {
                return;
            }
            
            NSString *imageName = [obj objectForKey:@"image"];
            if (imageName.length > 0)
            {
                additionalImages = [additionalImages arrayByAddingObject:[imageName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            }
        }];
        
        self.displayImageNames = [NSArray arrayWithArray:additionalImages];
        [self headerBackgroundImages:self.displayImageNames];
        
        [self startImageCycle];
    }
}

- (void)headerBackgroundImages:(NSArray *)imageNames
{
    self.displayImages = [NSArray new];
    NSString *baseImageURL = [self.userDefaults objectForKey:kGAHLocationImageURL];
    __weak __typeof(&*self)weakSelf = self;
    for (NSString *imageName in imageNames)
    {
        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",baseImageURL,imageName]] options:0 progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
            
            if (image)
            {
                weakSelf.displayImages = [weakSelf.displayImages arrayByAddingObject:image];
            }
        }];
    }
}

- (void)setHeaderBackgroundImage:(NSString *)imageName
{
    if (imageName.length > 0)
    {
        self.headerImage.alpha = 1.f;
        NSString *baseImageURL = [self.userDefaults objectForKey:kGAHLocationImageURL];
        NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",baseImageURL,imageName]];
        [self.headerImage setImageWithURL:imageURL placeholderImage:nil];
    }
    else
    {
        self.headerImage.alpha = 0.25f;
    }
}

#pragma mark - Auto Layout Setup
- (void)setupConstraints
{

}


@end
