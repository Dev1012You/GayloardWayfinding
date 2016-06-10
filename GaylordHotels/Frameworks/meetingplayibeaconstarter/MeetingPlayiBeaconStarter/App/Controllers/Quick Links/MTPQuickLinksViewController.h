//
//  MTPQuickLinksViewController.h
//  MeetingPlayiBeaconStarter
//
//  Created by John Pacheco on 4/10/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "MTPBaseViewController.h"
#import "MTPCustomRootNavigationViewController.h"

@interface MTPQuickLinksViewController : MTPBaseViewController
@property (nonatomic, weak) MTPCustomRootNavigationViewController *rootNavigationController;
@property (nonatomic, strong) NSArray *quickLinks;

- (void)didSelectMenuItem:(MTPMenuItem *)selectedMenuItem;

@end
