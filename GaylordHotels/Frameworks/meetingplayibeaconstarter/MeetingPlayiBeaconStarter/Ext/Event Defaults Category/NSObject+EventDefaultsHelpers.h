//
//  NSObject+EventDefaultsHelpers.h
//  MeetingPlayiBeaconStarter
//
//  Created by John Pacheco on 4/7/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MTPMenuItem;

@interface NSObject (EventDefaultsHelpers)

- (NSUserDefaults *)userDefaults;

- (NSDictionary *)viewControllerDataSources;

- (NSArray *)extractViewControllerDataSources:(MTPMenuItem *)menuItem;

- (NSArray *)quickLinkItems;

- (NSArray *)defaultMainMenuItems;

- (NSArray *)menuItemsFromCollection:(NSArray *)menuItemCollection;

- (UIFont *)customSectionHeaderFont:(NSDictionary *)customTextStyling;
- (UIFont *)customMainMenuHeaderFont:(NSDictionary *)headerStyling;
- (UIFont *)customMainMenuHeaderSubtitleFont:(NSDictionary *)headerStyling;

- (NSDictionary *)dummyMenuItem;

- (UIView *)addSeparatorLine:(UILabel *)mainTitleLabel;

//- (UIColor *)appTintColor;

- (UIColor *)colorFromString:(NSString *)colorString;

#ifndef __OPTIMIZE__
#   define DLog(fmt, ...) NSLog((@"%s [File %s: Line %d] " fmt), __PRETTY_FUNCTION__, __FILE__, __LINE__, ##__VA_ARGS__)
#   define ELog(err) {if(err) DLog(@"%@", err);}
#else
#   define DLog(...)
#endif

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
@end
