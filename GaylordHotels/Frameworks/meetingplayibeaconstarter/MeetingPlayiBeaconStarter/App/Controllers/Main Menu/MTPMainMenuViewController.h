//
//  MTPMainMenuViewController.h
//  MeetingPlayiBeaconStarter
//
//  Created by John Pacheco on 4/10/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "MTPBaseViewController.h"
#import "MTPCustomRootNavigationViewController.h"
#import "MTPMenuItem.h"
#import "MTPViewControllerDataSource.h"

@class MTPMainMenuViewController;

typedef NS_ENUM(NSInteger, MTPMainMenuVisibilityState)
{
    MTPMainMenuVisibilityStateHidden     = -1,
    MTPMainMenuVisibilityStateAnimating  =  0,
    MTPMainMenuVisibilityStateVisible    =  1,

};

@protocol MTPMainMenuDelegate <NSObject>
- (void)mainMenu:(MTPMainMenuViewController *)mainMenu didSelectMainMenuItem:(MTPMenuItem *)menuItem;
@optional
- (void)mainMenuDidToggleMenu:(MTPMainMenuViewController *)mainMenu;
@end

@interface MTPMainMenuViewController : MTPBaseViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id <MTPMainMenuDelegate> mainMenuDelegate;
@property (nonatomic, weak) MTPCustomRootNavigationViewController *rootNavigationController;
@property (nonatomic, strong) NSArray *mainMenuItems;
@property (nonatomic, assign) MTPMainMenuVisibilityState visiblityState;

- (void)loadMainMenuItem:(MTPMenuItem *)menuItem;

- (UITableViewCell *)configureTableView:(UITableView *)tableView
                                   cell:(UITableViewCell *)cell
                               cellData:(id)cellData
                              indexPath:(NSIndexPath *)indexPath;
/**
 @description Reloads the menu data. The default implementation does nothing. Subclasses should override this method to perform custom data fetching.
 @param reloadCompletionHandler Optional completion handler
 */
- (void)reloadMainMenuData:(void(^)(NSArray *menuItems))reloadCompletionHandler;

@end
