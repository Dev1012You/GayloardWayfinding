//
//  MTPQuickLinksViewController.m
//  MeetingPlayiBeaconStarter
//
//  Created by John Pacheco on 4/10/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "MTPQuickLinksViewController.h"
#import "MTPMenuItem.h"
#import "MTPMenuIcon.h"
#import "MTPViewControllerDataSource.h"
#import "MTPAppSettingsKeys.h"

@interface MTPQuickLinksViewController ()

@end

@implementation MTPQuickLinksViewController
#pragma mark - View Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.quickLinks = [self prepareDataSource];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.rootNavigationController = [[self.parentViewController navigationController] isKindOfClass:[MTPCustomRootNavigationViewController class]] ? [(MTPCustomRootNavigationViewController *)self.parentViewController navigationController] : nil;
}

#pragma mark - Initial Setup
- (NSArray *)prepareDataSource
{
    NSMutableArray *quickLinkMenuItems = [NSMutableArray new];
    for (NSDictionary *menuItemDictionary in [self.userDefaults objectForKey:MTP_QuickLinksItems])
    {
        MTPMenuItem *newMenuItem = [MTPMenuItem menuItemFromDictionary:menuItemDictionary];
        if (newMenuItem)
        {
            [quickLinkMenuItems addObject:newMenuItem];
        }
    }
    return quickLinkMenuItems;
}
#pragma mark - Protocol Conformance
#pragma mark - IBActions
#pragma mark - Helper Methods
- (void)didSelectMenuItem:(MTPMenuItem *)selectedMenuItem
{
    [self.rootNavigationController loadViewController:selectedMenuItem controllerDataSources:[self extractViewControllerDataSources:selectedMenuItem]];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
