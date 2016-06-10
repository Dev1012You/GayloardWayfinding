//
//  GAHLandingCell.m
//  GaylordHotels
//
//  Created by MeetingPlay on 5/6/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "GAHLandingCell.h"
#import "GAHDataSource.h"
#import "EventKeys.h"
#import "NSObject+EventDefaultsHelpers.h"

@implementation GAHLandingCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.iconLabel.font = [UIFont fontWithName:@"FontAwesome" size:15.f];
    self.iconLabel.textAlignment = NSTextAlignmentCenter;
    
    UIView *containerView = self.bannerImage.superview;
    if (containerView)
    {
        containerView.layer.shadowColor = [UIColor blackColor].CGColor;
        containerView.layer.shadowOpacity = 0.2f;
        containerView.layer.shadowRadius = 1.f;
        containerView.layer.shadowOffset = CGSizeMake(0,1);
    }
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.bannerImage.image = nil;
}

- (void)loadImageForCategory:(NSString *)dataCategory
{
    const NSDictionary *categories = @{@"Recreation": @(GAHDataCategoryRecreation),
                                       @"Restaurants & Lounges": @(GAHDataCategoryRestaurants)};
    
    const NSDictionary *codeForCategory = @{@(GAHDataCategoryRestaurants): @"\uf0f5",
                                            @(GAHDataCategoryRecreation): @"\uf185"};
    
    GAHDataCategory category = [[categories objectForKey:dataCategory] integerValue];
    
    NSString *iconCode = [codeForCategory objectForKey:@(category)];
    if (iconCode)
    {
        self.iconLabel.text = iconCode;
    }
    else
    {
        self.iconLabel.text = @"\uf14e";
    }
    
    UIColor *categoryColor = [self categoryColor:category];
    if (categoryColor)
    {
        self.iconLabel.textColor = categoryColor;
    }
    else
    {
        self.iconLabel.textColor = [UIColor darkGrayColor];
    }
}

- (UIColor *)categoryColor:(GAHDataCategory)dataCategory
{
    NSDictionary *colorsForCategories = @{@(GAHDataCategoryRestaurants): kDarkBlue,
                                          @(GAHDataCategoryRecreation): UIColorFromRGB(0xa61c1c)};
    return colorsForCategories[@(dataCategory)];
}

/*
 Printing description of cellData:
 {
 alt = "Aerial_Overall_9176";
 category = Recreation;
 image = "Aerial_Overall_9176.jpg";
 location = "Falls Pool Oasis";
 locationid = 5;
 slug = "iconic-falls-pool";
 }
 */
@end
