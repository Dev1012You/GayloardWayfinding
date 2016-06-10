//
//  MTPMenuItem.h
//  MeetingPlayiBeaconStarter
//
//  Created by John Pacheco on 4/9/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MTPMenuIcon;

typedef NS_ENUM(NSUInteger, MTPNavigationType) {
    MTPNavigationTypeNavigationController = 0,
    MTPNavigationTypeSingleViewController = 1,
    MTPNavigationTypeTabBarController = 2,
};

@interface MTPMenuItem : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subtitle;
@property (nonatomic, strong) NSString *itemDescription;
@property (nonatomic, strong) NSURL *imageURL;

@property (nonatomic, strong) MTPMenuIcon *icon;
@property (nonatomic, strong) NSURL *link;
@property (nonatomic, strong) NSString *category;

@property (nonatomic, assign) MTPNavigationType navigationType;
@property (nonatomic, assign) NSInteger selectedTabBarIndex;
@property (nonatomic, strong) NSArray *additionalData;

+ (instancetype)menuItemFromDictionary:(NSDictionary *)itemDictionary;

@end

