//
//  MTPMainMenuViewController.m
//  MeetingPlayiBeaconStarter
//
//  Created by John Pacheco on 4/10/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "MTPMainMenuViewController.h"

@interface MTPMainMenuViewController ()
@end

@implementation MTPMainMenuViewController
#pragma mark - View Life Cycle
- (void)awakeFromNib
{
    [super awakeFromNib];
    self.visiblityState = MTPMainMenuVisibilityStateHidden;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.mainMenuItems = [self defaultMainMenuItems];
}

#pragma mark - Initial Setup

#pragma mark - Protocol Conformance
#pragma mark UITableView Conformance
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.mainMenuItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    cell = [self configureTableView:tableView
                               cell:cell
                           cellData:self.mainMenuItems
                          indexPath:indexPath];
    
    return cell;
}

- (UITableViewCell *)configureTableView:(UITableView *)tableView
                                   cell:(UITableViewCell *)cell
                               cellData:(id)cellData
                              indexPath:(NSIndexPath *)indexPath
{
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    [self processTableView:tableView selection:indexPath tableData:self.mainMenuItems];
}

#pragma mark - Helper Methods
#pragma mark Menu Visibility
- (void)toggleMenu:(id)sender
{
    if (self.mainMenuDelegate && [self.mainMenuDelegate respondsToSelector:@selector(mainMenuDidToggleMenu:)])
    {
        [self.mainMenuDelegate mainMenuDidToggleMenu:self];
    }
}

#pragma mark Menu Item Loading
- (void)processTableView:(UITableView *)tableView
               selection:(NSIndexPath *)indexPath
               tableData:(id)tableData
{
    if ([tableData isKindOfClass:[NSArray class]])
    {
        NSString *sectionName = [[[tableData objectAtIndex:indexPath.section] allKeys] firstObject];
        [self loadMainMenuItem:[[[tableData objectAtIndex:indexPath.section] objectForKey:sectionName] objectAtIndex:indexPath.row]];
    }
}

- (void)loadMainMenuItem:(MTPMenuItem *)menuItem
{
    if ([menuItem.title caseInsensitiveCompare:@"near me"] == NSOrderedSame)
    {
        [self didSelectNearMe:menuItem];
    }
    else
    {
        [self.rootNavigationController loadViewController:menuItem
                                    controllerDataSources:[self extractViewControllerDataSources:menuItem]];
    }
}

- (void)didSelectNearMe:(MTPMenuItem *)menuItem
{
    if (self.mainMenuDelegate && [self.mainMenuDelegate respondsToSelector:@selector(mainMenu:didSelectMainMenuItem:)])
    {
        [self.mainMenuDelegate mainMenu:self didSelectMainMenuItem:menuItem];
    }
}

- (void)reloadMainMenuData:(void(^)(NSArray *menuItemCollection))reloadCompletionHandler
{
    if (reloadCompletionHandler)
    {
        reloadCompletionHandler(nil);
    }
}

@end
