//
//  GAHMainMenuViewController.h
//  GaylordHotels
//
//  Created by MeetingPlay on 4/27/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "MTPMainMenuViewController.h"

@class GAHRootNavigationController;

@interface GAHMainMenuViewController : MTPMainMenuViewController <UITextFieldDelegate>

@property (nonatomic, strong) GAHRootNavigationController *rootNavigationController;

@property (strong, nonatomic) NSArray *parsedMenuItems;
@property (nonatomic, weak) IBOutlet UIButton *homeButton;
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (nonatomic, weak) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UITableView *mainMenuTableView;

- (NSArray *)loadMenuData:(NSArray *)mainMenuItems;

- (IBAction)didPressHome:(id)sender;
- (IBAction)didPressSearch:(id)sender;

@end


@interface GAHMainMenuCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *menuItemIconLabel;
@property (weak, nonatomic) IBOutlet UIImageView *menuItemIconImage;
@property (nonatomic, weak) IBOutlet UILabel *menuItemLabel;

@end