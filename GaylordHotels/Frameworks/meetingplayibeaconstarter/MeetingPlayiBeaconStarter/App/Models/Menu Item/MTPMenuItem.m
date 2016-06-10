//
//  MTPMenuItem.m
//  MeetingPlayiBeaconStarter
//
//  Created by John Pacheco on 4/9/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "MTPMenuItem.h"
#import "MTPMenuIcon.h"

@implementation MTPMenuItem

+ (instancetype)menuItemFromDictionary:(NSDictionary *)itemDictionary
{
    MTPMenuItem *menuItem = [[MTPMenuItem alloc] init];
    
    menuItem.title = [itemDictionary objectForKey:@"title"];
    menuItem.subtitle = [itemDictionary objectForKey:@"subtitle"];
    menuItem.itemDescription = [itemDictionary objectForKey:@"itemDescription"];
    menuItem.category = [itemDictionary objectForKey:@"category"];
    menuItem.additionalData = [itemDictionary objectForKey:@"additionalData"];

    menuItem.imageURL = [NSURL URLWithString:[itemDictionary objectForKey:@"imageURL"]];
    menuItem.link = [NSURL URLWithString:[itemDictionary objectForKey:@"link"]];
    
    menuItem.navigationType = [[itemDictionary objectForKey:@"navigationType"] integerValue];
    menuItem.icon = [[MTPMenuIcon alloc] initWithDictionary:[itemDictionary objectForKey:@"icon"]];
    menuItem.selectedTabBarIndex = 0;
    
    return menuItem;
}

@end
