//
//  NSObject+EventDefaultsHelpers.m
//  MeetingPlayiBeaconStarter
//
//  Created by John Pacheco on 4/7/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "NSObject+EventDefaultsHelpers.h"
#import "MTPMenuItem.h"
#import "MTPViewControllerDataSource.h"
#import "MTPAppSettingsKeys.h"

@implementation NSObject (EventDefaultsHelpers)

- (NSUserDefaults *)userDefaults
{
    return [NSUserDefaults standardUserDefaults];
}

- (NSDictionary *)viewControllerDataSources
{
    NSDictionary *viewControllerDataSources = [self.userDefaults objectForKey:MTP_ViewControllerConfigurationData];
    if (!viewControllerDataSources) {
        [self.userDefaults setObject:[NSMutableDictionary new] forKey:MTP_ViewControllerConfigurationData];
    }
    return viewControllerDataSources;
}

- (NSArray *)extractViewControllerDataSources:(MTPMenuItem *)menuItem
{
    __block NSMutableArray *controllerDataSources = [NSMutableArray new];
    for (NSDictionary *viewControllerSubItem in menuItem.additionalData)
    {
        MTPViewControllerDataSource *dataSource = [MTPViewControllerDataSource viewDataSource:viewControllerSubItem];
        [controllerDataSources addObject:dataSource];
    }
    return controllerDataSources;
}

- (NSArray *)quickLinkItems
{
    NSMutableArray *menuItems = [NSMutableArray new];

    NSArray *quickLinks = [self.userDefaults objectForKey:MTP_QuickLinksItems];
    for (NSDictionary *menuItemDictionary in quickLinks)
    {
        MTPMenuItem *newMenuItem = [MTPMenuItem menuItemFromDictionary:menuItemDictionary];
        if (newMenuItem)
        {
            [menuItems addObject:newMenuItem];
        }
    }
    return menuItems;
}

- (NSArray *)defaultMainMenuItems
{
    NSArray *menuItems = [self menuItemsFromCollection:[[self.userDefaults objectForKey:MTP_MainMenuOptions] objectForKey:MTP_MainMenuItems]];
    return menuItems;
}

- (NSArray *)menuItemsFromCollection:(NSArray *)menuItemCollection
{
    __block NSArray *menuItemsGrouped = [NSArray new];
    
    [menuItemCollection enumerateObjectsUsingBlock:^(NSDictionary *menuItemsInSections, NSUInteger idx, BOOL *stop)
    {
        [menuItemsInSections enumerateKeysAndObjectsWithOptions:NSEnumerationReverse usingBlock:^(id key, NSArray *menuItemDictionaryCollection, BOOL *stop)
        {
            NSString *groupName;
            if ([key isKindOfClass:[NSString class]])
            {
                groupName = key;
            }
            else
            {
                groupName = @"section";
            }
            
            NSMutableArray *menuItems = [NSMutableArray new];
            
            for (NSDictionary *menuItemDictionary in menuItemDictionaryCollection)
            {
                MTPMenuItem *newMenuItem = [MTPMenuItem menuItemFromDictionary:menuItemDictionary];
                if (newMenuItem)
                {
                    [menuItems addObject:newMenuItem];
                }
            }
            menuItemsGrouped = [menuItemsGrouped arrayByAddingObject:@{groupName: menuItems}];
        }];
    }];
    
    return menuItemsGrouped;
}

- (NSDictionary *)dummyMenuItem
{
    NSMutableDictionary *itemDictionary = [NSMutableDictionary new];
    
    [itemDictionary setObject:@"pageTitle" forKey:@"title"];
    [itemDictionary setObject:@"subTitle" forKey:@"subtitle"];
    [itemDictionary setObject:@"itemDescription" forKey:@"itemDescription"];
    //    [itemDictionary setObject:@"" forKey:@"imageURL"];
    //    [itemDictionary setObject: forKey:@"link"];
    [itemDictionary setObject:@"Connect" forKey:@"category"];
    [itemDictionary setObject:@(MTPNavigationTypeNavigationController) forKey:@"navigationType"];
    [itemDictionary setObject:@(0) forKey:@"selectedTabBarIndex"];
    
    return itemDictionary;
}

- (UIView *)addSeparatorLine:(UILabel *)mainTitleLabel
{
    if (!mainTitleLabel)
    {
        return nil;
    }
    CGRect separatorLineFrame = mainTitleLabel.frame;
    separatorLineFrame.size.height = 1.f;
    separatorLineFrame.origin.y = CGRectGetMaxY(mainTitleLabel.frame) - (separatorLineFrame.size.height * (mainTitleLabel.frame.size.height * 0.15));
    separatorLineFrame.origin.x = 0;
    UIView *separatorLine = [[UIView alloc] initWithFrame:separatorLineFrame];
    separatorLine.translatesAutoresizingMaskIntoConstraints = false;
    separatorLine.backgroundColor = [UIColor whiteColor];
    return separatorLine;
}

- (UIFont *)customSectionHeaderFont:(NSDictionary *)customTextStyling
{
    UIFont *sectionHeaderFont;
    
    NSString *customFontName = [customTextStyling objectForKey:MTP_MainMenuSectionFontName];
    NSNumber *customFontSize = [customTextStyling objectForKey:MTP_MainMenuSectionFontSize];
    if (customFontName)
    {
        if (customFontSize)
        {
            sectionHeaderFont = [UIFont fontWithName:customFontName
                                                size:customFontSize.floatValue];
        }
        else
        {
            sectionHeaderFont = [UIFont fontWithName:customFontName
                                                size:[[customTextStyling objectForKey:MTP_MainMenuDefaultFontSize] floatValue]];
        }
    } else {
        sectionHeaderFont = [UIFont fontWithName:[customTextStyling objectForKey:MTP_MainMenuDefaultFontName]
                                            size:[[customTextStyling objectForKey:MTP_MainMenuDefaultFontSize] floatValue]];
    }
    return sectionHeaderFont;
}

- (UIFont *)customMainMenuHeaderFont:(NSDictionary *)headerStyling
{
    UIFont *customHeaderFont;
    
    NSString *fontName = [headerStyling objectForKey:@"headerFontName"];
    if (fontName)
    {
        NSNumber *fontSize = [headerStyling objectForKey:@"headerFontSize"];
        if (fontSize)
        {
            customHeaderFont = [UIFont fontWithName:fontName size:fontSize.floatValue];
        }
        else
        {
            customHeaderFont = [UIFont fontWithName:fontName size:[[headerStyling objectForKey:@"headerFontDefaultSize"] floatValue]];
        }
    }
    return customHeaderFont;
}


- (UIFont *)customMainMenuHeaderSubtitleFont:(NSDictionary *)headerStyling
{
    UIFont *customHeaderFont;
    
    NSString *fontName = [headerStyling objectForKey:@"headerSubtitleFontName"];
    if (fontName)
    {
        NSNumber *fontSize = [headerStyling objectForKey:@"headerSubtitleFontSize"];
        if (fontSize)
        {
            customHeaderFont = [UIFont fontWithName:fontName size:fontSize.floatValue];
        }
        else
        {
            customHeaderFont = [UIFont fontWithName:fontName size:[[headerStyling objectForKey:@"headerFontDefaultSize"] floatValue]];
        }
    }
    return customHeaderFont;
}

//- (UIColor *)appTintColor
//{
//    return UIColorFromRGB(0x0178b0);
//}

- (UIColor *)colorFromString:(NSString *)colorString
{
    if (colorString.length == 0)
    {
        return nil;
    }
    
    NSMutableString *tempHex = [[NSMutableString alloc] init];

    [tempHex appendString:colorString];
    
    unsigned colorInt = 0;
    
    [[NSScanner scannerWithString:tempHex] scanHexInt:&colorInt];
    
    return UIColorFromRGB(colorInt);
}


@end
